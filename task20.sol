// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Copy storage array to memory
CONCEPT: Data copying behavior
=========================================================

OBJECTIVE

- Learn how storage arrays are copied into memory
- Understand copy behavior in Solidity
- Learn difference between storage reference and memory copy
- Understand why memory modifications do NOT affect storage

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

When storage array is assigned to memory:

uint256[] memory temp = numbers;

A FULL COPY is created.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

After copying:

- temp becomes independent memory array
- original storage remains unchanged
- modifying temp does NOT affect storage

---------------------------------------------------------
STORAGE -> MEMORY COPY
---------------------------------------------------------

STORAGE:
Permanent blockchain data

MEMORY:
Temporary execution copy

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Storage-to-memory copying used in:

- batch processing
- temporary calculations
- sorting
- filtering
- returning data safely

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Is copy intentional?
- Is developer expecting reference?
- Are mutations safe?
- Is excessive copying expensive?
- Can large arrays create DOS?

=========================================================
*/
/*
contract StorageToMemoryCopyVul {

    uint256[] public numbers;

    function addValues() public {

        /*
            STORE VALUES IN STORAGE ARRAY
        
        numbers.push(10);

        numbers.push(20);

        numbers.push(30);
    }

    function copyArrayToMemory()
        public
        view
        returns (uint256[] memory)
    {

        /*
            STORAGE -> MEMORY COPY

            Entire storage array copied
            into temporary memory array.
        
        uint256[] memory tempArray = numbers;

        /*
            Returning temporary copy
        
        return tempArray;
    }

    function modifyMemoryCopy()
        public
        view
        returns (uint256[] memory)
    {

        /*
            Create memory copy
        
        uint256[] memory tempArray = numbers;

        /*
            Modify MEMORY copy only
        
        tempArray[0] = 999;

        /*
            Original storage remains unchanged
        
        return tempArray;
    }

    function getStorageArray()
        public
        view
        returns (uint256[] memory)
    {
        return numbers;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
addValues()

STORAGE ARRAY:

[10,20,30]

---------------------------------------------------------

CALL:
copyArrayToMemory()

EVM ACTIONS:

1. Storage array loaded
2. Full copy created in memory
3. tempArray becomes independent copy
4. Memory array returned
5. Memory cleared after execution

---------------------------------------------------------

CALL:
modifyMemoryCopy()

MEMORY COPY BEFORE:
[10,20,30]

AFTER MODIFICATION:
[999,20,30]

---------------------------------------------------------

IMPORTANT

ORIGINAL STORAGE STILL:

[10,20,30]

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
addValues()

---------------------------------------------------------

STEP 3:
Call:
getStorageArray()

EXPECTED:
[10,20,30]

---------------------------------------------------------

STEP 4:
Call:
copyArrayToMemory()

EXPECTED:
[10,20,30]

---------------------------------------------------------

STEP 5:
Call:
modifyMemoryCopy()

EXPECTED:
[999,20,30]

---------------------------------------------------------

STEP 6:
Call:
getStorageArray()

EXPECTED:
[10,20,30]

OBSERVE:
Storage unchanged.

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Copy empty storage array

EXPECTED:
Returns empty memory array

---------------------------------------------------------

TEST:
Large arrays

OBSERVE:
Higher gas usage due to copying

---------------------------------------------------------

TEST:
Repeated calls

OBSERVE:
Fresh memory copy created each execution

=========================================================
IMPORTANT COPY UNDERSTANDING
=========================================================

THIS LINE:

uint256[] memory tempArray = numbers;

---------------------------------------------------------

DOES:
Create FULL COPY.

---------------------------------------------------------

DOES NOT:
Create storage reference.

=========================================================
MEMORY COPY BEHAVIOR
=========================================================

AFTER COPYING:

Storage Array:
[10,20,30]

Memory Array:
[10,20,30]

---------------------------------------------------------

AFTER MODIFYING MEMORY:

Storage:
[10,20,30]

Memory:
[999,20,30]

---------------------------------------------------------

IMPORTANT

Arrays become independent after copy.

=========================================================
STORAGE VS MEMORY REFERENCE
=========================================================

---------------------------------------------------------
MEMORY COPY
---------------------------------------------------------

uint256[] memory temp = numbers;

Creates independent copy.

---------------------------------------------------------
STORAGE REFERENCE
---------------------------------------------------------

uint256[] storage temp = numbers;

Creates direct pointer/reference.

Changes affect original storage.

=========================================================
GAS OBSERVATION
=========================================================

COPYING LARGE ARRAYS:
Expensive

---------------------------------------------------------

Reason:
Every element copied individually
from storage into memory.

---------------------------------------------------------

VERY LARGE ARRAYS:
May become DOS risk.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. MEMORY/STORAGE CONFUSION
---------------------------------------------------------

Common Solidity bug source.

Developers may incorrectly assume:
memory copy affects storage.

---------------------------------------------------------
2. DOS RISK
---------------------------------------------------------

Huge arrays may:
- consume excessive gas
- exceed block gas limits

---------------------------------------------------------
3. COPYING COST
---------------------------------------------------------

Large storage-to-memory copies
can become very expensive.

---------------------------------------------------------
4. REFERENCE ASSUMPTIONS
---------------------------------------------------------

Auditors verify:
whether developer intended:
- copy
OR
- direct storage reference

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker inflates storage array size.

Function copying array:
becomes too expensive.

Result:
Function becomes unusable.

---------------------------------------------------------

REAL-WORLD ISSUE

Large storage copying has caused:
- DOS vulnerabilities
- gas exhaustion
- scalability failures

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Create storage reference variable
2. Modify referenced array
3. Observe storage changes directly

BONUS:
Compare:
memory copy vs storage reference

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Storage-to-memory creates full copy
- Memory copies are independent
- Memory changes do not affect storage
- Storage references behave differently
- Large array copying increases gas
- Memory cleared after execution
- Storage persists permanently
- Copying dynamic arrays is expensive
- Memory/storage confusion causes bugs
- Auditors inspect copy behavior carefully

=========================================================
*/

