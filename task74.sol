// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Call function with zero values
CONCEPT: Edge-case behavior
=========================================================

OBJECTIVE

- Understand how contracts behave with zero inputs
- Learn why edge cases matter in auditing
- Observe storage + logic behavior with 0
- Think like auditor checking boundary conditions

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Zero is NOT "nothing" in Solidity.

---------------------------------------------------------

0 is a valid input and can still:

- change state
- trigger logic
- affect storage
- break assumptions

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Many bugs happen because developers assume:

"value > 0 always"

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Zero-value edge cases can cause:

- logic bypass
- division errors
- unnecessary state changes
- incorrect accounting

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors check:

- zero input handling
- boundary conditions
- default values
- uninitialized logic
- false assumptions

=========================================================
ZERO VALUE CONTRACT
=========================================================
*/
/*
contract ZeroValueEdgeCaseVul {

    /*
        STORAGE VARIABLES
    
    uint256 public total;
    uint256 public lastInput;
    uint256 public counter;

    /*
        STORAGE ARRAY
    
    uint256[] public values;

    /*
    =====================================================
    FUNCTION: ADD VALUE (INCLUDING ZERO)
    =====================================================
    

    function addValue(uint256 value) public {

        /*
        =================================================
        EDGE CASE: ZERO INPUT
        =================================================
        

        lastInput = value;

        /*
            Even if value = 0,
            state is still updated.
        

        total += value;

        /*
            Storage write ALWAYS happens.
        
        values.push(value);

        /*
            Counter always increases,
            even for zero.
        
        counter++;
    }

    /*
    =====================================================
    SAFE VERSION (ZERO CHECK)
    =====================================================
    

    function addValueSafe(uint256 value)
        external
    {

        /*
            Ignore zero values.
        
        require(value > 0, "Zero not allowed");

        lastInput = value;
        total += value;
        values.push(value);
        counter++;
    }

    /*
    =====================================================
    ZERO TEST FUNCTION
    =====================================================
    

    function testZero()
        external
    {

        /*
            Explicit zero input calls.
        
        addValue(0);
        addValue(0);
        addValue(0);
    }

    /*
    =====================================================
    GET ARRAY LENGTH
    =====================================================
    

    function getLength()
        external
        view
        returns (uint256)
    {

        return values.length;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy ZeroValueEdgeCase

=========================================================
TRACE:
addValue(0)
=========================================================

STEP 1:
value = 0

---------------------------------------------------------

lastInput = 0

=========================================================
STEP 2
=========================================================

total += 0

---------------------------------------------------------

NO change in total

=========================================================
STEP 3
=========================================================

values.push(0)

---------------------------------------------------------

IMPORTANT:
ZERO is still stored in blockchain.

=========================================================
STEP 4
=========================================================

counter++

---------------------------------------------------------

counter increases even for zero input.

=========================================================
FINAL STATE AFTER 3 CALLS
=========================================================

CALL:
testZero()

---------------------------------------------------------
counter
---------------------------------------------------------

= 3

---------------------------------------------------------
values
---------------------------------------------------------

[0, 0, 0]

---------------------------------------------------------
total
---------------------------------------------------------

= 0

---------------------------------------------------------
lastInput
---------------------------------------------------------

= 0

=========================================================
IMPORTANT OBSERVATION
=========================================================

Zero STILL causes:

- storage writes
- gas consumption
- state updates

=========================================================
SAFE VERSION BEHAVIOR
=========================================================

CALL:
addValueSafe(0)

=========================================================

STEP 1:
require(value > 0)

---------------------------------------------------------

value = 0 → REVERT

=========================================================
RESULT
=========================================================

Transaction fails BEFORE state change.

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

Zero values are:

---------------------------------------------------------
VALID INPUTS
---------------------------------------------------------

BUT often:

---------------------------------------------------------
LOGICALLY IGNORED BY SYSTEMS
---------------------------------------------------------

=========================================================
COMMON BUGS FROM ZERO VALUES
=========================================================

---------------------------------------------------------
1. DIVISION BY ZERO
---------------------------------------------------------

if (a / value)

---------------------------------------------------------

---------------------------------------------------------
2. LOGIC BYPASS
---------------------------------------------------------

if (value > 0) { ... }

---------------------------------------------------------

---------------------------------------------------------
3. UNEXPECTED STORAGE WRITE
---------------------------------------------------------

storing useless zero values

---------------------------------------------------------

---------------------------------------------------------
4. INCORRECT ACCOUNTING
---------------------------------------------------------

totals not updated correctly

=========================================================
ATTACK THINKING
=========================================================

Attackers may:

- send zero values repeatedly
- bloat storage arrays
- trigger unnecessary gas costs
- exploit missing zero checks

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors check:

- is zero handled?
- does zero cause state change?
- can zero break logic?
- is validation missing?

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors test:

---------------------------------------------------------
BOUNDARY INPUTS:
0, 1, max uint256
---------------------------------------------------------

=========================================================
BEST PRACTICES
=========================================================

- Validate inputs when needed
- Handle zero explicitly
- Avoid storing useless values
- Document zero behavior
- Test boundary conditions

=========================================================
MINI CHALLENGE
=========================================================

Modify contract:

1. Reject zero and negative-like edge cases
2. Compare gas usage with/without zero validation
3. Add event logging instead of storage push
4. Handle max uint256 input safely

BONUS:
Create full edge-case testing suite.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Zero is a valid Solidity value
- Zero still consumes gas if stored
- State updates happen even for zero
- Edge cases cause real vulnerabilities
- Input validation is critical
- Auditors test boundary conditions
- Storage grows even with useless values
- Safe design avoids unnecessary writes
- Zero can break assumptions
- Robust contracts handle all inputs

=========================================================
*/

