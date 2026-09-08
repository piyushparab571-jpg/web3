// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Try modifying calldata
CONCEPT: Read-only restriction
=========================================================

OBJECTIVE

- Learn why calldata is immutable
- Understand read-only restrictions
- Learn difference between calldata and memory
- Understand Solidity compiler protections

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

calldata is READ-ONLY.

You can read values from calldata,
but cannot modify them directly.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Calldata represents:
external transaction input data.

It is not writable memory.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Understanding calldata immutability is critical for:

- gas optimization
- secure input handling
- Solidity auditing
- memory vs calldata behavior

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Calldata commonly used for:

- router inputs
- swap parameters
- token transfers
- batch operations
- governance proposals

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Is calldata used correctly?
- Are developers misunderstanding immutability?
- Are unnecessary memory copies used?
- Is gas optimization possible?
- Are inputs validated safely?

=========================================================
*/
/*
contract CalldataRestrictionVul {
    /*
        STORAGE VARIABLE

        Permanent blockchain state.
    
    uint256 public savedValue;

    function readCalldata(
        uint256 _number
    )
        external
        pure
        returns (uint256)
    {

        /*
            _number arrives through calldata.

            Reading is allowed.
        
        return _number;
    }

    function workingMemoryExample(
        uint256[] calldata _numbers
    )
        external
        pure
        returns (uint256[] memory)
    {

        /*
            CREATE MEMORY COPY

            Memory is mutable.
        
        uint256[] memory tempArray = _numbers;

        /*
            MODIFY MEMORY COPY

            Allowed.
        
        tempArray[0] = 999;

        return tempArray;
    }

    /*
    =====================================================
    THIS FUNCTION INTENTIONALLY FAILS
    =====================================================

    Uncomment to observe compiler error.

    function failModification(
        uint256[] calldata _numbers
    )
        external
        pure
    {

        // ERROR:
        // calldata is read-only

        _numbers[0] = 999;
    }

    =====================================================
    COMPILER ERROR EXPLANATION
    =====================================================

    Solidity prevents modification because:
    calldata is immutable.

    =====================================================
    */
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
readCalldata(50)

EVM ACTIONS:

1. External input arrives in calldata
2. Value read directly
3. Returned successfully
4. Calldata discarded after execution

---------------------------------------------------------

IMPORTANT

No modification occurs.

=========================================================

CALL:
workingMemoryExample([1,2,3])

EVM ACTIONS:

1. Array arrives in calldata
2. Copied into mutable memory
3. Memory array modified
4. Modified memory returned
5. Memory destroyed after execution

---------------------------------------------------------

RETURN VALUE:

[999,2,3]

---------------------------------------------------------

ORIGINAL CALLDATA:
Never changed.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
readCalldata(123)

EXPECTED:
123

---------------------------------------------------------

STEP 3:
Call:
workingMemoryExample([1,2,3])

EXPECTED:
[999,2,3]

---------------------------------------------------------

STEP 4:
Uncomment failModification()

---------------------------------------------------------

STEP 5:
Compile contract

EXPECTED:
Compiler error

=========================================================
EXPECTED COMPILER ERROR
=========================================================

Typical error:

TypeError:
Calldata arrays are read-only.

---------------------------------------------------------

IMPORTANT

Solidity protects calldata automatically.

=========================================================
IMPORTANT CALLDATA UNDERSTANDING
=========================================================

CALLDATA IS:

- temporary
- external input
- immutable
- read-only

---------------------------------------------------------

YOU CAN:
- read calldata
- loop through calldata
- copy calldata to memory

---------------------------------------------------------

YOU CANNOT:
- modify calldata directly

=========================================================
WHY CALLDATA IS IMMUTABLE
=========================================================

Reason 1:
Gas efficiency

---------------------------------------------------------

Reason 2:
External transaction integrity

---------------------------------------------------------

Reason 3:
Avoid unnecessary memory writes

=========================================================
CALLDATA VS MEMORY
=========================================================

---------------------------------------------------------
CALLDATA
---------------------------------------------------------

Read-only

Cheapest

External input

Immutable

---------------------------------------------------------
MEMORY
---------------------------------------------------------

Mutable

Temporary

Can be modified

More expensive

=========================================================
HOW TO MODIFY CALLDATA SAFELY
=========================================================

