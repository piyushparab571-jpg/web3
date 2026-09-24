// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Stress test repeated calls
CONCEPT: Stability testing
=========================================================

OBJECTIVE

- Understand system behavior under repeated calls
- Learn how state grows over time
- Observe gas accumulation risks
- Think like auditor performing stress tests

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Repeated function calls simulate real-world load.

---------------------------------------------------------

Each call:
modifies state
consumes gas
adds cumulative load

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Stress testing is used to detect:

- gas exhaustion
- storage bloating
- performance degradation
- DOS risks

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

In real systems:

- users call contracts repeatedly
- bots interact heavily
- protocols accumulate state over time

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors test:

- repeated execution stability
- state growth over time
- gas scaling behavior
- worst-case repeated usage
- storage accumulation

=========================================================
STRESS TEST CONTRACT
=========================================================
*/
/*
contract StressTestCallsVul {
    /*
        STORAGE STATE
    
    uint256 public counter;
    uint256 public totalCalls;
    uint256[] public history;

    /*
    =====================================================
    SINGLE STATE UPDATE FUNCTION
    =====================================================
    

    function singleCall(uint256 value) public {

        /*
            Increment counters.
        
        counter++;
        totalCalls++;

        /*
            Store value.
        
        history.push(value);
    }

    /*
    =====================================================
    STRESS TEST FUNCTION (LOOPED CALLS)
    =====================================================
    

    function stressTest(uint256 times) external {

        /*
        =================================================
        WARNING:
        =================================================

        This simulates repeated usage.

        Gas grows linearly with `times`.
        

        for (uint256 i = 0; i < times; i++ ) {

            /*
                Repeated internal execution.
            
            singleCall(i);
        }
    }

    /*
    =====================================================
    DIRECT CALL STRESS (EXTERNAL STYLE SIMULATION)
    =====================================================
    

    function externalStyleStress(uint256 times) external{

        for ( uint256 i = 0;  i < times; i++ ) {
            /*
                Simulates repeated user interactions.
            
            this.singleCall(i);
        }
    }

    /*
    =====================================================
    RESET STATE (FOR TESTING ONLY)
    =====================================================
    

    function reset() external {

        counter = 0;
        totalCalls = 0;

        delete history;
    }

    /*
    =====================================================
    GET HISTORY SIZE
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
Deploy StressTestCalls

=========================================================
TRACE:
stressTest(5)
=========================================================

STEP 1:
i = 0

---------------------------------------------------------

singleCall(0)

=========================================================
STEP 2
=========================================================

STATE CHANGES:

counter++
totalCalls++
history.push(0)

=========================================================
STEP 3
=========================================================

i = 1 → repeat

=========================================================
STEP 4
=========================================================

i = 2 → repeat

=========================================================
STEP 5
=========================================================

i = 3 → repeat

=========================================================
STEP 6
=========================================================

i = 4 → repeat

=========================================================
FINAL STATE
=========================================================

---------------------------------------------------------
counter
---------------------------------------------------------

= 5

---------------------------------------------------------
totalCalls
---------------------------------------------------------

= 5

---------------------------------------------------------
history
---------------------------------------------------------

[0,1,2,3,4]

=========================================================
IMPORTANT OBSERVATION
=========================================================

Each loop iteration:

---------------------------------------------------------
1 storage increment
1 storage increment
1 array push
---------------------------------------------------------

Gas grows quickly.

=========================================================
TRACE:
externalStyleStress()
=========================================================

STEP 1:
this.singleCall(i)

---------------------------------------------------------

IMPORTANT:

This creates EXTERNAL CALLS to same contract.

=========================================================
STEP 2
=========================================================

Execution context switches:

Contract → Contract (external call)

=========================================================
STEP 3
=========================================================

Each iteration:

- external call overhead
- higher gas usage
- more execution cost

=========================================================
IMPORTANT DIFFERENCE
=========================================================

---------------------------------------------------------
singleCall()
---------------------------------------------------------

cheap internal call

---------------------------------------------------------

---------------------------------------------------------
this.singleCall()
---------------------------------------------------------

expensive external call

=========================================================
STRESS TEST INSIGHT
=========================================================

Repeated calls reveal:

- gas scaling issues
- storage growth
- execution bottlenecks
- stability limits

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

=========================================================
TEST 1
=========================================================

Call:
stressTest(10)

EXPECTED:
fast execution

=========================================================
STEP 2
=========================================================

Call:
stressTest(1000)

EXPECTED:
high gas usage / possible failure

=========================================================
TEST 3
=========================================================

Call:
externalStyleStress(10)

EXPECTED:
higher gas than internal version

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

Repeated calls can cause:

---------------------------------------------------------
GAS DOS
---------------------------------------------------------

AND

---------------------------------------------------------
STORAGE BLOAT
---------------------------------------------------------

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. UNBOUNDED REPEATED CALLS
---------------------------------------------------------

can exhaust gas

---------------------------------------------------------
2. STORAGE GROWTH
---------------------------------------------------------

array keeps increasing

---------------------------------------------------------
3. EXTERNAL CALL OVERHEAD
---------------------------------------------------------

increases gas significantly

---------------------------------------------------------
4. SYSTEM INSTABILITY
---------------------------------------------------------

becomes unscalable under load

=========================================================
ATTACK THINKING
=========================================================

Attackers may:

- spam function calls
- increase gas usage
- force storage growth
- degrade protocol performance

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors test:

- repeated call behavior
- worst-case gas usage
- storage scaling
- external call risks
- system stability under load

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors simulate:

---------------------------------------------------------
HIGH-FREQUENCY USAGE
---------------------------------------------------------

to find failure points.

=========================================================
BEST PRACTICES
=========================================================

- Avoid unbounded loops
- Minimize storage writes per call
- Prefer batch processing
- Avoid unnecessary external calls
- Design for scalability

=========================================================
MINI CHALLENGE
=========================================================

Modify contract:

1. Limit stressTest to 100 calls
2. Replace storage writes with events
3. Compare internal vs external call gas
4. Add gas measurement logging

BONUS:
Create batch-stress-safe architecture.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Repeated calls simulate real load
- Gas grows with execution frequency
- Storage accumulates over time
- External calls are more expensive
- Stress testing reveals vulnerabilities
- System scalability must be designed
- Auditors simulate heavy usage scenarios
- Unbounded execution is dangerous
- Storage + loops = high risk pattern
- Stability testing is critical for security

=========================================================
*/

