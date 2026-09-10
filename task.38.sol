// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Fail require after state update
CONCEPT: Transaction atomicity
=========================================================

OBJECTIVE

- Learn Ethereum transaction atomicity
- Understand rollback after require() failure
- Observe temporary vs permanent state changes
- Learn why partial updates cannot persist

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

If require() fails:

EVERYTHING inside the transaction
is reverted.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Even if:
- storage updated
- balances changed
- counters incremented

A revert removes ALL changes.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Atomicity is a core EVM guarantee.

Without atomicity:
partial state corruption would occur.

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Atomicity protects:

- ERC20 transfers
- DeFi accounting
- lending protocols
- AMMs
- auctions
- governance systems

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- state updates before revert points
- external call ordering
- partial execution assumptions
- transaction rollback behavior
- CEI pattern compliance

=========================================================
*/
/*
contract TransactionAtomicityVul {

    /*
        STORAGE VARIABLES

        Persist only if transaction succeeds.
    
    uint256 public globalCounter;

    mapping(address => uint256) public balances;

    /*
    =====================================================
    FAIL REQUIRE AFTER STATE UPDATE
    =====================================================
    

    function brokenExecution(
        uint256 _amount
    )
        external
    {

        /*
            STEP 1:
            UPDATE GLOBAL COUNTER

            Temporary state update.
        
        globalCounter =
            globalCounter + _amount;

        /*
            STEP 2:
            UPDATE USER BALANCE

            Temporary state update.
        
        balances[msg.sender] =
            balances[msg.sender] + _amount;

        /*
            STEP 3:
            REQUIRE FAILURE

            If _amount > 5:
            transaction reverts completely.
        
        require(
            _amount <= 5,
            "Amount too large"
        );
    }

    /*
    =====================================================
    SAFE EXECUTION
    =====================================================

    Validation first.
    

    function safeExecution(
        uint256 _amount
    )
        external
    {

        /*
            VALIDATE BEFORE CHANGES
        
        require(
            _amount <= 5,
            "Amount too large"
        );

        /*
            UPDATE STATE AFTER VALIDATION
        
        globalCounter =
            globalCounter + _amount;

        balances[msg.sender] =
            balances[msg.sender] + _amount;
    }
}
*/
/*
=========================================================
INITIAL STATE
=========================================================

globalCounter = 0

balances[Alice] = 0

=========================================================
TRACE:
brokenExecution(3)
=========================================================

---------------------------------------------------------
STEP 1
---------------------------------------------------------

globalCounter =
0 + 3

TEMP VALUE:
3

---------------------------------------------------------
STEP 2
---------------------------------------------------------

balances[Alice] =
0 + 3

TEMP VALUE:
3

---------------------------------------------------------
STEP 3
---------------------------------------------------------

require(3 <= 5)

RESULT:
true

---------------------------------------------------------
TRANSACTION SUCCEEDS
---------------------------------------------------------

FINAL STATE:

globalCounter = 3

balances[Alice] = 3

=========================================================
TRACE:
brokenExecution(10)
=========================================================

---------------------------------------------------------
STEP 1
---------------------------------------------------------

globalCounter =
3 + 10

TEMP VALUE:
13

---------------------------------------------------------
STEP 2
---------------------------------------------------------

balances[Alice] =
3 + 10

TEMP VALUE:
13

---------------------------------------------------------
STEP 3
---------------------------------------------------------

require(10 <= 5)

RESULT:
false

---------------------------------------------------------
TRANSACTION REVERTS
---------------------------------------------------------

ALL STATE CHANGES UNDONE.

---------------------------------------------------------
FINAL STATE
---------------------------------------------------------

globalCounter = 3

balances[Alice] = 3

---------------------------------------------------------

IMPORTANT:
Temporary values disappear.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
brokenExecution(3)

---------------------------------------------------------

STEP 3:
Call:
globalCounter()

EXPECTED:
3

---------------------------------------------------------

STEP 4:
Call:
balances(your_address)

EXPECTED:
3

---------------------------------------------------------

STEP 5:
Call:
brokenExecution(10)

EXPECTED:
Transaction reverts

---------------------------------------------------------

STEP 6:
Call:
globalCounter()

EXPECTED:
Still 3

---------------------------------------------------------

STEP 7:
Call:
balances(your_address)

EXPECTED:
Still 3

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
- entire transaction succeeds

OR:
- entire transaction reverts

=========================================================
WHAT REVERT DOES
=========================================================

When require() fails:

EVM:
- undoes storage writes
- restores old state
- stops execution
- refunds remaining gas

=========================================================
TEMPORARY EXECUTION STATE
=========================================================

During execution:

Temporary storage updates exist internally.

---------------------------------------------------------

BUT:
They persist ONLY if transaction succeeds.

=========================================================
WHY VALIDATION-FIRST MATTERS
=========================================================

BEST PRACTICE:

1. CHECKS
2. EFFECTS
3. INTERACTIONS

---------------------------------------------------------

This is:
Checks-Effects-Interactions pattern.

=========================================================
BAD PATTERN
=========================================================

1. update storage
2. validate later

---------------------------------------------------------

Problems:
- wasted gas
- dangerous with external calls
- harder to audit

=========================================================
GAS OBSERVATION
=========================================================

Even reverted transactions:
consume gas.

---------------------------------------------------------

Reason:
Computation already executed.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. TRACE EXECUTION ORDER
---------------------------------------------------------

Auditors inspect:
what changes BEFORE revert points.

---------------------------------------------------------
2. PARTIAL STATE ASSUMPTIONS
---------------------------------------------------------

Partial updates cannot survive revert.

---------------------------------------------------------
3. EXTERNAL CALL DANGER
---------------------------------------------------------

External interactions before revert
may create reentrancy risks.

---------------------------------------------------------
4. CEI PATTERN
---------------------------------------------------------

Checks -> Effects -> Interactions
improves security.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker repeatedly triggers:
expensive computation + revert.

Result:
gas griefing DOS.

---------------------------------------------------------

ANOTHER RISK

Improper external-call ordering
before revert may expose vulnerabilities.

=========================================================
REAL AUDITOR QUESTIONS
=========================================================

Auditors ask:

- What happens before require()?
- Can external calls occur first?
- What reverts?
- What persists?
- Is rollback behavior understood?

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add external token transfer logic
2. Trigger revert after external call
3. Observe rollback behavior carefully

BONUS:
Implement proper CEI ordering.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Ethereum transactions are atomic
- require() failure reverts all state changes
- Temporary updates disappear after revert
- Storage persists only on success
- Validation-first is preferred
- Reverted transactions still consume gas
- CEI pattern improves security
- Execution order matters heavily
- Auditors trace rollback behavior carefully
- Partial state corruption is prevented by EVM atomicity

=========================================================
*/

