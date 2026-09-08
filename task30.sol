// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Compare calldata vs memory
CONCEPT: Gas + mutability
=========================================================

OBJECTIVE

- Learn difference between calldata and memory
- Understand gas efficiency differences
- Learn mutability behavior
- Understand when to use calldata vs memory

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

CALLDATA:
- external input area
- read-only
- cheaper
- avoids copying

MEMORY:
- temporary execution area
- mutable
- more expensive
- requires allocation/copying

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Choosing correct data location:
- affects gas usage
- affects mutability
- affects protocol efficiency

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Gas optimization is critical in:

- DeFi protocols
- routers
- NFT systems
- governance contracts
- multicall architectures

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

CALldata commonly used for:
- external read-only inputs

Memory commonly used for:
- temporary modifications
- internal processing

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Is calldata preferable?
- Are unnecessary copies created?
- Are developers misunderstanding mutability?
- Can large copies create DOS?
- Is gas optimized properly?

=========================================================
*/
/*
contract CalldataVsMemoryVul {

    /*
        STORAGE ARRAY

        Permanent blockchain data.
    
    uint256[] public storedValues;

    /*
    =====================================================
    CALLDATA EXAMPLE
    =====================================================

    Efficient external read-only input.
    

    function useCalldata(
        uint256[] calldata _numbers
    )
        external
        pure
        returns (uint256)
    {

        uint256 total = 0;

        /*
            LOOP DIRECTLY OVER CALLDATA

            No memory copy created.
        
        for (uint256 i = 0; i < _numbers.length; i++) {

            total += _numbers[i];
        }

        return total;
    }

    /*
    =====================================================
    MEMORY EXAMPLE
    =====================================================

    Creates memory copy.
    

    function useMemory(
        uint256[] memory _numbers
    )
        public
        pure
        returns (uint256)
    {

        uint256 total = 0;

        /*
            _numbers exists in memory.

            Mutable temporary copy.
        
        for (uint256 i = 0; i < _numbers.length; i++) {

            total += _numbers[i];
        }

        return total;
    }

    /*
    =====================================================
    MEMORY MODIFICATION EXAMPLE
    =====================================================

    Memory arrays are mutable.
    

    function modifyMemory(
        uint256[] calldata _numbers
    )
        external
        pure
        returns (uint256[] memory)
    {

        /*
            COPY CALLDATA INTO MEMORY
        
        uint256[] memory tempArray = _numbers;

        /*
            MODIFY MEMORY ARRAY

            Allowed.
        
        tempArray[0] = 999;

        return tempArray;
    }

    /*
    =====================================================
    STORAGE WRITE EXAMPLE
    =====================================================


    function saveValues(
        uint256[] calldata _numbers
    )
        external
    {

        /*
            Copy calldata values into storage.
        
        for (uint256 i = 0; i < _numbers.length; i++) {

            storedValues.push(_numbers[i]);
        }
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
useCalldata([1,2,3])

EVM ACTIONS:

1. Array arrives in calldata
2. Loop reads directly from calldata
3. No memory copy created
4. Result returned
5. Calldata discarded

---------------------------------------------------------

GAS:
Cheaper

=========================================================

CALL:
modifyMemory([1,2,3])

EVM ACTIONS:

1. Array arrives in calldata
2. Full copy created in memory
3. Memory array modified
4. Modified copy returned
5. Memory destroyed

---------------------------------------------------------

GAS:
More expensive than calldata-only read

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
useCalldata([1,2,3])

EXPECTED:
6

---------------------------------------------------------

STEP 3:
Call:
useMemory([1,2,3])

EXPECTED:
6

---------------------------------------------------------

STEP 4:
Compare gas usage

OBSERVE:
calldata cheaper than memory

---------------------------------------------------------

STEP 5:
Call:
modifyMemory([5,6,7])

EXPECTED:
[999,6,7]

---------------------------------------------------------

STEP 6:
Observe:
Original calldata unchanged

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Pass empty array

EXPECTED:
0

---------------------------------------------------------

TEST:
Pass huge array

OBSERVE:
Higher gas usage

---------------------------------------------------------

TEST:
Modify calldata directly

EXPECTED:
Compiler error

=========================================================
IMPORTANT CALLDATA UNDERSTANDING
=========================================================

CALLDATA:
- temporary
- immutable
- external-input optimized

---------------------------------------------------------

BEST FOR:
Read-only external inputs.

=========================================================
IMPORTANT MEMORY UNDERSTANDING
=========================================================

MEMORY:
- temporary
- mutable
- supports modifications

---------------------------------------------------------

BEST FOR:
Temporary processing and mutations.

=========================================================
CALLDATA VS MEMORY COMPARISON
=========================================================

---------------------------------------------------------
CALLDATA
---------------------------------------------------------

Read-only

Cheaper

No automatic copy

Cannot modify

External functions only

---------------------------------------------------------
MEMORY
---------------------------------------------------------

Mutable

More expensive

Requires allocation

Can modify

Used internally too

=========================================================
GAS OBSERVATION
=========================================================

CALLDATA:
More gas efficient

---------------------------------------------------------

Reason:
Avoids memory allocation/copying.

---------------------------------------------------------

MEMORY:
More expensive due to:
- allocation
- copying
- expansion

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. UNNECESSARY MEMORY COPIES
---------------------------------------------------------

Common gas inefficiency.

Auditors recommend:
calldata where possible.

---------------------------------------------------------
2. DOS VIA LARGE ARRAYS
---------------------------------------------------------

Huge arrays may:
- exhaust gas
- break loops
- create scalability issues

---------------------------------------------------------
3. MUTABILITY CONFUSION
---------------------------------------------------------

Developers may incorrectly assume:
calldata can be modified.

---------------------------------------------------------
4. LOOP RISKS
---------------------------------------------------------

Attacker-controlled arrays
must be bounded carefully.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker submits huge array.

Contract unnecessarily copies:
calldata -> memory.

Result:
- wasted gas
- DOS condition
- inefficient execution

---------------------------------------------------------

ANOTHER RISK

Developer expects:
calldata modification.

Logic silently fails.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Accept calldata string array
2. Copy into memory
3. Modify one element safely
4. Return updated memory array

BONUS:
Measure gas differences in Remix.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Calldata is read-only
- Memory is mutable
- Calldata cheaper than memory
- Memory requires allocation
- Copying arrays costs gas
- External inputs arrive via calldata
- Memory useful for temporary modifications
- Large arrays create DOS risks
- Gas optimization matters heavily
- Auditors inspect data-location efficiency carefully

=========================================================
*/

