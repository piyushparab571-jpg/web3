// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Vulnerable Reentrancy Bank
CONCEPT: Root reentrancy logic
=========================================================

WARNING:
This contract is INTENTIONALLY VULNERABLE.

DO NOT use in production.
=========================================================
*/

contract VulnerableBankVul {

    mapping(address => uint256) public balance;

    /*
    =====================================================
    DEPOSIT ETH
    =====================================================
    */

    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }

    /*
    =====================================================
    WITHDRAW ETH (VULNERABLE)
    =====================================================
    */

    function withdraw(uint256 amount) external {

        /*
        STEP 1:
        Check balance
        */
        require(balance[msg.sender] >= amount, "Not enough balance");

        /*
        STEP 2:
        EXTERNAL CALL FIRST ❌ (DANGER)
        */
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        /*
        STEP 3:
        STATE UPDATE AFTER CALL ❌ (ROOT ISSUE)
        */
        balance[msg.sender] -= amount;
    }

    /*
    =====================================================
    VIEW BALANCE
    =====================================================
    */

    function getBalance(address user)
        external
        view
        returns (uint256)
    {
        return balance[user];
    }
}


/*
Audit Report

Title: Reentrancy Vulnerability in withdraw()

Severity: Critical

Reason:
The contract performs an external call before updating internal state,
allowing a malicious contract to re-enter withdraw() multiple times and
drain funds.

Location:

Contract: VulnerableBankVul
Function: withdraw(uint256 amount)

Vulnerability Description:

The withdraw() function sends ETH to msg.sender using a low-level call
before reducing the user's recorded balance.

Because control is transferred to an external address before the balance
is updated, a malicious contract can execute a fallback() or receive()
function and call withdraw() again.

Since the balance has not yet been reduced, the balance check passes
repeatedly, allowing multiple withdrawals within the same transaction.

Impact:

An attacker can drain ETH from the contract beyond their legitimate balance.

Potential consequences include:

- theft of all ETH stored in the contract
- loss of user funds
- protocol insolvency
- complete contract compromise

Proof of Concept:
        1. Deploy VulnerableBankVul.
        2. User deposits ETH into the bank.
        3. Attacker deposits a small amount of ETH.
        4. Attacker calls withdraw().
        5. During the external call:

        msg.sender.call{value: amount}("");

        6. Attacker's fallback/receive function executes.
        7. Fallback calls withdraw() again.
        8. Balance check still succeeds because balance has not been reduced.
        9. Process repeats until contract funds are drained.

Root Cause:
The contract violates the Checks-Effects-Interactions (CEI) pattern.

Vulnerable code:
require(balance[msg.sender] >= amount, "Not enough balance");
(bool success, ) = msg.sender.call{value: amount}("");
require(success, "Transfer failed");
balance[msg.sender] -= amount;
State update occurs after the external interaction.

Recommendation:

Follow the Checks-Effects-Interactions pattern:
1. Check requirements
2. Update state
3. Perform external interaction

Additionally consider using a reentrancy guard.

Example:

balance[msg.sender] -= amount;
(bool success, ) = msg.sender.call{value: amount}("");
require(success, "Transfer failed");
*/


// patched code 
contract VulnerableBank {
    mapping (address=>uint256)public balance;
    //events
    event ETHDeposited(address indexed sender,uint256 amount);
    event ETHWithdrawn(address indexed sender,uint256 amount);
    //deposit 
    function deposit()external payable {
        require(msg.value>0,"amount should be greater then 0");
        balance[msg.sender]+=msg.value;
        emit ETHDeposited(msg.sender,msg.value);
    }
    //withdraw safe
    function withdraw(uint256 amount)external {
        //check balance
        require(balance[msg.sender]>=amount,"Not enough balance");
        //effects
        balance[msg.sender]-=amount;
        //interactions
        (bool success,)=msg.sender.call{value:amount}(""); 
        require(success,"Transfer Failed");
         emit ETHWithdrawn(msg.sender,amount);
    }
    // view balance
    function getBalance(address user)external view returns (uint256){
        return balance[user];
    }

}