// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Create local uint variable
CONCEPT: Temporary execution memory
=========================================================

OBJECTIVE

- Learn how local variables work in Solidity
- Understand temporary execution memory
- Learn difference between local variables and storage
- Understand variable lifetime during execution

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Local variables exist ONLY during
function execution.

After function completes:
local variables disappear.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Local variables are NOT stored permanently
on blockchain storage.

They usually live in:
- stack
- memory

---------------------------------------------------------
STATE VARIABLE VS LOCAL VARIABLE
---------------------------------------------------------

STATE VARIABLE:
- stored permanently
- lives in storage
- persists across transactions

LOCAL VARIABLE:
- temporary
- exists only during execution
- disappears after function ends

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Local variables are used for:

- calculations
- temporary values
- loop counters
- intermediate logic
- gas optimization

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Is temporary data handled correctly?
- Is storage used unnecessarily?
- Are local variables initialized?
- Can uninitialized variables cause bugs?
- Is memory usage efficient?

=========================================================
*/
/*
contract LocalUintVariableVul {

    uint256 public storedValue;

    function calculateSum(uint256 _a, uint256 _b)
        public
        pure
        returns (uint256)
    {

        /*
            LOCAL VARIABLE

            sum exists ONLY during execution.

            It is NOT stored permanently
            on blockchain storage.
        
        uint256 sum = _a + _b;

        return sum;
    }

    function storeCalculatedValue(
        uint256 _x,
        uint256 _y
    ) public {

        /*
            TEMPORARY LOCAL VARIABLE

            Used for intermediate computation.
        
        uint256 result = _x + _y;

        /*
            STORAGE WRITE

            Only this line modifies blockchain state.
        
        storedValue = result;
    }

    function demonstrateLocalVariable()
        public
        pure
        returns (uint256)
    {

        /*
            Local variable created
        
        uint256 temp = 100;

        /*
            temp exists only during this function call
        
        temp = temp + 50;

        return temp;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
calculateSum(10, 20)

EVM ACTIONS:

1. _a and _b arrive through calldata
2. Local variable sum created
3. Addition performed
4. sum temporarily stores result
5. Result returned
6. sum destroyed after execution

---------------------------------------------------------

IMPORTANT

sum does NOT persist on blockchain.

---------------------------------------------------------

CALL:
storeCalculatedValue(5, 7)

EVM ACTIONS:

1. Local variable result created
2. result = 12
3. storedValue updated in storage
4. result destroyed after execution
5. storedValue persists permanently

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
calculateSum(10,20)

EXPECTED:
30

---------------------------------------------------------

STEP 3:
Call:
storedValue()

EXPECTED:
0

OBSERVE:
calculateSum did NOT modify storage.

---------------------------------------------------------

STEP 4:
Call:
storeCalculatedValue(5,7)

---------------------------------------------------------

STEP 5:
Call:
storedValue()

EXPECTED:
12

---------------------------------------------------------

STEP 6:
Call:
demonstrateLocalVariable()

EXPECTED:
150

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Use zero values

calculateSum(0,0)

EXPECTED:
0

---------------------------------------------------------

TEST:
Use large uint256 values

EXPECTED:
Solidity ^0.8.x prevents overflow

---------------------------------------------------------

TEST:
Call functions repeatedly

OBSERVE:
Local variables recreated every execution.

=========================================================
IMPORTANT MEMORY UNDERSTANDING
=========================================================

LOCAL VARIABLES ARE TEMPORARY

They exist only during:
single function execution.

---------------------------------------------------------

AFTER FUNCTION ENDS

Local variables are destroyed.

---------------------------------------------------------

VERY IMPORTANT

This does NOT persist:

uint256 temp = 100;

---------------------------------------------------------

THIS PERSISTS:

storedValue = 100;

because storage is modified.

=========================================================
STACK VS STORAGE
=========================================================

LOCAL UINT VARIABLES

Usually stored in:
EVM stack

---------------------------------------------------------

STATE VARIABLES

Stored in:
blockchain storage

---------------------------------------------------------

STACK:
- temporary
- cheap
- fast

STORAGE:
- permanent
- expensive
- persistent

=========================================================
GAS OBSERVATION
=========================================================

LOCAL VARIABLES:
Cheap
    515 gas
---------------------------------------------------------

STORAGE WRITES:
Expensive
	24325 gas
---------------------------------------------------------

Reason:
Storage modifies blockchain state permanently.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. UNINITIALIZED VARIABLES
---------------------------------------------------------

Auditors verify:
all local variables initialized properly.

---------------------------------------------------------
2. STORAGE MISUSE
---------------------------------------------------------

Developers sometimes use storage
when temporary variable sufficient.

This wastes gas.

---------------------------------------------------------
3. OVERFLOW RISKS
---------------------------------------------------------

Math on local variables still matters.

Solidity ^0.8.x checks overflow automatically.

---------------------------------------------------------
4. TEMPORARY LOGIC VALIDATION
---------------------------------------------------------

Auditors inspect:
- intermediate calculations
- temporary computation correctness
- execution flow consistency

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Incorrect temporary calculations may:
- manipulate balances
- break reward logic
- corrupt protocol state

---------------------------------------------------------

ANOTHER RISK

Developer may incorrectly assume:
local variable persists after execution.

This creates logic bugs.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Create local multiplication variable
2. Return multiplication result
3. Do NOT modify storage

BONUS:
Compare gas between:
- local calculation
- storage write

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Local variables are temporary
- Local variables do not persist
- State variables use storage
- Local uint variables usually use stack
- Storage writes consume more gas
- Local variables disappear after execution
- Temporary variables useful for calculations
- view/pure functions avoid storage modification
- Solidity ^0.8.x protects from overflow
- Auditors inspect temporary logic carefully

=========================================================
*/

/*
Implementation Review Report

Title: Correct Implementation of Local Variable Multiplication Function

Severity: Informational

Result: Passed

Location:

Contract: LocalUintVariable
Function: calculateMul()

Description:

The function correctly implements the mini challenge requirement by using a local variable to perform multiplication of two input values and returning the result without modifying any state variables.

The variable mul is properly declared as a local variable and exists only during function execution.

Requirement Check:
Create local multiplication variable → ✔ Done
Return multiplication result → ✔ Done
Do NOT modify storage → ✔ Done
Proof of Concept:

Deploy the contract.

Call:
calculateMul(10, 20)

Result:
200

Call:
calculateMul(2, 5)

Result:
10

Call:
calculateMul(0, 99)

Result:
0

Security Observation:
No storage mutation occurs
No state variables are modified
Function is safe and gas-efficient
Uses pure function correctly
Root Cause:

Not applicable — no vulnerability found. This is a correct implementation.

Recommendation:

No changes required.
*/
// patched code 
/*
contract LocalUintVariable {
    function calculateMul(uint256 _a, uint256 _b) public pure returns (uint256)
    {
        /*
            LOCAL VARIABLE

            mul exists ONLY during execution.

            It is NOT stored permanently
            on blockchain storage.
        //
        uint256 mul = _a * _b;
        return mul;
    }
}
*/
contract LocalUintVariableVul {
    function calculateMultiplication(
        uint256 _a,
        uint256 _b
    )
        public
        pure
        returns (uint256)
    {
        //Local variable
        uint256 multiplication = _a * _b;
        //Return multiplication result
        return multiplication;
    }    

}