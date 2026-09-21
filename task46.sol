// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Trigger revert manually
CONCEPT: Full rollback
=========================================================

OBJECTIVE

- Learn how revert() works
- Understand manual transaction rollback
- Learn EVM atomicity behavior
- Understand state restoration after revert

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

revert() immediately:
- stops execution
- undoes ALL state changes
- returns remaining gas

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Even if storage was modified BEFORE revert():

ALL changes are undone.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Manual revert is critical for:

- validation
- invariant enforcement
- protocol safety
- emergency protection

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

revert() used in:

- DeFi protocols
- ERC20 tokens
- staking systems
- governance logic
- liquidation engines
- vault protections

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- revert conditions
- rollback guarantees
- partial execution risks
- state consistency
- revert message clarity

=========================================================
*/
/*
contract ManualRevertExampleVul {
    /*
        STORAGE VARIABLES
    
    uint256 public totalCounter;

    mapping(address => uint256) public balances;

    /*
    =====================================================
    MANUAL REVERT EXAMPLE
    =====================================================
    

    function dangerousDeposit(
        uint256 _amount
    )
        external
    {
        /*
            STEP 1:
            Update storage.

            TEMPORARY until transaction succeeds.
        
        balances[msg.sender] += _amount;
        totalCounter += _amount;

        /*
            STEP 2:
            Manual revert condition.
        
        if (_amount > 10) {

            /*
                MANUAL REVERT

                ALL earlier state changes rollback.
            
            revert("Amount exceeds limit");
        }

        /*
            If execution reaches here:
            transaction succeeds.
        
    }

    /*
    =====================================================
    CONDITIONAL REVERT EXAMPLE
    =====================================================
    

    function onlyEven(
        uint256 _number
    )
        external
        pure
        returns (string memory)
    {

        /*
            Reject odd numbers.
        
        if (_number % 2 != 0) {

            revert("Odd number rejected");
        }

        return "Even number accepted";
    }

    /*
    =====================================================
    REVERT WITHOUT MESSAGE
    =====================================================
    
    function silentRevert(
        bool _shouldFail
    )
        external
        pure
    {

        if (_shouldFail) {

            /*
                Revert without reason string.
            
            revert();
        }
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

INITIAL STATE

balances[Alice] = 0

totalCounter = 0

=========================================================
TRACE:
dangerousDeposit(5)
=========================================================

---------------------------------------------------------
STEP 1
---------------------------------------------------------

balances[Alice] += 5

TEMP VALUE:
5

---------------------------------------------------------

totalCounter += 5

TEMP VALUE:
5

---------------------------------------------------------
STEP 2
---------------------------------------------------------

if (_amount > 10)

CHECK:
5 > 10

RESULT:
false

---------------------------------------------------------

NO REVERT OCCURS

---------------------------------------------------------

TRANSACTION SUCCEEDS

---------------------------------------------------------

FINAL STATE:

balances[Alice] = 5

totalCounter = 5

=========================================================
REVERT TRACE
=========================================================

CALL:
dangerousDeposit(50)

=========================================================

---------------------------------------------------------
STEP 1
---------------------------------------------------------

balances[Alice] += 50

TEMP VALUE:
55

---------------------------------------------------------

totalCounter += 50

TEMP VALUE:
55

---------------------------------------------------------
STEP 2
---------------------------------------------------------

CHECK:
50 > 10

RESULT:
true

---------------------------------------------------------

revert("Amount exceeds limit")

---------------------------------------------------------

TRANSACTION STOPS IMMEDIATELY

---------------------------------------------------------

ALL STATE CHANGES ROLLBACK

---------------------------------------------------------

FINAL STATE:

balances[Alice] = 5

totalCounter = 5

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
dangerousDeposit(5)

---------------------------------------------------------

STEP 3:
Call:
balances(your_address)

EXPECTED:
5

---------------------------------------------------------

STEP 4:
Call:
dangerousDeposit(50)

EXPECTED:
Revert

---------------------------------------------------------

STEP 5:
Call:
balances(your_address)

EXPECTED:
Still 5

---------------------------------------------------------

STEP 6:
Call:
totalCounter()

EXPECTED:
Still 5

---------------------------------------------------------

OBSERVE:
Failed transaction changed NOTHING.

---------------------------------------------------------

STEP 7:
Call:
onlyEven(4)

EXPECTED:
"Even number accepted"

---------------------------------------------------------

STEP 8:
Call:
onlyEven(5)

EXPECTED:
Revert

=========================================================
IMPORTANT REVERT UNDERSTANDING
=========================================================

revert() immediately:

- stops execution
- undoes state changes
- restores previous state

=========================================================
EVM ATOMICITY
=========================================================

Ethereum transactions are:

ATOMIC

---------------------------------------------------------

Meaning:

Either:
- everything succeeds

OR:
- everything reverts

=========================================================
REVERT VS RETURN
=========================================================

---------------------------------------------------------
RETURN
---------------------------------------------------------

- stops execution
- keeps state changes

---------------------------------------------------------
REVERT
---------------------------------------------------------

- stops execution
- undoes state changes

=========================================================
REVERT VS REQUIRE
=========================================================

require(condition, "msg")

is internally similar to:

if (!condition) {
    revert("msg");
}

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. MISSING REVERTS
---------------------------------------------------------

Invalid state may persist.

---------------------------------------------------------
2. LATE REVERTS
---------------------------------------------------------

Gas wasted after expensive computation.

---------------------------------------------------------
3. EXTERNAL CALL BEFORE REVERT
---------------------------------------------------------

Dangerous execution ordering.

---------------------------------------------------------
4. UNCLEAR ERROR REASONS
---------------------------------------------------------

Poor debugging visibility.

=========================================================
GAS OBSERVATION
=========================================================

revert():
refunds REMAINING gas only.

---------------------------------------------------------

Gas already consumed:
is NOT recovered.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- What conditions trigger revert?
- Does rollback fully restore state?
- Can partial execution escape?
- Are invariants protected?
- Are revert reasons meaningful?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker intentionally triggers:
expensive computation + revert.

Result:
gas griefing DOS.

---------------------------------------------------------

ANOTHER RISK

Improper external-call ordering
before revert may expose vulnerabilities.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. State before revert
2. State after revert
3. Execution ordering
4. External interactions
5. Rollback guarantees

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add withdraw() function
2. Revert on insufficient balance
3. Add custom errors
4. Compare gas with require()

BONUS:
Implement invariant check:
that reverts on corruption.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- revert() manually stops execution
- revert() undoes all state changes
- Ethereum transactions are atomic
- Temporary storage updates disappear after revert
- revert() and require() are closely related
- return() and revert() behave differently
- Reverted transactions still consume gas
- Execution order matters heavily
- Auditors verify rollback guarantees
- Full rollback is critical for protocol safety

=========================================================
*/