/*
Audit Report

Title: Unbounded Loop and External Self-Call Leading to Gas Denial of Service

Severity: Medium

Reason:
User-controlled loop iterations can consume excessive gas and make protocol functions unusable.

Location:

Contract: StressTestCallsVul
Functions:
    stressTest(uint256 times)
    externalStyleStress(uint256 times)

Vulnerability Description:

The stressTest() and externalStyleStress() functions allow users to provide an arbitrary value for the times parameter.
Both functions execute loops based on user input.
The stressTest() function repeatedly performs storage updates through singleCall().

The externalStyleStress() function additionally performs expensive external self-calls using:

this.singleCall(i);

inside the loop.
Because no upper limit exists for times, gas consumption grows linearly as the value increases.
Large values may cause transactions to run out of gas and revert.

Impact:

An attacker can trigger excessive gas consumption by supplying very large values for times.
This can result in:

high transaction costs
out-of-gas failures
storage bloat
denial of service conditions

If these functions were used in critical protocol operations such as:

reward distribution
staking updates
governance processing

then protocol functionality could become unavailable due to gas exhaustion.

Proof of Concept:
        1.Deploy the contract.
        2.User A calls:
            stressTest(10)
        Execution succeeds.
        3.An attacker calls:
            stressTest(100000)
        Transaction consumes excessive gas and may fail.
        4.User A calls:
        externalStyleStress(10)
        5.Execution succeeds.
        6.An attacker calls:
            externalStyleStress(100000)
        Transaction consumes significantly more gas due to repeated external calls and may fail.

Root Cause:

The functions use user-controlled loop counts without validation.
No require() statement limits the maximum value of times.
Additionally, externalStyleStress() performs unnecessary external self-calls through:
this.singleCall(i);
which significantly increases gas consumption.

Recommendation:
Restrict the maximum value of times.

Example:

require(times <= 100, "Too many calls");
Replace external self-calls with direct internal calls where possible.
*/

//patched code 
contract StressTestCallsVul {
    //STORAGE STATE
    uint256 public counter;
    uint256 public totalCalls;
    uint256 public constant MAX_CALLS = 100;
    //EVENTS
    event CallLogged(
        uint256 indexed value,
        uint256 counterValue
    );
    event GasMeasurement(
        string testType,
        uint256 calls,
        uint256 gasUsed
    );
    //SINGLE STATE UPDATE FUNCTION
    function singleCall(uint256 value) public {
        counter++;
        totalCalls++;
        //Event replaces the history storage write.

        emit CallLogged(value, counter);
    }
    //INTERNAL CALL STRESS TEST
    function stressTest(uint256 times) external {
        require(times <= MAX_CALLS, "Maximum 100 calls");
        //Record gas at the beginning.
        uint256 gasStart = gasleft();
        for (uint256 i = 0; i < times; i++) {
            //INTERNAL-STYLE CALL.
            singleCall(i);
        }
        //calculate gas consumed.
        uint256 gasUsed = gasStart - gasleft();
        emit GasMeasurement(
            "Internal Call",
            times,
            gasUsed
        );
    }

    /*
    =====================================================
    GAS COMPARISON
    =====================================================
    */

    function compareGas(uint256 times)
        external
        view
        returns (
            uint256 estimatedInternalGas,
            uint256 estimatedExternalGas
        )
    {
        require(times <= MAX_CALLS, "Maximum 100 calls");

        /*
            Approximate values for comparison.
            Actual transaction gas should be checked
            from the transaction receipt in Remix.
        */

        estimatedInternalGas = times * 5000;
        estimatedExternalGas = times * 7000;
    }

    /*
    =====================================================
    RESET STATE
    =====================================================
    */

    function reset() external {

        counter = 0;
        totalCalls = 0;
    }

    /*
    =====================================================
    GET CURRENT STATE
    =====================================================
    */

    function getState()
        external
        view
        returns (
            uint256 currentCounter,
            uint256 currentTotalCalls
        )
    {
        return (counter, totalCalls);
    }
}