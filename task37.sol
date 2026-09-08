// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Update state before require
CONCEPT: State rollback behavior
=========================================================

OBJECTIVE

- Learn what happens when require() fails
- Understand transaction rollback behavior
- Learn EVM atomicity guarantees
- Understand why reverted state changes disappear

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

If require() fails:

ALL state changes in the transaction
are reverted automatically.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Even if storage was updated BEFORE require():

A revert undoes everything.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

This is one of the MOST IMPORTANT
EVM security guarantees.

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Rollback behavior protects:

- balances
- token transfers
- DeFi accounting
- governance state
- auction logic

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- execution order
- state updates before external calls
- revert handling
- atomicity assumptions
- partial-update risks

=========================================================
*/
/*
contract StateRollbackBehaviorVul {

    /*
        STORAGE VARIABLES

        Persist permanently unless reverted.
    
    uint256 public totalCounter;

    mapping(address => uint256) public userCounter;

    /*
    =====================================================
    UPDATE STATE BEFORE REQUIRE
    ===================================================
    

    function riskyIncrement(
        uint256 _value
    )
        external
    {

        /*
            STEP 1:
            UPDATE STORAGE

            State changes happen immediately
            during execution.
        
        totalCounter =
            totalCounter + _value;

        userCounter[msg.sender] =
            userCounter[msg.sender] + _value;

        /*
            STEP 2:
            REQUIRE CHECK

            If this fails:
            ALL earlier storage changes revert.
        
        require(
            _value <= 10,
            "Value too large"
        );
    }

    /*
    =====================================================
    SAFE VERSION
    =====================================================

    Validation first.
    

    function safeIncrement(
        uint256 _value
    )
        external
    {

        /*
            VALIDATE FIRST
        
        require(
            _value <= 10,
            "Value too large"
        );

        /*
            UPDATE STATE AFTER VALIDATION
        
        totalCounter =
            totalCounter + _value;

        userCounter[msg.sender] =
            userCounter[msg.sender] + _value;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

INITIAL STATE

totalCounter = 0

userCounter[Alice] = 0

=========================================================
TRACE:
riskyIncrement(5)
=========================================================

---------------------------------------------------------
STEP 1
---------------------------------------------------------

totalCounter =
0 + 5

NEW VALUE:
5

---------------------------------------------------------
STEP 2
---------------------------------------------------------

userCounter[Alice] =
0 + 5

NEW VALUE:
5

---------------------------------------------------------
STEP 3
---------------------------------------------------------

require(5 <= 10)

RESULT:
true

---------------------------------------------------------
FINAL STATE
---------------------------------------------------------

totalCounter = 5

userCounter[Alice] = 5

=========================================================
TRACE:
riskyIncrement(50)
=========================================================

---------------------------------------------------------
STEP 1
---------------------------------------------------------

totalCounter =
5 + 50

TEMP VALUE:
55

---------------------------------------------------------
STEP 2
---------------------------------------------------------

userCounter[Alice] =
5 + 50

TEMP VALUE:
55

---------------------------------------------------------
STEP 3
---------------------------------------------------------

require(50 <= 10)

RESULT:
false

---------------------------------------------------------
TRANSACTION REVERTS
---------------------------------------------------------

ALL STATE CHANGES UNDONE.

---------------------------------------------------------
FINAL STATE
---------------------------------------------------------

totalCounter = 5

userCounter[Alice] = 5

---------------------------------------------------------

IMPORTANT:
Temporary updates disappear.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
riskyIncrement(5)

---------------------------------------------------------

STEP 3:
Call:
totalCounter()

EXPECTED:
5

---------------------------------------------------------

STEP 4:
Call:
riskyIncrement(50)

EXPECTED:
Transaction reverts

---------------------------------------------------------

STEP 5:
Call:
totalCounter()

EXPECTED:
Still 5

---------------------------------------------------------

STEP 6:
Call:
userCounter(your_address)

EXPECTED:
Still 5

---------------------------------------------------------

OBSERVE:
Failed transaction changed NOTHING.

=========================================================
IMPORTANT EVM UNDERSTANDING
=========================================================

ETHEREUM TRANSACTIONS ARE:

ATOMIC

---------------------------------------------------------

Meaning:

Either:
- EVERYTHING succeeds

OR:
- EVERYTHING reverts

=========================================================
ROLLBACK MECHANISM
=========================================================

When require() fails:

EVM:
- discards storage writes
- discards state changes
- refunds remaining gas
- reverts execution

=========================================================
VERY IMPORTANT SECURITY CONCEPT
=========================================================

TEMPORARY STORAGE CHANGES
can exist DURING execution.

---------------------------------------------------------

BUT:
they disappear after revert.

=========================================================
WHY VALIDATION-FIRST IS BETTER
=========================================================

THIS IS PREFERRED:

1. validate
2. update state

---------------------------------------------------------

Reason:
Avoid wasted computation/gas.

=========================================================
BAD PATTERN
=========================================================

1. update storage
2. validate later

---------------------------------------------------------

Problem:
Wasted gas if revert occurs.

=========================================================
GAS OBSERVATION
=========================================================

REVERTS:
Undo state changes

---------------------------------------------------------

BUT:
Gas already consumed is NOT fully refunded.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. VALIDATE BEFORE STATE CHANGES
---------------------------------------------------------

Auditors prefer:
Checks -> Effects -> Interactions

---------------------------------------------------------
2. UNDERSTAND ATOMICITY
---------------------------------------------------------

Partial state updates cannot persist
after revert.

---------------------------------------------------------
3. EXTERNAL CALL RISKS
---------------------------------------------------------

If external calls happen before revert,
complex behaviors may occur.

---------------------------------------------------------
4. GAS WASTAGE
---------------------------------------------------------

Late validation wastes gas.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker intentionally triggers reverts
after expensive computation.

Result:
Gas griefing / DOS potential.

---------------------------------------------------------

ANOTHER RISK

Incorrect assumptions about rollback
may create accounting vulnerabilities.

=========================================================
REAL AUDITOR PATTERN
=========================================================

AUDITORS TRACE:

1. What changes first?
2. What can revert?
3. Are external calls involved?
4. Can partial execution leak effects?
5. Is CEI pattern followed?

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add withdraw() function
2. Update balance before require()
3. Observe rollback manually
4. Then rewrite using:
Checks -> Effects -> Interactions

BONUS:
Add custom errors instead of require strings.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Ethereum transactions are atomic
- require() failure reverts all state changes
- Storage updates disappear after revert
- Temporary execution state exists internally
- Validation-first is preferred
- Late validation wastes gas
- Reverts undo storage writes
- CEI pattern improves security
- Auditors trace rollback behavior carefully
- State persistence only happens on success

=========================================================
*/

