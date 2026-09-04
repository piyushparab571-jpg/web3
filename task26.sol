// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Create calldata uint input
CONCEPT: External immutable input
=========================================================

OBJECTIVE

- Learn how external function inputs work
- Understand calldata in Solidity
- Learn immutable input behavior
- Understand difference between calldata, memory, and storage

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

calldata:
- temporary input area
- read-only
- immutable
- cheaper than memory

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Function arguments from external calls
arrive through calldata.

Calldata exists only during execution.

---------------------------------------------------------
WHY CALLDATA MATTERS
---------------------------------------------------------

Using calldata correctly:
- saves gas
- prevents unnecessary copying
- improves efficiency

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Calldata used heavily in:

- external function parameters
- DeFi protocols
- routers
- token transfers
- governance systems

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Is calldata used efficiently?
- Are unnecessary memory copies present?
- Are inputs validated?
- Can attacker abuse external inputs?
- Is immutability understood?

=========================================================
*/
/*
contract CalldataUintInputVul {

    /*
        STATE VARIABLE

        Stored permanently on blockchain.
    
    uint256 public storedNumber;

    function readInput(
        uint256 _number
    )
        external
        pure
        returns (uint256)
    {

        /*
            _number arrives through calldata.

            uint256 is value type,
            so Solidity handles it efficiently.

            Input exists temporarily
            during execution only.
        

        return _number;
    }

    function saveInput(
        uint256 _number
    )
        external
    {

        /*
            INPUT READ FROM CALLDATA

            Then copied into storage.
        
        storedNumber = _number;
    }

    function doubleInput(
        uint256 _number
    )
        external
        pure
        returns (uint256)
    {

        /*
            Using immutable external input
            for temporary calculation.
        
        uint256 result = _number * 2;

        return result;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
readInput(50)

EVM ACTIONS:

1. External transaction sent
2. Input encoded into calldata
3. _number read from calldata
4. Value returned
5. Calldata discarded after execution

---------------------------------------------------------

IMPORTANT

Nothing stored permanently.

=========================================================

CALL:
saveInput(777)

EVM ACTIONS:

1. Input arrives through calldata
2. _number read
3. storedNumber updated in storage
4. Blockchain state changes permanently

---------------------------------------------------------

FINAL STORAGE:

storedNumber = 777

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
readInput(50)

EXPECTED:
50

---------------------------------------------------------

STEP 3:
Call:
doubleInput(10)

EXPECTED:
20

---------------------------------------------------------

STEP 4:
Call:
saveInput(999)

---------------------------------------------------------

STEP 5:
Call:
storedNumber()

EXPECTED:
999

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Pass zero

EXPECTED:
Works correctly

---------------------------------------------------------

TEST:
Pass max uint256

EXPECTED:
Works unless arithmetic overflow occurs

---------------------------------------------------------

TEST:
Repeated calls

OBSERVE:
Calldata recreated every execution

=========================================================
IMPORTANT CALLDATA UNDERSTANDING
=========================================================

CALLDATA IS:

- temporary
- read-only
- external input data

---------------------------------------------------------

AFTER FUNCTION ENDS:
Calldata disappears automatically.

---------------------------------------------------------

VERY IMPORTANT

You cannot permanently modify calldata.

=========================================================
CALLDATA VS MEMORY VS STORAGE
=========================================================

---------------------------------------------------------
CALLDATA
---------------------------------------------------------

Temporary

Read-only

Cheapest

External inputs

---------------------------------------------------------
MEMORY
---------------------------------------------------------

Temporary

Mutable

More expensive than calldata

---------------------------------------------------------
STORAGE
---------------------------------------------------------

Permanent

Most expensive

Persists on blockchain

=========================================================
IMMUTABILITY CONCEPT
=========================================================

CALLDATA INPUTS ARE IMMUTABLE

Meaning:
they cannot be modified directly.

---------------------------------------------------------

THIS FAILS:

_number = 100;

(for reference-type calldata variables)

---------------------------------------------------------

Reason:
calldata is read-only.

=========================================================
GAS OBSERVATION
=========================================================

CALLDATA:
Cheaper than memory

---------------------------------------------------------

Reason:
No unnecessary copying.

---------------------------------------------------------

STORAGE WRITES:
Most expensive operations.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. INPUT VALIDATION
---------------------------------------------------------

External calldata is attacker-controlled.

Always validate inputs.

---------------------------------------------------------
2. GAS OPTIMIZATION
---------------------------------------------------------

Auditors check:
whether calldata should replace memory.

---------------------------------------------------------
3. IMMUTABILITY ASSUMPTIONS
---------------------------------------------------------

Developers must understand:
calldata cannot be modified.

---------------------------------------------------------
4. LARGE INPUT DOS
---------------------------------------------------------

Huge calldata inputs may:
increase gas consumption.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker sends malicious input values.

Without validation:
protocol logic may break.

---------------------------------------------------------

ANOTHER RISK

Large attacker-controlled calldata arrays
may create DOS via gas exhaustion.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Accept calldata uint array
2. Loop through values
3. Return total sum

BONUS:
Compare gas:
memory array vs calldata array

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Calldata stores external input data
- Calldata is temporary
- Calldata is read-only
- Calldata cheaper than memory
- Storage persists permanently
- External inputs are attacker-controlled
- Storage writes consume most gas
- Calldata improves gas efficiency
- Inputs disappear after execution
- Auditors inspect input handling carefully

=========================================================
*/

