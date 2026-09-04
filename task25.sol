// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Return large memory array
CONCEPT: Memory allocation
=========================================================

OBJECTIVE

- Learn how large memory arrays are allocated
- Understand memory expansion costs
- Learn how returning large arrays affects gas
- Understand scalability risks in Solidity

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Memory arrays are allocated dynamically
during execution.

Larger arrays:
- require more memory
- consume more gas
- increase execution cost

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Returning large arrays can become expensive.

Reason:
EVM must:
- allocate memory
- store elements
- encode return data

---------------------------------------------------------
REAL-WORLD IMPORTANCE
---------------------------------------------------------

Large memory operations affect:

- scalability
- gas efficiency
- DOS resistance
- protocol usability

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Large arrays appear in:

- DeFi protocols
- NFT collections
- staking systems
- governance snapshots
- batch operations

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Can arrays grow unbounded?
- Can functions become uncallable?
- Is gas exhaustion possible?
- Are loops scalable?
- Is pagination needed?

=========================================================
*/
/*

contract LargeMemoryArrayVul {

    /*
        STORAGE ARRAY

        Persists permanently.
    
    uint256[] public storedValues;

    function addValues(uint256 _count) public {

        /*
            Add values into storage array.

            WARNING:
            Large loops increase gas usage.
        
        for (uint256 i = 0; i < _count; i++) {

            storedValues.push(i);
        }
    }

    function returnLargeArray(uint256 _size)
        public
        pure
        returns (uint256[] memory)
    {

        /*
            CREATE LARGE MEMORY ARRAY

            Memory allocated dynamically.
        
        uint256[] memory tempArray =new uint256[](_size);

        /*
            Fill memory array
        
        for (uint256 i = 0; i < _size; i++) {

            tempArray[i] = i + 1;
        }

        /*
            Entire array returned.

            Larger arrays:
            higher gas cost.
        
        return tempArray;
    }

    function copyStorageToMemory()
        public
        view
        returns (uint256[] memory)
    {

        /*
            FULL STORAGE -> MEMORY COPY

            Dangerous if storage array becomes huge.
        
        return storedValues;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
returnLargeArray(5)

EVM ACTIONS:

1. Allocate memory for 5 elements
2. Create temporary array
3. Fill array using loop
4. Encode return data
5. Return memory array
6. Memory cleared after execution

---------------------------------------------------------

RETURNED ARRAY:

[1,2,3,4,5]

=========================================================

CALL:
returnLargeArray(1000)

OBSERVE:

- more memory allocation
- more loop iterations
- higher gas consumption
- larger return data

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
returnLargeArray(5)

EXPECTED:
[1,2,3,4,5]

---------------------------------------------------------

STEP 3:
Call:
returnLargeArray(50)

OBSERVE:
Higher execution cost

---------------------------------------------------------

STEP 4:
Call:
returnLargeArray(500)

OBSERVE:
Even higher gas usage

---------------------------------------------------------

STEP 5:
Call:
addValues(20)

---------------------------------------------------------

STEP 6:
Call:
copyStorageToMemory()

EXPECTED:
Returns all stored values

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
_size = 0

EXPECTED:
Empty array returned

---------------------------------------------------------

TEST:
Very large _size

OBSERVE:
Possible:
- high gas cost
- out-of-gas errors

---------------------------------------------------------

TEST:
Huge storage array copy

OBSERVE:
Function may become expensive/unusable

=========================================================
IMPORTANT MEMORY UNDERSTANDING
=========================================================

THIS LINE:

new uint256[](_size)

---------------------------------------------------------

ALLOCATES:
dynamic memory space.

---------------------------------------------------------

LARGER ARRAYS:
require more EVM memory expansion.

---------------------------------------------------------

VERY IMPORTANT

Memory is temporary:
cleared after execution.

=========================================================
MEMORY EXPANSION COST
=========================================================

EVM charges gas for:
- allocating memory
- expanding memory
- writing values
- encoding return data

---------------------------------------------------------

LARGE ARRAYS:
grow gas costs rapidly.

=========================================================
RETURN DATA COST
=========================================================

Returning large arrays also costs gas.

Reason:
EVM must ABI-encode:
every array element.

=========================================================
SCALABILITY RISK
=========================================================

UNBOUNDED ARRAYS ARE DANGEROUS.

Functions may become:
- too expensive
- uncallable
- DOS vulnerable

=========================================================
GAS OBSERVATION
=========================================================

SMALL ARRAY:
Cheap

---------------------------------------------------------

LARGE ARRAY:
Expensive

---------------------------------------------------------

VERY LARGE ARRAY:
Possible out-of-gas failure

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. DOS VIA GAS EXHAUSTION
---------------------------------------------------------

Huge arrays may:
- exceed block gas limit
- make function unusable

---------------------------------------------------------
2. UNBOUNDED LOOPS
---------------------------------------------------------

Loops over attacker-controlled size
are dangerous.

---------------------------------------------------------
3. STORAGE-TO-MEMORY COPYING
---------------------------------------------------------

Copying massive storage arrays
can break scalability.

---------------------------------------------------------
4. PAGINATION REQUIREMENT
---------------------------------------------------------

Auditors often recommend:
pagination instead of returning everything.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker grows storage array massively.

Then calls:
copyStorageToMemory()

Result:
- excessive gas usage
- DOS condition
- function unusable

---------------------------------------------------------

REAL-WORLD ISSUE

Many protocols became uncallable
because arrays grew too large.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add pagination support
2. Return only partial array range
3. Avoid returning entire huge array

BONUS:
Implement:
(start, limit) logic

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Memory arrays allocate temporary memory
- Large arrays increase gas consumption
- Memory expansion costs gas
- Returning arrays requires ABI encoding
- Large return data becomes expensive
- Unbounded loops create scalability risks
- Storage-to-memory copying can be dangerous
- DOS via gas exhaustion is common
- Pagination improves scalability
- Auditors inspect array growth carefully

=========================================================
*/


