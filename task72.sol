// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Use repeated storage writes
CONCEPT: Expensive operations
=========================================================

OBJECTIVE

- Understand cost of repeated storage updates
- See how gas scales with state writes
- Learn why storage-heavy loops are dangerous
- Think like auditor about optimization risks

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Every storage write costs gas.

---------------------------------------------------------

Repeated storage writes inside loops:
become VERY expensive quickly.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Storage writes:

- modify blockchain state
- are permanently stored
- require high gas

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Repeated writes can cause:

- high transaction cost
- out-of-gas failure
- denial of service
- unscalable contracts

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Repeated writes appear in:

- reward updates
- counters
- staking systems
- voting systems
- accounting updates

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- write frequency
- loop-based storage updates
- redundant state changes
- gas inefficiencies
- optimization opportunities

=========================================================
EXPENSIVE STORAGE CONTRACT
=========================================================
*/
/*
contract RepeatedStorageWritesVul {

    /*
        STORAGE VARIABLES
    
    uint256 public counter;
    uint256 public lastValue;

    /*
        STORAGE ARRAY
    
    uint256[] public history;

    /*
    =====================================================
    HEAVY STORAGE WRITE LOOP
    =====================================================
    

    function heavyWrites(uint256 n) external {
        /*
            Loop controlled by user input.
        
        for ( uint256 i = 0; i < n; i++ ) {
            /*
            =============================================
            EXPENSIVE OPERATION 1
            =============================================

            Increment storage variable.
            
            counter++;

            /*
            =============================================
            EXPENSIVE OPERATION 2
            =============================================
            
            lastValue = i;

            /*
            =============================================
            EXPENSIVE OPERATION 3
            =============================================
            
            history.push(i);
        }
    }

    /*
    =====================================================
    OPTIMIZED VERSION
    =====================================================
    

    function optimizedWrites(uint256 n) external{
        /*
            Local variable (cheap).
        
        uint256 tempCounter = counter;

        uint256 tempValue = 0;

        uint256[] memory tempArray = new uint256[](n);

        for (  uint256 i = 0; i < n; i++ ) {
            /*
                ONLY memory operations inside loop.
    
            tempCounter++;

            tempValue = i;

            tempArray[i] = i;
        }

        /*
            SINGLE storage write operations.
        
        counter = tempCounter;
        lastValue = tempValue;

        /*
            Write array once (optional pattern).
        
        for (uint256 i = 0;i < n; i++) {
            history.push(tempArray[i]);
        }
    }

    /*
    =====================================================
    GET HISTORY LENGTH
    =====================================================
    

    function getHistoryLength() external view returns (uint256) {
        return history.length;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy RepeatedStorageWrites

=========================================================
TRACE:
heavyWrites(n)
=========================================================

INPUT:
n = 100

=========================================================
STEP 2
=========================================================

Loop starts:

i = 0

=========================================================
STEP 3
=========================================================

STORAGE WRITE #1:

counter++

=========================================================
STEP 4
=========================================================

STORAGE WRITE #2:

lastValue = 0

=========================================================
STEP 5
=========================================================

STORAGE WRITE #3:

history.push(0)

=========================================================
STEP 6
=========================================================

Repeat for i = 1 ... 99

=========================================================
IMPORTANT OBSERVATION
=========================================================

Each iteration performs:

---------------------------------------------------------
3 STORAGE WRITES
---------------------------------------------------------

Total:

100 × 3 = 300 writes

=========================================================
GAS IMPACT
=========================================================

This becomes VERY expensive.

---------------------------------------------------------

May lead to:

- high transaction cost
- gas limit issues
- execution failure

=========================================================
OPTIMIZED FLOW
=========================================================

CALL:
optimizedWrites(100)

=========================================================

STEP 1:
All computation happens in memory.

=========================================================
STEP 2
=========================================================

Only 2 final storage writes:

---------------------------------------------------------
counter = tempCounter
lastValue = tempValue

=========================================================
STEP 3
=========================================================

history updated in batch style.

=========================================================
IMPORTANT RESULT
=========================================================

Same outcome,
MUCH lower gas cost.

=========================================================
WHY THIS MATTERS
=========================================================

Storage writes are the MOST expensive
EVM operation.

---------------------------------------------------------

Reducing them improves scalability.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

=========================================================
TEST 1
=========================================================

Call:
heavyWrites(100)

---------------------------------------------------------

Observe:
HIGH gas usage

=========================================================
TEST 2
=========================================================

Call:
optimizedWrites(100)

---------------------------------------------------------

Observe:
lower gas usage

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

Repeated storage writes cause:

---------------------------------------------------------
GAS EXPLOSION
---------------------------------------------------------

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. LOOPED STORAGE WRITES
---------------------------------------------------------

very expensive pattern

---------------------------------------------------------
2. UNNECESSARY STATE UPDATES
---------------------------------------------------------

wasted gas

---------------------------------------------------------
3. USER CONTROLLED n
---------------------------------------------------------

can trigger DOS

---------------------------------------------------------
4. SCALABILITY FAILURE
---------------------------------------------------------

contract becomes unusable

=========================================================
ATTACK THINKING
=========================================================

Attackers may:

- increase n
- force heavy writes
- trigger gas exhaustion
- block execution

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors check:

- number of storage writes per call
- loop complexity
- worst-case gas cost
- user-controlled input size

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors calculate:

---------------------------------------------------------
writes_per_iteration × max_iterations
---------------------------------------------------------

to estimate risk.

=========================================================
BEST PRACTICES
=========================================================

- Minimize storage writes
- Batch updates
- Use memory for intermediate data
- Avoid per-iteration state changes
- Validate input size

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Limit n to 50
2. Compare gas usage
3. Add event logging instead of storage
4. Remove history array writes

BONUS:
Create event-based accounting system.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Storage writes are expensive
- Repeated writes increase gas linearly
- Loops with state changes are dangerous
- Memory is cheaper than storage
- Batch updates improve efficiency
- User-controlled loops can cause DOS
- Gas optimization is critical
- Auditors analyze write frequency
- Scalability depends on storage design
- Efficient state management is essential

=========================================================
*/

