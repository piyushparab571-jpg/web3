// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Storage Collision Demo
CONCEPT: Upgrade/Proxy Risk (delegatecall mismatch)
=========================================================

OBJECTIVE

- Understand storage layout collision in proxy patterns
- See how delegatecall can corrupt state
- Learn why upgradeable contracts are dangerous if misaligned
- Observe proxy vs logic storage interaction

=========================================================
CORE IDEA
=========================================================

delegatecall uses CALLER STORAGE.

If storage layouts differ between:
- Proxy contract
- Logic contract

→ storage collision occurs ❌

=========================================================
VULNERABLE LOGIC CONTRACT (V1)
=========================================================
*/

contract LogicV1Vul {

    // SLOT 0
    uint256 public value;

    // SLOT 1
    address public owner;

    function setValue(uint256 _value) external {
        value = _value;
    }

    function setOwner(address _owner) external {
        owner = _owner;
    }
}

/*
=========================================================
PROXY CONTRACT (WRONG STORAGE LAYOUT)
=========================================================
*/

contract ProxyBad {

    /*
        ❌ STORAGE MISMATCH STARTS HERE
    */

    // SLOT 0 (EXPECTED: maybe admin)
    address public admin;

    // SLOT 1 (EXPECTED: implementation)
    address public implementation;

    /*
        BUT LogicV1 expects:
        slot0 = value
        slot1 = owner
    */

    constructor(address _impl) {
        admin = msg.sender;
        implementation = _impl;
    }

    /*
    =====================================================
    DELEGATECALL EXECUTION
    =====================================================
    */

    function setValue(uint256 _value) external {

        (bool success, ) = implementation.delegatecall(
            abi.encodeWithSignature(
                "setValue(uint256)",
                _value
            )
        );

        require(success, "delegatecall failed");
    }

    function setOwner(address _owner) external {

        (bool success, ) = implementation.delegatecall(
            abi.encodeWithSignature(
                "setOwner(address)",
                _owner
            )
        );

        require(success, "delegatecall failed");
    }
}

/*
=========================================================
ATTACK / COLLISION RESULT
=========================================================

CALL:
setValue(100)

=========================================================

LogicV1 executes:

value = 100

BUT STORAGE ACTUALLY WRITES INTO PROXY:

slot0 → admin ❌ overwritten

=========================================================

CALL:
setOwner(attacker)

=========================================================

LogicV1 executes:

owner = attacker

BUT STORAGE WRITES INTO:

slot1 → implementation ❌ overwritten

=========================================================
FINAL BROKEN STATE IN PROXY
=========================================================

admin         = 100 (CORRUPTED)
implementation = attacker address (BROKEN)
value         = NOT stored correctly
owner         = attacker (misplaced slot)

=========================================================
💥 THIS IS STORAGE COLLISION
=========================================================

Logic assumes one layout
Proxy has another layout

→ delegatecall causes memory mismatch

=========================================================
WHY THIS IS CRITICAL
=========================================================

This leads to:

- admin takeover
- implementation hijack
- proxy corruption
- full protocol compromise

=========================================================
SECURE PATTERN (FIX IDEA)
=========================================================

Use consistent storage layout:

---------------------------------------------------------
Proxy:
slot0 = implementation
slot1 = admin
---------------------------------------------------------

OR use OpenZeppelin standard proxies:
- Transparent Proxy
- UUPS Proxy

=========================================================
SAFE PROXY EXAMPLE (CONCEPT ONLY)
=========================================================
*/

contract ProxySafeVul {

    // MUST MATCH expected layout carefully
    address public implementation;
    address public admin;

    constructor(address _impl) {
        implementation = _impl;
        admin = msg.sender;
    }

    function setValue(uint256 _value) external {
        (bool success, ) = implementation.delegatecall(
            abi.encodeWithSignature("setValue(uint256)", _value)
        );
        require(success);
    }
}

/*
=========================================================
KEY SECURITY INSIGHTS
=========================================================

- delegatecall shares storage with proxy
- storage slot order MUST match exactly
- mismatch = silent corruption (very dangerous)
- upgradeable contracts require strict layout control

=========================================================
AUDITOR CHECKLIST
=========================================================

✔ Does proxy and logic share identical storage layout?
✔ Are new variables appended safely?
✔ Is upgrade mechanism controlled?
✔ Is implementation address protected?
✔ Is storage collision possible via delegatecall?

=========================================================
REAL-WORLD IMPACT
=========================================================

Many DeFi hacks come from:

- broken upgradeable proxies
- storage slot mismatch
- unsafe delegatecall usage
- logic contract upgrades without layout checks

=========================================================
KEY TAKEAWAYS
=========================================================

- delegatecall = shared storage execution
- storage order matters more than logic
- mismatch causes silent corruption
- proxy patterns must be strictly standardized

=========================================================
*/
contract LogicV1 {

    // SLOT 0
    uint256 public value;

    // SLOT 1
    address public owner;

    function setValue(uint256 _value) external {
        value = _value;
    }

    function setOwner(address _owner) external {
        owner = _owner;
    }
}

contract ProxyMatching {

    // Must correspond to LogicV1's slots

    // SLOT 0
    uint256 public value;

    // SLOT 1
    address public owner;

    // SLOT 2
    address public implementation;

    constructor(address _impl) {
        implementation = _impl;
        owner = msg.sender;
    }

    function setValue(uint256 _value) external {
        (bool success, ) = implementation.delegatecall(
            abi.encodeWithSignature(
                "setValue(uint256)",
                _value
            )
        );

        require(success, "delegatecall failed");
    }

    function setOwner(address _owner) external {
        (bool success, ) = implementation.delegatecall(
            abi.encodeWithSignature(
                "setOwner(address)",
                _owner
            )
        );

        require(success, "delegatecall failed");
    }
}