/*
Audit Report

Title: State Updates Performed Before Validation in brokenExecution()

Severity: Medium

Reason:
The brokenExecution() function updates storage
before performing validation checks.

Although Ethereum transaction atomicity
reverts all state changes on failure,
gas is still consumed performing unnecessary
storage writes and computation.

This pattern also becomes dangerous
if external calls are introduced before validation.

Location:

Contract: TransactionAtomicityVul
Function: brokenExecution()

Vulnerability Description:

The brokenExecution() function performs:

1. storage updates
2. validation afterwards

Code:

globalCounter =
    globalCounter + _amount;

balances[msg.sender] =
    balances[msg.sender] + _amount;

require(
    _amount <= 5,
    "Amount too large"
);

If _amount exceeds 5,
the require() statement fails.

Although all state changes are reverted,
the contract already consumed gas executing:

- arithmetic operations
- storage writes
- execution logic

This violates the recommended:

Checks -> Effects -> Interactions (CEI)

security pattern.

Impact:

An attacker may repeatedly trigger
reverted execution using large values.

This causes:

- unnecessary gas consumption
- wasted computation
- inefficient execution flow
- potential gas griefing behavior

Additionally, if external calls existed
before validation,
more severe vulnerabilities could occur:

- reentrancy
- inconsistent external state
- unsafe execution ordering

Proof of Concept:
        1.Deploy the contract.

        2.Initial State:
        globalCounter = 0
        balances[Alice] = 0

        3.Alice calls:
        brokenExecution(3)
        Execution succeeds.

        4.New State:
        globalCounter = 3
        balances[Alice] = 3

        5.Alice now calls:
        brokenExecution(10)

            STEP 1: globalCounter = 3 + 10
                                = 13
                Temporary value:
                        13

            STEP 2: balances[Alice] = 3 + 10
                                    = 13

                Temporary value:
                        13

            STEP 3: Validation executes:
                        require(10 <= 5)

                    RESULT:
                        false

        Transaction reverts.

        6.Final State:
            globalCounter = 3
            balances[Alice] = 3

        7.Observe:
            - temporary storage updates occurred
            - all state changes reverted
            - gas was still consumed
            - no permanent corruption occurred

Root Cause:

The function performs state updates
before validation checks.

Execution order is:

1. Effects
2. Validation

instead of:

1. Checks
2. Effects

Recommendation:

    Perform validation BEFORE modifying storage.

Use the CEI pattern:
    1. Checks
    2. Effects
    3. Interactions

Example:
    require( _amount <= 5,"Amount too large");

globalCounter = globalCounter + _amount;

balances[msg.sender] = balances[msg.sender] + _amount;
*/