/*
Audit Report

Title: Zero Value Edge Case Leading to Unnecessary State Changes

Severity: Low 

Reason:
Zero input is treated as valid and still triggers storage writes
and state updates, leading to unnecessary gas consumption and
potential logic misuse.

Location:

Contract: ZeroValueEdgeCaseVul
Function: addValue(uint256 value), testZero()

Vulnerability Description:

The contract does not validate zero-value inputs.
As a result, calling addValue(0) still:
- updates lastInput
- writes to storage array
- increments counter

Even though the value has no real business meaning,
it still modifies blockchain state.

The function testZero() further demonstrates repeated
zero-value submissions.

Impact:

An attacker or careless user can repeatedly send zero values,
leading to:

- unnecessary storage growth
- wasted gas consumption
- polluted historical data
- incorrect assumptions in analytics or accounting systems

If downstream logic assumes values are always meaningful (> 0),
this can lead to incorrect protocol behavior.

Proof of Concept:
    1.Deploy the contract.
    2.Call:
        addValue(0)
    3.Result:
    State is updated with zero value.
    4.Call multiple times:
        testZero()

Result:
    counter = 3
    values = [0, 0, 0]
    total = 0

Root Cause:

The function does not validate input before writing to storage.
No condition exists such as:
require(value > 0) to prevent zero-value writes.

Vulnerable code:

function addValue(uint256 value) public {
    lastInput = value;
    total += value;
    values.push(value);
    counter++;
}

Recommendation:
Add input validation to reject zero values
if they are not required by business logic.

Example fix:
require(value > 0, "Zero not allowed");
*/
//patched code 
contract ZeroValueEdgeCaseVul {

    uint256 public total;
    uint256 public lastInput;
    uint256 public counter;

    // Kept for gas comparison / reference.
    uint256[] public values;

    event ValueAdded(
        uint256 indexed value,
        uint256 newTotal,
        uint256 newCounter
    );

    /*
     * =====================================================
     * VERSION 1: NO ZERO VALIDATION
     * =====================================================
     *
     * Useful as a baseline for gas comparison.
     *
     * NOTE:
     * Solidity 0.8+ automatically reverts if total + value
     * overflows uint256.
     */
    function addValue(uint256 value) public {
        lastInput = value;
        total += value;
        values.push(value);
        counter++;
    }

    /*
     * =====================================================
     * VERSION 2: ZERO VALIDATION + STORAGE ARRAY
     * =====================================================
     */
    function addValueSafe(uint256 value) external {
        require(value > 0, "Zero not allowed");

        // Solidity 0.8+ protects this addition from overflow.
        total += value;

        lastInput = value;
        values.push(value);
        counter++;

        emit ValueAdded(value, total, counter);
    }

    /*
     * =====================================================
     * VERSION 3: ZERO VALIDATION + EVENT INSTEAD OF ARRAY
     * =====================================================
     *
     * This avoids the permanent storage cost of values.push().
     * Events are stored in transaction logs rather than contract
     * storage.
     */
    function addValueEvent(uint256 value) external {
        require(value > 0, "Zero not allowed");

        // Solidity 0.8+ reverts automatically on overflow.
        total += value;

        lastInput = value;
        counter++;

        emit ValueAdded(value, total, counter);
    }

    /*
     * =====================================================
     * VERSION 4: EXPLICIT MAX-UINT VALIDATION
     * =====================================================
     *
     * Solidity 0.8+ already performs this check, but this
     * version makes the intended behavior explicit.
     */
    function addValueChecked(uint256 value) external {
        require(value > 0, "Zero not allowed");
        require(
            value <= type(uint256).max - total,
            "Total overflow"
        );

        total += value;
        lastInput = value;
        counter++;

        emit ValueAdded(value, total, counter);
    }

    /*
     * =====================================================
     * ZERO TEST
     * =====================================================
     *
     * This will revert on the first call to addValueSafe().
     */
 

    /*
     * =====================================================
     * MAX UINT TEST
     * =====================================================
     *
     * The first call succeeds if total == 0.
     * A subsequent addition that exceeds uint256.max reverts.
     */


    /*
     * =====================================================
     * ARRAY LENGTH
     * =====================================================
     */
    function getLength() external view returns (uint256) {
        return values.length;
    }

    /*
     * =====================================================
     * REMAINING CAPACITY
     * =====================================================
     */
    function remainingCapacity() external view returns (uint256) {
        return type(uint256).max - total;
    }
}