/*
Audit Report

Title: Unbounded Calldata Array May Cause Gas Exhaustion

Severity: Medium

Reason:
The contract accepts an attacker-controlled calldata array
without limiting its size.

A malicious user can pass extremely large arrays,
causing excessive loop iterations and high gas consumption.

Location:

Contract: CalldataUintInputVul
Function: sumInput(uint256[] calldata nums)

Vulnerability Description:
The function loops through the entire calldata array
without validating nums.length.

Because calldata input is fully controlled by external users,
an attacker may submit a massive array that forces
the transaction to consume excessive gas.

This creates a potential denial-of-service (DOS) risk
and scalability issue.

Impact:
An attacker can:

- trigger excessive gas consumption
- cause out-of-gas transaction failures
- reduce protocol usability
- make execution expensive

If similar logic exists in production protocols,
large calldata processing may eventually make
functions impractical to execute.

Proof of Concept:

1. Deploy the contract.

2. Call:
sumInput([1,2,3])

Result:
Function executes normally.

3. Call:
sumInput() with a very large array
containing hundreds or thousands of elements.

Result:
- gas usage increases heavily
- transaction may fail
- execution becomes expensive

Root Cause:
The function performs iteration over
a user-controlled dynamic array
without enforcing a maximum length limit.

No validation exists for:
- calldata size
- loop bounds
- execution scalability

Recommendation:
Restrict maximum calldata array size
before looping through elements.
*/

//patched code 
/*
contract CalldataUintInput {
    // calldata — reads DIRECTLY from input, no copy made
    // external  →  callable from OUTSIDE contract ONLY
    function sumInput(uint256[] calldata nums)external pure returns(uint256) {
        require(nums.length <= 100,"Array too large");

        uint256 sum=0;
        for(uint256 i=0;i<nums.length;i++){
            sum=sum+nums[i];
        }
        return sum;
    }
}
*/
// storage  →  permanent, lives on blockchain     (expensive)
// memory   →  temporary, copied into contract    (costs gas)
// calldata →  temporary, stays in the input      (cheapest)
contract CalldataUintInputVul {
    //Accept calldata uint array and return sum
    function sumArray(
    uint256[] calldata numbers
    )
    external 
    pure 
    returns (uint256)
    {
        uint256 total = 0;
        for (uint256 i = 0; i < numbers.length; i++) {
            total += numbers[i];
        }
        return total;
    }
}