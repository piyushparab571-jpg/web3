// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Pass huge calldata array
CONCEPT: Gas impact
=========================================================

OBJECTIVE

- Understand calldata gas efficiency
- Compare large input handling costs
- Learn why calldata is preferred over memory
- Observe gas impact of large arrays

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

calldata = read-only external input

---------------------------------------------------------

Huge calldata arrays:
do NOT get copied into memory automatically.

---------------------------------------------------------

This makes calldata cheaper than memory.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Gas cost increases with:

- array size
- decoding complexity
- storage writes (if any)
- loops over data

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Large inputs appear in:

- batch transfers
- airdrops
- multicall systems
- oracle feeds
- on-chain aggregation

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- calldata size limits
- loop processing cost
- gas scaling behavior
- DOS via large inputs

=========================================================
CALDATA CONTRACT
=========================================================
*/
/*
contract CalldataGasVul {
    /*
        STORE PROCESSED SUM
    
    uint256 public totalSum;
    /*
        TRACK ELEMENT COUNT
    
    uint256 public totalElements;
    /*
    =====================================================
    PROCESS HUGE CALDATA ARRAY
    =====================================================
    
    function processCalldataArray( uint256[] calldata data )  external {
        /*
            Local variable in stack.
        
        uint256 sum = 0;

        /*
        =================================================
        LOOP OVER CALDATA ARRAY
        =================================================
        

        for (uint256 i = 0;i < data.length;i++) {
            /*
                READ FROM CALDATA

                Cheap read-only access.
            
            sum += data[i];

            /*
                Storage update per iteration.
                (expensive part)
            
            totalElements++;
        }

        /*
            One final storage write.
        
        totalSum = sum;
    }

    /*
    =====================================================
    COMPARE MEMORY VERSION
    =====================================================
    

    function processMemoryArray(uint256[] memory data) public pure returns (uint256){
        uint256 sum = 0;
        for (  uint256 i = 0;  i < data.length;  i++ ) {
            /*
                Memory access.
            
            sum += data[i];
        }
        return sum;
    }

    /*
    =====================================================
    GET TOTAL ELEMENTS
    =====================================================
    

    function getTotalElements() external view returns (uint256){
        return totalElements;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy CalldataGas

=========================================================
TRACE:
processCalldataArray()
=========================================================

INPUT:
Huge uint256[] calldata

Example size:
1000 elements

=========================================================
STEP 2
=========================================================

Function starts.

---------------------------------------------------------

sum = 0

=========================================================
STEP 3
=========================================================

Loop begins:
i = 0

=========================================================
STEP 4
=========================================================

Read:
data[0]

---------------------------------------------------------

Add to sum.

---------------------------------------------------------

sum += data[0]

=========================================================
STEP 5
=========================================================

Storage write:

totalElements++

---------------------------------------------------------

IMPORTANT:
This is expensive.

=========================================================
STEP 6
=========================================================

Loop continues:

i = 1 ... 999

=========================================================
IMPORTANT BEHAVIOR
=========================================================

Each iteration:

---------------------------------------------------------
READ
---------------------------------------------------------

from calldata (cheap)

---------------------------------------------------------
WRITE
---------------------------------------------------------

to storage (expensive)

=========================================================
FINAL STEP
=========================================================

After loop:

totalSum = sum

=========================================================
FINAL RESULT
=========================================================

---------------------------------------------------------
totalElements
---------------------------------------------------------

= number of elements processed

---------------------------------------------------------
totalSum
---------------------------------------------------------

= sum of all values

=========================================================
WHY CALDATA IS IMPORTANT
=========================================================

calldata is:

---------------------------------------------------------
READ-ONLY
---------------------------------------------------------

AND

---------------------------------------------------------
NO COPYING INTO MEMORY
---------------------------------------------------------

=========================================================
GAS ADVANTAGE
=========================================================

Compared to memory:

- NO extra copy cost
- NO allocation overhead
- DIRECT access

=========================================================
BUT IMPORTANT
=========================================================

Gas still increases due to:

---------------------------------------------------------
LOOP PROCESSING
---------------------------------------------------------

AND

---------------------------------------------------------
STORAGE WRITES
---------------------------------------------------------

=========================================================
MEMORY VS CALDATA COMPARISON
=========================================================

---------------------------------------------------------
calldata
---------------------------------------------------------

- cheapest input
- read-only
- no copying
- best for external inputs

=========================================================

---------------------------------------------------------
memory
---------------------------------------------------------

- copied data
- more gas than calldata
- mutable

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

=========================================================
TEST 1
=========================================================

Call:
processCalldataArray([1,2,3,...1000])


---------------------------------------------------------

Observe:
moderate gas usage

=========================================================
TEST 2
=========================================================
 
Call:
processMemoryArray([...1000 values...])

---------------------------------------------------------

Observe:
higher gas than calldata version

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

Large calldata inputs can cause:

---------------------------------------------------------
GAS DOS
---------------------------------------------------------

if processing is heavy.

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. LARGE INPUT LOOPS
---------------------------------------------------------

Gas scales linearly.

---------------------------------------------------------
2. STORAGE INSIDE LOOP
---------------------------------------------------------

Major gas explosion.

---------------------------------------------------------
3. UNBOUNDED CALDATA SIZE
---------------------------------------------------------

Attacker can send huge arrays.

---------------------------------------------------------
4. DENIAL OF SERVICE
---------------------------------------------------------

Function becomes too expensive.

=========================================================
ATTACK THINKING
=========================================================

Attackers may:

- send huge arrays
- force gas exhaustion
- exploit loop scaling
- DOS processing functions

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors check:

- calldata size limits
- loop complexity O(n)
- storage writes per iteration
- gas upper bounds
- worst-case execution cost

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors estimate:

---------------------------------------------------------
MAX ARRAY SIZE IMPACT
---------------------------------------------------------

AND

---------------------------------------------------------
BLOCK GAS LIMIT SAFETY
---------------------------------------------------------

=========================================================
BEST PRACTICES
=========================================================

- Use calldata for external inputs
- Avoid storage writes in loops
- Batch processing carefully
- Enforce input size limits
- Prefer O(1) or O(log n) designs

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Limit array size to 500
2. Compare 500 vs 1000 gas usage
3. Remove storage writes in loop
4. Add batch processing function

BONUS:
Create gas-safe streaming processor.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Calldata is cheapest input type
- Large arrays increase gas linearly
- Storage writes dominate gas cost
- calldata avoids memory copy cost
- loops over large inputs are expensive
- gas scaling can cause DOS
- auditors analyze worst-case input size
- calldata is read-only external input
- optimization reduces execution cost
- input validation is critical for security

=========================================================
*/