/*
=========================================================
AUDIT REPORT
=========================================================

Title: Missing Balance Update Validation in dangerousDeposit()

Severity: Medium

Reason:
The function modifies state before validation,
causing unnecessary state changes prior to revert.

---------------------------------------------------------
Location
---------------------------------------------------------

Contract: ManualRevertExampleVul
Function: dangerousDeposit(uint256 _amount)

---------------------------------------------------------
Vulnerability Description
---------------------------------------------------------

The dangerousDeposit() function updates contract state
BEFORE performing validation:

balances[msg.sender] += _amount;
totalCounter += _amount;

Only after state modification, a condition checks:

if (_amount > 10) {
    revert("Amount exceeds limit");
}

This results in unnecessary state mutation prior to revert logic.

Although Solidity correctly rolls back state on revert,
this pattern is considered unsafe from an auditing perspective
because:

- state is modified before validation
- logic is not fail-fast
- high-cost operations may execute before revert
- future modifications could introduce side effects

---------------------------------------------------------
Impact
---------------------------------------------------------

Direct Impact:
- No permanent state corruption (due to EVM atomicity)

Indirect Risk:
- Gas wastage due to early state updates
- Increased risk if external calls are added later
- Higher chance of introducing future vulnerabilities
- Poor code hygiene and unsafe execution ordering

If expanded with external calls, this pattern may lead to:

- reentrancy vulnerabilities
- inconsistent intermediate state exposure
- execution ordering bugs

---------------------------------------------------------
Proof of Concept
        STEP 1:
        Call dangerousDeposit(5)

        STATE UPDATE:
        balances[msg.sender] = 5
        totalCounter = 5

        RESULT:
        Transaction succeeds

        STEP 2:
        Call dangerousDeposit(50)

        STATE UPDATE (temporary):
        balances[msg.sender] = 55
        totalCounter = 55

        CHECK FAILS:
        50 > 10

        RESULT:
        revert("Amount exceeds limit")


        STEP 3:
        Final State After Revert:

        balances[msg.sender] = unchanged
        totalCounter = unchanged

---------------------------------------------------------

Root Cause:
State updates are performed before validation checks.

---------------------------------------------------------
Recommendation

Follow "checks-effects-interactions" pattern:

1. Validate input first
2. Then update state
3. Avoid unnecessary pre-validation mutations

Improved pattern:

if (_amount > 10) revert("Amount exceeds limit");

balances[msg.sender] += _amount;
totalCounter += _amount;
*/
/*
//patched code 
contract ManualRevertExample{
    /*
        STORAGE VARIABLES
    
    uint256 public totalCounter;

    mapping(address => uint256) public balances;

    error InsufficientBalance(uint256 available,uint256 required);

    /*
    =====================================================
    MANUAL REVERT EXAMPLE
    =====================================================
    

    function dangerousDeposit(
        uint256 _amount
    )
        external
    {

          if (_amount > 10) {

            /*
                MANUAL REVERT

                ALL earlier state changes rollback.
            
            revert("Amount exceeds limit");
        }
        /*
            STEP 1:
            Update storage.

            TEMPORARY until transaction succeeds.
        
        balances[msg.sender] += _amount;
        totalCounter += _amount;
    }

    /*
    =====================================================
    CONDITIONAL REVERT EXAMPLE
    =====================================================
    

    function onlyEven(
        uint256 _number
    )
        external
        pure
        returns (string memory)
    {

        /*
            Reject odd numbers.
        
        if (_number % 2 != 0) {

            revert("Odd number rejected");
        }

        return "Even number accepted";
    }

    /*
    =====================================================
    REVERT WITHOUT MESSAGE
    =====================================================
    

    function silentRevert(
        bool _shouldFail
    )
        external
        pure
    {

        if (_shouldFail) {

            /*
                Revert without reason string.
            
            revert();
        }
    }

    function withdraw(uint256 amount)external  {
    if (balances[msg.sender] < amount) {
        revert InsufficientBalance(balances[msg.sender],amount);
    }
      uint256 before = balances[msg.sender];
        balances[msg.sender] -= amount;
    // invariant check: 
    //After withdrawal, the balance MUST exactly match what we expect
    assert(balances[msg.sender] == before - amount);
    }
}
*/