/*
Audit Report

Title: Large Storage-To-Memory Array Copy May Cause Gas Exhaustion

Severity: Low

Reason: Copying large storage arrays into memory may consume excessive gas and create denial-of-service risks.

Location:

Contract: StorageToMemoryCopyVul
Function: copyArrayToMemory()

Vulnerability Description:

The function copies the entire storage array into memory using:

uint256[] memory tempArray = numbers;

Although this behavior is correct and intentional, copying very large storage arrays into memory can become computationally expensive because every element must be copied individually.

If the storage array grows excessively large, transactions calling the function may fail due to block gas limits.

Impact:

Excessive gas consumption
Potential denial-of-service (DoS)
Reduced scalability
Expensive execution for large arrays
Functions may become unusable for oversized datasets

Proof of Concept:

Deploy contract
Call:
addValues()
Call repeatedly to increase array size.
Call:
copyArrayToMemory()
Observation:
Entire storage array copied into memory
Gas usage increases with array size
Very large arrays may cause transaction failure

Root Cause:

The following line performs a full storage-to-memory copy:

uint256[] memory tempArray = numbers;

Every array element is copied individually from storage into temporary memory.

Recommendation:

Avoid copying excessively large storage arrays into memory.

Consider:

pagination
bounded array sizes
partial retrieval mechanisms

Example:

require(numbers.length <= 100, "Array too large");
*/
//patched code 
/*
contract StorageToMemoryCopy {

    uint256[] public numbers;

    function addValues() public {

        /*
            STORE VALUES IN STORAGE ARRAY
        
        numbers.push(10);

        numbers.push(20);

        numbers.push(30);
    }

    function copyArrayToMemory()
        public
        view
        returns (uint256[] memory)
    {

        /*
            STORAGE -> MEMORY COPY

            Entire storage array copied
            into temporary memory array.
        
        uint256[] memory tempArray = numbers;

        /*
            Returning temporary copy
        
        return tempArray;
    }

    function modifyMemoryCopy()
        public
        view
        returns (uint256[] memory)
    {

        /*
            Create memory copy
        
        uint256[] memory tempArray = numbers;

        /*
            Modify MEMORY copy only
        
        tempArray[0] = 999;

        /*
            Original storage remains unchanged
        
        return tempArray;
    }

    function getStorageArray()
        public
        view
        returns (uint256[] memory)
    {
        return numbers;
    }


    function modifyRefArray()public{
        require(numbers.length>0,"Empty Array");
        uint256[] storage tempArray=numbers;
        tempArray[0]=100;

    }
}
*/
contract StorageToMemoryCopyVul {
    uint256[] public numbers;
    function addValues() public {
        numbers.push(10);
        numbers.push(20);
        numbers.push(30);
    }
    function modifyStorageReference()
    public 
    {
        /*
        STORAGE REFERENCE
        A storage reference points directly
        to the original storage array.
        */
        uint256[] storage refArray = numbers;
        /*
        Modify the referenced storage array
        */
        refArray[0] = 999;
        /*
        The original numbers array is also changed.
        */
    }
    function getStorageArray()
    public 
    view 
    returns (uint256[] memory)
    {
        return numbers;
    }
}