/*
Audit Report

Title: Unbounded Calldata Array Processing Causing Gas Denial of Service

Severity: Medium

Reason:
The processCalldataArray() function accepts a dynamic calldata array with no size limit and performs
storage updates during every iteration. Large arrays can cause excessive gas consumption and transaction failures.

Location:

Contract: CalldataGasVul
Function: processCalldataArray()

Vulnerability Description:

The function processes every element inside the provided calldata array:
    for (uint256 i = 0; i < data.length; i++) {
        sum += data[i];
        totalElements++;
    }

Since there is no maximum size restriction on data.length, an attacker can submit an extremely large array.
Additionally, totalElements++ performs a storage write during every iteration, significantly increasing gasconsumption.
As array size grows, gas consumption grows linearly (O(n)) and may eventually exceed the block gas limit.

Impact:

- Transaction may run out of gas.
- Function becomes uncallable for very large arrays.
- Potential Denial of Service (DoS).
- Users may waste gas on failed transactions.
- Protocol scalability is reduced.

Proof of Concept:
        1. Deploy CalldataGasVul.
        2. Call:
            processCalldataArray([1,2,3,...1000])
        Transaction succeeds.

        3. Call:
            processCalldataArray([1,2,3,...10000])
        Gas consumption increases dramatically.

        4. Call with an even larger array.
        Transaction eventually reverts with:
            out of gas

Root Cause:

The contract performs:
- Unbounded iteration over calldata.
- Storage writes inside the loop.
- No validation on maximum array size.

The following line is the primary cause:

    totalElements++;

executed for every element processed.

Recommendation:

1. Restrict maximum array size.
2. Avoid storage writes inside loops.
3. Batch updates after loop completion.
4. Process large datasets in chunks.

Example:

    require(data.length <= 500, "Array too large");
*/
//patched code 
contract CalldataGasVul {
    //STORE PROCESSED SUM
    uint256 public totalSum;
    //MAXIMUM ARRAY SIZE
    uint256 public constant MAX_SIZE = 500;
    /*
    ========================================
    PROCESS MAXIMUM 500 CALLdata VALUES
    ========================================
    */
    function processCalldataArray(
        uint256[] calldata data
    ) external {
        //limit input to 500 elements
        require(data.length <= MAX_SIZE, "Maximum 500 elements");
        uint256 sum = 0;
        /*
        LOOP OVER CALLdATA ARRAY\
        No storage write inside the loop.
        */
        for (uint256 i = 0; i < data.length; i++) {
            //Readd directly from calldata.
            sum += data[i];
        }
        /*
        Only ONE storage write aftr
        the loop is completed
        */
        totalSum = sum;
    }
    /*
    ===================================
    COMPARE 500 VS 1000
    ===================================
    */
    function proccess500(
        uint256[] calldata data
    ) external {
        require(data.length <= 500, "Maximum 500 elements");
        uint256 sum = 0;
        for (uint256 i = 0; i < data.length; i++) {
            sum += data[i];
        } 
        totalSum = sum;
    }
    /*
    This function is only for gas comparision.
    It allows 1000 elements so you can compare
    the gas cost of processing 500 vs 1000 values.
    */
    function process1000(
        uint256[] calldata data
    ) external {
        require(data.length <= 1000, "Maximum 1000 elements");
        uint256 sum = 0;
        for (uint256 i = 0; i < data.length; i++) {
            sum += data[i];
        }
        totalSum = sum;
    }
      /*
    =====================================================
    BATCH PROCESSING
    =====================================================
    */

    function batchProcess(
        uint256[][] calldata batches
    ) external {

        uint256 grandTotal = 0;

        /*
            Process multiple arrays in batches.
        */
        for (uint256 i = 0; i < batches.length; i++) {

            require(
                batches[i].length <= MAX_SIZE,
                "Batch too large"
            );

            for (
                uint256 j = 0;
                j < batches[i].length;
                j++
            ) {
                grandTotal += batches[i][j];
            }
        }

        /*
            One storage write after
            all batches are processed.
        */
        totalSum = grandTotal;
    }

    /*
    =====================================================
    MEMORY VERSION
    =====================================================
    */

    function processMemoryArray(
        uint256[] memory data
    ) external pure returns (uint256) {

        uint256 sum = 0;

        for (uint256 i = 0; i < data.length; i++) {
            sum += data[i];
        }

        return sum;
    }

}