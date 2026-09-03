// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Modify memory array
CONCEPT: Mutable temporary data
=========================================================

OBJECTIVE

- Learn how memory arrays can be modified
- Understand mutable temporary data
- Learn that memory changes do NOT persist
- Understand difference between memory and storage mutation

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Memory arrays are mutable.

This means:
their values CAN be changed during execution.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Even though memory arrays are mutable:

Changes are TEMPORARY.

After function execution:
memory disappears.

---------------------------------------------------------
MEMORY ARRAY BEHAVIOR
---------------------------------------------------------

Memory array:
- temporary
- modifiable
- non-persistent

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Mutable memory arrays used for:

- temporary calculations
- sorting
- filtering
- aggregation
- batch processing
- intermediate transformations

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Are memory changes intentional?
- Is storage accidentally expected to change?
- Can large memory operations cause DOS?
- Are loops scalable?
- Are copies handled safely?

=========================================================
*/
/*
contract ModifyMemoryArrayVul {

    uint256[] public storedNumbers;

    function createAndModifyArray()
        public
        pure
        returns (uint256[] memory)
    {
        /*
            CREATE MEMORY ARRAY
            Temporary array with size 3
        
        uint256[] memory tempArray = new uint256[](3);

        /*
            Initial values
        
        tempArray[0] = 1;
        tempArray[1] = 2;
        tempArray[2] = 3;
        /*
            MODIFY MEMORY ARRAY
            Memory arrays are mutable.
        
        tempArray[1] = 999;

        /*
            Final array:

            [1,999,3]
        
        return tempArray;
    }
    function modifyInputArray(uint256[] memory _numbers)
        public
        pure
        returns (uint256[] memory)
    {

        /*
            Modify first element
        
        _numbers[0] = 777;

        /*
            Changes apply only to memory copy
        
        return _numbers;
    }

    function storeValue(uint256 _value) public {

        /*
            STORAGE ARRAY

            Persists permanently.
        
        storedNumbers.push(_value);
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
createAndModifyArray()

EVM ACTIONS:

1. Temporary memory allocated
2. Array created
3. Values inserted
4. tempArray[1] modified
5. Modified array returned
6. Memory destroyed after execution

---------------------------------------------------------

FINAL RETURNED ARRAY:

[1,999,3]

---------------------------------------------------------

IMPORTANT

No blockchain storage modified.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
createAndModifyArray()

EXPECTED:
[1,999,3]

---------------------------------------------------------

STEP 3:
Call:
storedNumbers(0)

EXPECTED:
Error

Reason:
Nothing stored permanently.

---------------------------------------------------------

STEP 4:
Call:
modifyInputArray([5,6,7])

EXPECTED:
[777,6,7]

---------------------------------------------------------

STEP 5:
Call:
storeValue(100)

---------------------------------------------------------

STEP 6:
Call:
storedNumbers(0)

EXPECTED:
100

OBSERVE:
Storage persists.
Memory does not.

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Modify zero values

Input:
[0,0,0]

EXPECTED:
[777,0,0]

---------------------------------------------------------

TEST:
Large arrays

OBSERVE:
Higher gas consumption

---------------------------------------------------------

TEST:
Repeated calls

OBSERVE:
Fresh memory created each execution

=========================================================
IMPORTANT MEMORY UNDERSTANDING
=========================================================

MEMORY ARRAYS ARE MUTABLE

You CAN change elements.

Example:

tempArray[1] = 999;

---------------------------------------------------------

HOWEVER:
Changes are temporary only.

---------------------------------------------------------

AFTER EXECUTION:
Memory cleared automatically.

=========================================================
MEMORY VS STORAGE MUTATION
=========================================================

---------------------------------------------------------
MEMORY MUTATION
---------------------------------------------------------

Temporary

Non-persistent

Cheap

---------------------------------------------------------
STORAGE MUTATION
---------------------------------------------------------

Permanent

Blockchain state updated

Expensive

=========================================================
IMPORTANT COPY BEHAVIOR
=========================================================

FUNCTION INPUT:

uint256[] memory _numbers

---------------------------------------------------------

This creates MEMORY COPY.

Modifying _numbers:
does NOT affect original external data.

=========================================================
GAS OBSERVATION
=========================================================

MEMORY OPERATIONS:
Cheaper than storage

---------------------------------------------------------

LARGE MEMORY ARRAYS:
Still expensive computationally

---------------------------------------------------------

STORAGE WRITES:
Most expensive operations

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. MEMORY/STORAGE CONFUSION
---------------------------------------------------------

Common Solidity bug.

Developers may incorrectly assume:
memory changes persist permanently.

---------------------------------------------------------
2. DOS RISK
---------------------------------------------------------

Large memory array operations may:
- consume excessive gas
- exceed block limits

---------------------------------------------------------
3. LOOP RISKS
---------------------------------------------------------

Nested loops on large memory arrays
can become dangerous.

---------------------------------------------------------
4. COPY ASSUMPTIONS
---------------------------------------------------------

Auditors verify:
whether function uses:
- reference
OR
- copy semantics

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker provides huge arrays.

Contract performs:
- heavy memory allocation
- large loops
- expensive modifications

Result:
DOS via gas exhaustion.

---------------------------------------------------------

ANOTHER RISK

Developer expects:
memory modifications persist.

Critical logic silently fails.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Double every element in memory array
2. Use loop for modification
3. Return updated array

BONUS:
Compare:
memory array vs storage array behavior

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Memory arrays are mutable
- Memory changes are temporary
- Memory cleared after execution
- Storage persists permanently
- Memory arrays useful for temporary processing
- Function inputs may become memory copies
- Memory operations cheaper than storage
- Large memory operations increase gas
- Memory/storage confusion causes bugs
- Auditors inspect temporary mutation carefully

=========================================================
*/
/*
AUDIT REPORT
Title: Unbounded Memory Array Loop May Cause Gas Exhaustion

Severity: Low

Reason: Function processes entire user-supplied memory array without size restriction, which may lead to excessive gas consumption for large inputs.

Location:

Contract: ModifyMemoryArray
Function: modifyArray()

Vulnerability Description:

The function modifyArray() accepts a dynamic memory array from the user and iterates through the entire array using a loop.

Although the logic correctly doubles each element and does not modify storage, there is no restriction on input array size.

An attacker may provide extremely large arrays, increasing computation cost and potentially causing transaction failure due to gas exhaustion.

Impact:
    Excessive gas consumption
    Potential denial-of-service (DoS) conditions
    Transaction failures for very large arrays
    Reduced scalability for larger datasets

Proof of Concept:
1.Deploy contract
2.Call:
    modifyArray([1,2,3])
3.Returned output:
    [2,4,6]
    Call function with very large array input
4.Observation:
Loop processes every element
Gas usage increases linearly with array size
Extremely large arrays may fail due to gas limits

Root Cause:
    No validation on _numbers.length
    Unbounded loop execution on user-controlled input
    Entire memory array processed without limits

Recommendation:
    Restrict maximum array size before processing.

Example:
    require(_numbers.length <= 100, "Array too large");
*/
//patched code 
/*
contract ModifyMemoryArray {
    function modifyArray(uint256[] memory _numbers)public pure returns (uint256[] memory)
    {
       require(_numbers.length <= 100, "Array too large");
       for (uint i=0;i<_numbers.length;i++){
        _numbers[i]=_numbers[i]*2;
       }
        return _numbers;
    }
}
*/
contract ModifyMemoryArrayVul {
    uint256[] public storedNumbers;
    function doubleMemoryArray()
    public 
    pure 
    returns (uint256[] memory)
    {
        //create memory array
        uint256[] memory numbers = new uint256[](3);
        //store values
        numbers[0] = 1;
        numbers[1] = 2;
        numbers[2] = 3;
        //Double every element using a loop
        for (uint256 i = 0; i < numbers.length; i++) {
            numbers[i] = numbers[i] *2;
        }
        //return updated array
        return numbers;
    }
    function storeValue(uint256 _value) public {
        //Storage array
        storedNumbers.push(_value);
    }
}