// patched code
/*
contract SimpleContract{
    mapping (address=>uint256) public balances;
    //adds tokens to any address
    function mint(address _to,uint256 _amt)external  {
        balances[_to]=balances[_to]+_amt;
    }
}

contract TransactionAtomicity {
    
    SimpleContract public token;

    mapping (address=>uint256) public balances;

    constructor(address _token){
        token=SimpleContract(_token);
    }
     /*
    =====================================================
    BAD VERSION
    =====================================================

    External call BEFORE validation.
    
    function badExecution(uint256 _amt) external {
        balances[msg.sender]+=_amt;
        /*
            EXTERNAL CALL
        
        token.mint(msg.sender,_amt);
        /*
            LATE VALIDATION

            If this fails:
            ENTIRE TRANSACTION REVERTS.
        
        require(_amt <= 5,"Amount too large");
    }

     /*
    =====================================================
    SAFE VERSION
    =====================================================

    CHECKS -> EFFECTS -> INTERACTIONS
    

     function safeExecution(uint256 _amount)external {   /*
            CHECKS
        
        require(_amount <= 5,"Amount too large");

        /*
            EFFECTS
        
        balances[msg.sender] += _amount;

        /*
            INTERACTIONS
        
        token.mint(msg.sender, _amount);
    }
}
*/
contract MockToken {

    mapping(address => uint256) public balances;

    /*
        Give tokens to an address.
    */
    function mint(
        address _to,
        uint256 _amount
    )
        external
    {
        balances[_to] += _amount;
    }

    /*
        External token transfer.
    */
    function transfer(
        address _to,
        uint256 _amount
    )
        external
        returns (bool)
    {
        require(
            balances[msg.sender] >= _amount,
            "Insufficient token balance"
        );

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;

        return true;
    }
}


/*
=====================================================
TRANSACTION ATOMICITY CONTRACT
=====================================================
*/

contract TransactionAtomicityVul {

    /*
        STORAGE VARIABLES
    */
    uint256 public globalCounter;

    mapping(address => uint256) public balances;

    /*
        TOKEN CONTRACT
    */
    MockToken public token;


    /*
        Store the token contract address.
    */
    constructor(address _token) {
        token = MockToken(_token);
    }


    /*
    =====================================================
    BROKEN EXECUTION
    =====================================================

    State update
        ↓
    External token transfer
        ↓
    Revert

    The entire transaction is rolled back.
    */

    function brokenExecution(
        address _receiver,
        uint256 _amount
    )
        external
    {
        /*
            STEP 1:
            Update contract state.
        */
        globalCounter += _amount;

        balances[msg.sender] += _amount;


        /*
            STEP 2:
            EXTERNAL TOKEN TRANSFER

            This calls another contract.
        */
        bool success = token.transfer(
            _receiver,
            _amount
        );

        require(
            success,
            "Token transfer failed"
        );


        /*
            STEP 3:
            INTENTIONAL REVERT

            Everything done in this transaction
            is reverted.
        */
        revert(
            "Intentional failure after transfer"
        );
    }


    /*
    =====================================================
    SAFE CEI EXECUTION
    =====================================================

    CHECKS
        ↓
    EFFECTS
        ↓
    INTERACTIONS
    */

    function safeExecution(
        address _receiver,
        uint256 _amount
    )
        external
    {
        /*
            =========================
            CHECKS
            =========================
        */

        require(
            _receiver != address(0),
            "Invalid receiver"
        );

        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );


        /*
            =========================
            EFFECTS
            =========================

            Update internal state BEFORE
            making the external call.
        */

        balances[msg.sender] -= _amount;

        globalCounter -= _amount;


        /*
            =========================
            INTERACTION
            =========================

            External token transfer is
            performed LAST.
        */

        bool success = token.transfer(
            _receiver,
            _amount
        );

        require(
            success,
            "Token transfer failed"
        );
    }
}