/*
Audit Report

Title: Missing Array Bounds Validation in stringArr()

Severity: Low

Reason:
The function copies attacker-controlled calldata
arrays into memory and modifies index [0]
without validating array length.

Location:

    Contract: CalldataVsMemory
    Function: stringArr()

Vulnerability Description:

The patched function performs:

tempNames[0] = "Solidity";

without checking whether the input array
contains at least one element.

If an empty array is passed:

[]

then accessing index [0] will revert
with an out-of-bounds error.

Additionally, very large arrays may still
consume excessive gas during calldata-to-memory copying.

Impact:

An attacker may:

- trigger unnecessary transaction reverts
- cause failed executions
- waste gas
- reduce usability of the function

Large arrays may also:

- increase gas costs
- create scalability concerns
- contribute to denial-of-service conditions

Proof of Concept:

1. Deploy contract

2. Call:

stringArr([])

3. OBSERVE:

Transaction reverts because:

tempNames[0]

does not exist.

Root Cause:

The contract assumes the calldata array
always contains at least one element.

Missing validation:

require(_names.length > 0, "Array empty");

Additionally:

No upper bound exists for large arrays.

Recommendation:

Validate array size before copying/modifying.

Example:

require(_names.length > 0, "Array empty");
require(_names.length <= 100, "Array too large");
*/
//patched code 
/*
contract CalldataVsMemory {

  function stringArr(string[] calldata _names)external pure returns (string[] memory){
      require(_names.length > 0, "Array empty");
    require(_names.length <= 100, "Array too large");
    string[] memory tempNames=_names;
    tempNames[0]="Solidity";
    return tempNames;
  }
}
*/
contract CalldataVsMemoryVul {

    /*
        FUNCTION:
        Accept string array through calldata,
        copy it into memory,
        modify one element,
        and return the updated array.
    */
    function modifyStringArray(
        string[] calldata _messages
    )
        external
        pure
        returns (string[] memory)
    {
        /*
            COPY CALLDATA ARRAY INTO MEMORY

            The complete array is copied
            from calldata to memory.
        */
        string[] memory tempArray = _messages;

        /*
            MODIFY ONE ELEMENT

            Memory arrays are mutable.

            Element at index 0 is replaced.
        */
        tempArray[0] = "Modified";

        /*
            RETURN UPDATED MEMORY ARRAY
        */
        return tempArray;
    }
}