contract ManualRevertExampleVul {

    uint256 public totalCounter;
    mapping(address => uint256) public balances;

    // Custom errors
    error InsufficientBalance();
    error AmountExceedsLimit();
    error OddNumber();
    error InvariantBroken();

    // Deposit with manual revert
    function dangerousDeposit(uint256 _amount) external {

        balances[msg.sender] += _amount;
        totalCounter += _amount;

        if (_amount > 10) {
            revert AmountExceedsLimit();
        }

        _checkInvariant();
    }

    // Withdraw using custom error
    function withdraw(uint256 _amount) external {

        if (balances[msg.sender] < _amount) {
            revert InsufficientBalance();
        }

        balances[msg.sender] -= _amount;
        totalCounter -= _amount;

        _checkInvariant();
    }

    // Withdraw using require()
    function withdrawUsingRequire(uint256 _amount) external {

        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        balances[msg.sender] -= _amount;
        totalCounter -= _amount;
    }

    // Accept only even numbers
    function onlyEven(uint256 _number)
        external
        pure
        returns (string memory)
    {
        if (_number % 2 != 0) {
            revert OddNumber();
        }

        return "Even number accepted";
    }

    // Revert without message
    function silentRevert(bool _fail) external pure {
        if (_fail) {
            revert();
        }
    }

    // Invariant check
    function _checkInvariant() internal view {

        if (totalCounter < 0) {
            revert InvariantBroken();
        }
    }
}