/*
AUDIT REPORT

Title: Large Memory Allocation and Unbounded Array Operations May Cause Gas Exhaustion

Severity: Medium

Reason:
The original contract allows unrestricted memory array allocation,
unbounded loops, and full storage-to-memory copying, which may
cause excessive gas consumption and denial-of-service conditions.

Location:

Contract: LargeMemoryArrayVul

Functions:
- addValues(uint256 _count)
- returnLargeArray(uint256 _size)
- copyStorageToMemory()


Vulnerability Description:


1. UNBOUNDED LOOP IN addValues()

The addValues() function accepts a user-controlled _count
parameter and loops until _count is reached.

Example:

for (uint256 i = 0; i < _count; i++) {
    storedValues.push(i);
}

An attacker may pass extremely large values,
causing:
- excessive gas usage
- storage bloat
- transaction failures



2. LARGE MEMORY ARRAY ALLOCATION

The function returnLargeArray() creates a memory array
using fully user-controlled input.

Example:

uint256[] memory tempArray =
    new uint256[](_size);

Large _size values may:
- allocate excessive memory
- consume large gas amounts
- trigger out-of-gas errors



3. FULL STORAGE-TO-MEMORY COPYING

The function copyStorageToMemory() returns the
entire storage array.

Example:

return storedValues;

As storedValues grows,
copying the full array becomes increasingly expensive.

Eventually the function may:
- become uncallable
- exceed block gas limits
- create DOS conditions


Impact:


- Excessive gas consumption
- Denial-of-service risk
- Out-of-gas transaction failures
- Poor scalability
- Storage bloat
- Expensive memory allocation


Proof of Concept:


1. Deploy contract



2. Call:

addValues(10000)

Observation:
Massive storage growth occurs.



3. Call:

copyStorageToMemory()

Observation:
Very high gas consumption due to
full storage array copying.



4. Call:

returnLargeArray(5000)

Observation:
Large memory allocation and ABI encoding cost.

Possible result:
Out-of-gas failure.


Root Cause:


- No validation on _count
- No validation on _size
- Unbounded loops
- Full storage array copying
- Lack of pagination support

Recommendation:

1. Restrict maximum array growth.

Example:

require(_count <= 100, "Too many values");

2. Avoid returning entire large arrays.

3. Implement pagination.

4. Return only partial array ranges.

*/
// patched code 
/*
contract LargeMemoryArray {

    uint256[] public storeValues;

    function addValues(uint256 _count)public{
        require(_count <= 100, "Too many values");
        for (uint256 i=0;i<_count;i++){
            storeValues.push(i);
        }
    }

    function getPaginatedArray(uint256 start,uint256 limit)public view returns (uint[] memory){
         // Prevent invalid start
        require(start<storeValues.length,"start is too high"); 
        uint256 end=start+limit; // Finding ending index
        //  Prevent overflow beyond array size
        if(end>storeValues.length){
            end=storeValues.length;
        }

        uint256 size=end-start;

        uint256[] memory temp=new uint256[](size);   //Create memory array
        for(uint256 i=0;i<size;i++){  // Copy only partial range
            temp[i]=storeValues[start+i];
        }
        return  temp;
    }
}
*/
contract LargeMemoryArrayVul {
    uint256[] public storedValues;
    function addValues(uint256 _count) public {
        for (uint256 i = 0; i < _count; i++) {
            storedValues.push(i);
        }
    }
    //Pagination: return only part of array
    function getPage(uint256 start, uint256 limit)
    public 
    view 
    returns (uint256[] memory)
    {
        require(start < storedValues.length, "Invalid start");
        uint256 end = start + limit;
        if (end > storedValues.length) {
            end = storedValues.length;
        }
        uint256 size = end - start;
        uint256[] memory result = new uint256[](size);
        for (uint256 i = 0; i < size; i++) {
            result[i] = storedValues[start + i];
        }
        return result;
    }
}