/*
Audit Report

Title: Unbounded Loop with Repeated Storage Writes in heavyWrites()

Severity: Medium

Reason:
The heavyWrites() function performs multiple storage writes inside a user-controlled loop.
As n increases, gas consumption grows linearly and may eventually exceed the block gas limit.

Location:

Contract: RepeatedStorageWritesVul
Function: heavyWrites(uint256 n)

Vulnerability Description:
The heavyWrites() function allows users to supply any value for n.
For every iteration, the function performs:

1. counter++
2. lastValue = i
3. history.push(i)

These are storage write operations, which are among the most expensive EVM operations.
Because the loop is controlled by user input and has no upper limit, an attacker can provide a very large n value,
causing excessive gas consumption or transaction failure.

Impact:

- Excessive transaction cost
- Out-of-gas (OOG) failures
- Denial of Service (DOS)
- Poor scalability
- Contract functions may become unusable for large inputs

Proof of Concept:
        1. Deploy RepeatedStorageWritesVul.
        2. Call:
        heavyWrites(100)

        Result:
        Transaction succeeds with high gas usage.

        3. Call:
        heavyWrites(1000)
        Result:
        Much higher gas consumption.

        4. Call:
        heavyWrites(10000)

Result:
Transaction may fail due to out-of-gas depending on gas limits.

Root Cause:
The function performs three storage writes per iteration:

counter++;
lastValue = i;
history.push(i);

Additionally, n is fully controlled by the caller and no maximum limit is enforced.

Recommendation:

Restrict the maximum value of n.
Move calculations to memory whenever possible.
Avoid repeated storage writes inside loops.
Use batching or event logging instead of storing large amounts of data.

Example:
require(n <= 50, "Batch size too large");
*/

//patched code 

contract RepeatedStorageWritesVul {

    /*
    =====================================================
    STORAGE VARIABLES
    =====================================================
    */

    uint256 public counter;
    uint256 public lastValue;

    /*
        Maximum allowed loop size.
    */
    uint256 public constant MAX_N = 50;

    /*
    =====================================================
    EVENTS
    =====================================================
    */

    event ValueUpdated(
        uint256 indexed index,
        uint256 value
    );

    event BatchCompleted(
        uint256 totalIterations,
        uint256 finalCounter,
        uint256 finalValue
    );

    /*
    =====================================================
    HEAVY STORAGE WRITE VERSION
    =====================================================
    */

    function heavyWrites(uint256 n) external {

        require(n <= MAX_N, "Maximum 50 iterations");

        for (uint256 i = 0; i < n; i++) {

            /*
                Storage write 1
            */
            counter++;

            /*
                Storage write 2
            */
            lastValue = i;

            /*
                EVENT LOGGING

                Instead of storing every value in
                a history array, emit an event.
            */
            emit ValueUpdated(i, i);
        }

        emit BatchCompleted(
            n,
            counter,
            lastValue
        );
    }

    /*
    =====================================================
    OPTIMIZED VERSION
    =====================================================
    */

    function optimizedWrites(uint256 n) external {

        require(n <= MAX_N, "Maximum 50 iterations");

        /*
            Use local variables inside the loop.
        */
        uint256 tempCounter = counter;
        uint256 tempValue = lastValue;

        for (uint256 i = 0; i < n; i++) {

            /*
                Memory/stack operations.
            */
            tempCounter++;
            tempValue = i;

            /*
                Log the value instead of storing it
                in the history array.
            */
            emit ValueUpdated(i, i);
        }

        /*
            Only two storage writes after
            the loop.
        */
        counter = tempCounter;
        lastValue = tempValue;

        emit BatchCompleted(
            n,
            tempCounter,
            tempValue
        );
    }

    /*
    =====================================================
    GAS COMPARISON
    =====================================================
    */

    function compareGas(uint256 n)
        external
        view
        returns (
            uint256 heavyStorageWrites,
            uint256 optimizedStorageWrites
        )
    {
        require(n <= MAX_N, "Maximum 50 iterations");

        /*
            Educational estimate.

            Heavy version:
            roughly 2 storage updates per iteration.

            Optimized version:
            only 2 storage updates after the loop.
        */

        heavyStorageWrites = n * 2;
        optimizedStorageWrites = 2;
    }

    /*
    =====================================================
    GET CURRENT VALUES
    =====================================================
    */

    function getValues()
        external
        view
        returns (
            uint256 currentCounter,
            uint256 currentLastValue
        )
    {
        return (counter, lastValue);
    }
}