/*
Audit Report

Title: State Update Before Validation in riskyIncrement()

Severity: Low

Reason:
The riskyIncrement() function updates storage variables
before validating user input.

Although failed transactions revert state changes,
gas is still consumed performing unnecessary
storage writes before rollback occurs.

Location:

Contract: StateRollbackBehaviorVul
Function: riskyIncrement()

Vulnerability Description:

The riskyIncrement() function performs
storage updates before validation checks.

Code:

totalCounter =
    totalCounter + _value;

userCounter[msg.sender] =
    userCounter[msg.sender] + _value;

require(
    _value <= 10,
    "Value too large"
);

If _value exceeds 10,
the transaction reverts.

Although state changes are rolled back,
gas is already consumed for:

- storage writes
- arithmetic operations
- execution steps

This violates the recommended:

Checks -> Effects -> Interactions (CEI)

pattern.

Impact:

An attacker may intentionally trigger
transaction reverts using large values.

This causes:

- unnecessary gas consumption
- wasted computation
- inefficient execution flow
- possible gas griefing behavior

No permanent state corruption occurs
because Ethereum transactions are atomic.

Proof of Concept:
    1.Deploy the contract.

    2.Initial State:
    totalCounter = 20
    userCounter[Alice] = 20

    3.Alice calls:
    riskyIncrement(50)

    4.Temporary execution state becomes:
    totalCounter = 70
    userCounter[Alice] = 70

    5.Validation executes:
    require(50 <= 10)
    RESULT:
    false

    6.Transaction reverts.
    Final State:
    totalCounter = 20
    userCounter[Alice] = 20

    7.Observe:

    - storage updates executed temporarily
    - transaction reverted successfully
    - gas was still consumed

Root Cause:

The function performs state updates
before validation checks.

Execution order:

    1. Effects
    2. Validation

instead of:

    1. Validation
    2. Effects

Recommendation:

Validate user input BEFORE modifying storage.

Example:

    require(
        _value <= 10,
        "Value too large"
    );

    totalCounter =
        totalCounter + _value;

    userCounter[msg.sender] =
        userCounter[msg.sender] + _value;
*/
//patched code 
/*
contract StateRollbackChallenge {
    // CUSTOM ERRORS
    error InvalidAmount();
    error InsufficientBalance();
  
    uint256 public totalBalance;

    mapping(address => uint256) public balances;

    function deposit(uint256 _amount)external{
        if (_amount == 0) {
            revert InvalidAmount();
        }

        balances[msg.sender] += _amount;

        totalBalance += _amount;
    }

    /*
    =====================================================
    BAD WITHDRAW
    =====================================================

    PURPOSE:
    Demonstrate rollback behavior.

    BAD PATTERN:
    State updated BEFORE validation.
    

    function riskyWithdraw(uint256 _amount)external{
        /*
            STEP 1:
            UPDATE STATE FIRST
        
        balances[msg.sender] -= _amount;

        totalBalance -= _amount;

        /*
            STEP 2:
            VALIDATE LATER

            If this fails:
            ALL previous storage updates revert.
        
        if (_amount > 100) {
            revert InvalidAmount();
        }
    }

    /*
    =====================================================
    SAFE WITHDRAW
    =====================================================

    CEI PATTERN

    Checks
    Effects
    Interactions
    

    function safeWithdraw(uint256 _amount)external{
        /*
        =================================================
        CHECKS
        =================================================
        
        if (_amount == 0) {
            revert InvalidAmount();
        }

        if (
            balances[msg.sender] < _amount
        ) {
            revert InsufficientBalance();
        }

        if (_amount > 100) {
            revert InvalidAmount();
        }

        /*
        =================================================
        EFFECTS
        =================================================
        

        balances[msg.sender] -= _amount;

        totalBalance -= _amount;

        /*
        =================================================
        INTERACTIONS
        =================================================

        No external calls here,
        but this is where they would go.
        
    }
}
*/
contract StateRollbackBehaviorVul {

    /*
        STORAGE VARIABLES
    */
    uint256 public totalCounter;

    mapping(address => uint256) public userCounter;

    /*
    =====================================================
    RISKY WITHDRAW
    =====================================================

    Intentionally updates state BEFORE require().
    If require fails, the state changes are rolled back.
    */

    function withdrawRisky(
        uint256 _amount
    )
        external
    {
        /*
            STEP 1:
            Update balance BEFORE validation.
        */
        userCounter[msg.sender] =
            userCounter[msg.sender] - _amount;

        /*
            STEP 2:
            Update total counter.
        */
        totalCounter =
            totalCounter - _amount;

        /*
            STEP 3:
            Validation happens AFTER state update.

            If this fails, ALL previous changes
            in this transaction are reverted.
        */
        require(
            _amount <= 10,
            "Amount too large"
        );
    }

    /*
    =====================================================
    SAFE WITHDRAW
    =====================================================

    CHECKS -> EFFECTS
    */

    function withdrawSafe(
        uint256 _amount
    )
        external
    {
        /*
            CHECKS

            Validate first.
        */
        require(
            _amount <= 10,
            "Amount too large"
        );

        /*
            EFFECTS

            Update storage only after
            validation succeeds.
        */
        userCounter[msg.sender] =
            userCounter[msg.sender] - _amount;

        totalCounter =
            totalCounter - _amount;
    }
}