STEP 1:
Copy calldata into memory

Example:

uint256[] memory temp = _numbers;

---------------------------------------------------------

STEP 2:
Modify memory copy

temp[0] = 999;

---------------------------------------------------------

IMPORTANT

Original calldata remains unchanged.

=========================================================
GAS OBSERVATION
=========================================================

READING CALLDATA:
Cheap

---------------------------------------------------------

COPYING TO MEMORY:
Costs additional gas

---------------------------------------------------------

MODIFYING MEMORY:
Allowed

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. IMMUTABILITY ASSUMPTIONS
---------------------------------------------------------

Auditors verify developers understand:
calldata cannot be modified.

---------------------------------------------------------
2. UNNECESSARY MEMORY COPIES
---------------------------------------------------------

Copying calldata unnecessarily
wastes gas.

---------------------------------------------------------
3. LARGE INPUT DOS
---------------------------------------------------------

Huge calldata arrays may:
- increase gas usage
- create DOS conditions

---------------------------------------------------------
4. INPUT VALIDATION
---------------------------------------------------------

All calldata is attacker-controlled.

Never trust external inputs.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker sends huge calldata arrays.

Contract copies everything into memory.

Result:
- excessive gas usage
- DOS risk

---------------------------------------------------------

ANOTHER RISK

Developer incorrectly assumes:
calldata modifications persist.

Logic silently fails.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Accept calldata string
2. Copy into memory
3. Return modified version safely

BONUS:
Compare gas:
calldata vs memory inputs

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Calldata is read-only
- Calldata cannot be modified
- Solidity enforces immutability
- Memory copies are mutable
- Copying calldata costs gas
- Calldata is temporary
- External inputs are attacker-controlled
- Memory/storage/calldata behave differently
- Gas optimization matters
- Auditors inspect data-location behavior carefully

=========================================================
*/


/*
Audit Report

Title: Excessive Calldata-to-Memory Copy May Cause Gas Exhaustion

Severity: Low

Reason:
    The contract copies attacker-controlled calldata
    into memory without any size restriction.

Location:

        Contract: CalldataRestrictionVul
        Function: workingMemoryExample()

Vulnerability Description:

        The vulnerable contract accepts a dynamic calldata array:

        uint256[] calldata _numbers

        and copies the full array into memory:

        uint256[] memory tempArray = _numbers;

        Although calldata itself is read-only and efficient,
        copying very large calldata arrays into memory
        may consume excessive gas.

        An attacker can submit extremely large arrays,
        forcing expensive memory allocation and copying.

Impact:

An attacker may:

- increase gas consumption
- trigger out-of-gas failures
- create denial-of-service conditions
- reduce protocol scalability

The risk becomes more severe if:

- arrays become extremely large
- additional processing logic is added
- nested loops are introduced

Proof of Concept:

        1. Deploy contract

        2. Call:

        workingMemoryExample(
            [1,2,3,... huge array]
        )

        3. OBSERVE:

        - heavy gas usage
        - expensive memory allocation
        - possible transaction failure

Root Cause:

The contract copies attacker-controlled
dynamic calldata into memory
without validating array size.

Vulnerable logic:

uint256[] memory tempArray = _numbers;

Large calldata inputs directly increase
memory allocation costs.

Recommendation:
        Validate calldata input size before copying.
        Example:
        require(_numbers.length <= 100, "Array too large");

*/

//patched code 
/*
contract CalldataRestriction {
    function modifyString(string calldata _name)external pure returns (string memory) {
        require(bytes(_name).length <= 100, "String too large");
        string memory tempName=_name; // Copy calldata into memory

       tempName=string.concat(tempName," ", "Gadekar"); //modify's string
        return tempName;
    }
}
*/
contract CalldataRestrictionVul {

    /*
        FUNCTION TO COPY STRING FROM
        CALLDATA TO MEMORY AND MODIFY IT
    */
    function modifyString(
        string calldata _message
    )
        external
        pure
        returns (string memory)
    {
        /*
            COPY CALLDATA STRING TO MEMORY

            Calldata is read-only.
            Memory is mutable.
        */
        string memory modifiedMessage = _message;

        /*
            Solidity strings cannot be modified
            character-by-character directly.

            So we return the copied string here.
        */
        return modifiedMessage;
    }
}