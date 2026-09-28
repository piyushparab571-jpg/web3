// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: delegatecall Demo
CONCEPT: Context execution (storage of caller contract)
=========================================================

OBJECTIVE

- Understand delegatecall execution model
- See how storage of caller contract is modified
- Learn why delegatecall is powerful AND dangerous
- Observe context (msg.sender, msg.value, storage)

=========================================================
CORE IDEA
=========================================================

delegatecall:

- runs code from another contract
- BUT uses caller’s storage, msg.sender, msg.value

=========================================================
KEY DIFFERENCE

call        → changes callee storage
delegatecall → changes caller storage ❗

=========================================================
LIBRARY CONTRACT (LOGIC ONLY)
=========================================================
*/

contract LogicContractVul {

    // NOTE: storage layout MUST match caller
    uint256 public num;
    address public sender;

    /*
    =====================================================
    SET FUNCTION (RUNS IN CALLER CONTEXT)
    =====================================================
    */

    function set(uint256 _num) external payable {

        /*
            These variables actually belong to CALLER
            when used via delegatecall
        */

        num = _num;
        sender = msg.sender;
    }
}

/*
=========================================================
CALLER CONTRACT (STATE HOLDER)
=========================================================
*/

contract ProxyContractVul {

    uint256 public num;
    address public sender;

    /*
        Address of logic contract
    */
    address public logic;

    constructor(address _logic) {
        logic = _logic;
    }

    /*
    =====================================================
    DELEGATECALL EXECUTION
    =====================================================
    */

    function setViaDelegate(uint256 _num) external payable {

        (bool success, ) = logic.delegatecall(abi.encodeWithSignature("set(uint256)",_num ));
        require(success, "delegatecall failed");
    }
}

/*
Audit Report

Title: Untrusted delegatecall Usage in setViaDelegate()

Severity: High

Reason:
delegatecall executes external contract code in the storage context of the calling contract.

Location:

Contract: ProxyContract
Function: setViaDelegate()

Vulnerability Description:
The setViaDelegate() function performs a delegatecall to the address stored in the logic variable.

Because delegatecall executes the target contract's code using the storage, msg.sender, and msg.value of the
calling contract, any malicious or incorrect logic contract can modify the storage of ProxyContract.

Impact:
If the logic contract contains malicious code, it can:

- overwrite storage variables
- modify critical contract state
- corrupt data
- potentially take control of protocol functionality

The caller contract fully trusts the external logic contract.

Proof of Concept:

        1.Deploy LogicContract.
        2.Deploy ProxyContract with LogicContract address.
        3.Call:
            setViaDelegate(100)
        The LogicContract code executes, but the storage updated belongs to ProxyContract.
        If logic is replaced with a malicious contract containing harmful storage writes, the storage of 
        ProxyContract can be modified unexpectedly.

Root Cause:
The function uses delegatecall to execute code from an external contract.

delegatecall runs code in the context of the caller contract and grants the target contract access to the 
caller's storage layout.

Recommendation:

Only delegatecall to trusted and verified contracts.
Carefully validate logic contract addresses before deployment or upgrades.
Ensure storage layouts remain compatible between contracts.
*/

//patched code
contract LogicContract {

    // NOTE: storage layout MUST match caller
    uint256 public num;
    address public sender;

    /*
    =====================================================
    SET FUNCTION (RUNS IN CALLER CONTEXT)
    =====================================================
    */

    function set(uint256 _num) external payable {

        /*
            These variables actually belong to CALLER
            when used via delegatecall
        */

        num = _num;
        sender = msg.sender;
    }
}

/*
=========================================================
CALLER CONTRACT (STATE HOLDER)
=========================================================
*/

contract ProxyContract {

    uint256 public num;
    address public sender;

    /*
        Address of logic contract
    */
    address public immutable logic;

    constructor(address _logic) {
         require(logic !=address(0),"Invalid Logic");
         sender=msg.sender;
        logic = _logic;
    }

    modifier onlyOwner(){
        require(msg.sender==sender,"Not Owner");
        _;
    }

    /*
    =====================================================
    DELEGATECALL EXECUTION
    =====================================================
    */

    function setViaDelegate(uint256 _num) external payable onlyOwner {
        (bool success, ) = logic.delegatecall(abi.encodeWithSignature("set(uint256)",_num ));
        require(success, "delegatecall failed");
    }
}