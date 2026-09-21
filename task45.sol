// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Use modifier after function
CONCEPT: Post-execution flow
=========================================================

OBJECTIVE

- Learn modifier post-execution behavior
- Understand code execution after _;
- Learn execution wrapping flow
- Understand advanced modifier architecture

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Modifiers can execute:
- BEFORE function body
- AFTER function body

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

The special symbol:

_;

represents:
"insert function body here"

---------------------------------------------------------

Code:
BEFORE _;  -> pre-execution
AFTER  _;  -> post-execution

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Post-execution modifiers are used for:

- cleanup logic
- logging
- invariant checks
- reentrancy unlocking
- accounting verification

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Post-execution logic appears in:

- ReentrancyGuard
- fee settlement systems
- invariant validation
- logging frameworks
- protocol accounting

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- hidden post-state mutations
- execution ordering
- invariant enforcement
- modifier side effects
- reentrancy lock release

=========================================================
*/
/*
contract PostExecutionModifierVul {

    /*
        OWNER ADDRESS
    
    address public owner;

    /*
        EXECUTION STATUS
    
    bool public locked;

    /*
        LAST ACTION TRACKER
    
    string public lastAction;

    /*
        USER BALANCES
    
    mapping(address => uint256) public balances;

    /*
        CONSTRUCTOR
    
    constructor() {

        owner = msg.sender;
    }

    /*
    =====================================================
    MODIFIER WITH POST-EXECUTION LOGIC
    =====================================================
    
    modifier trackExecution() {

        /*
            PRE-EXECUTION LOGIC
        
        lastAction = "Function started";

        /*
            FUNCTION BODY EXECUTES HERE
        
        _;

        /*
            POST-EXECUTION LOGIC

            Executes AFTER function body.
        
        lastAction = "Function completed";
    }

    /*
    =====================================================
    REENTRANCY-STYLE MODIFIER
    =====================================================
    

    modifier noReentrant() {

        /*
            PRE-EXECUTION CHECK
        
        require(
            locked == false,
            "Reentrant call blocked"
        );

        /*
            LOCK BEFORE FUNCTION EXECUTION
        
        locked = true;

        /*
            FUNCTION BODY EXECUTES HERE
        
        _;

        /*
            UNLOCK AFTER FUNCTION EXECUTION

            POST-EXECUTION FLOW
        
        locked = false;
    }

    /*
    =====================================================
    FUNCTION USING POST MODIFIER
    =====================================================
    

    function deposit(
        uint256 _amount
    )
        external
        trackExecution
    {

        /*
            Function body.
        
        require(
            _amount > 0,
            "Invalid amount"
        );

        balances[msg.sender] += _amount;
    }

    /*
    =====================================================
    FUNCTION USING REENTRANCY-STYLE MODIFIER
    =====================================================
    

    function secureDeposit(
        uint256 _amount
    )
        external
        noReentrant
    {

        /*
            Function executes while locked=true.
        
        require(
            _amount > 0,
            "Invalid amount"
        );

        balances[msg.sender] += _amount;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
deposit(50)

=========================================================

STEP 1:
Modifier executes FIRST.

---------------------------------------------------------

trackExecution()

---------------------------------------------------------

PRE-EXECUTION:

lastAction =
"Function started"

---------------------------------------------------------

STEP 2:
_; reached

Execution enters function body.

---------------------------------------------------------

STEP 3:
Function body executes.

balances[Alice] += 50

---------------------------------------------------------

STEP 4:
Function body finishes.

Execution RETURNS to modifier.

---------------------------------------------------------

STEP 5:
POST-EXECUTION runs.

lastAction =
"Function completed"

---------------------------------------------------------

FINAL STATE:

balances[Alice] = 50

lastAction =
"Function completed"

=========================================================
REENTRANCY MODIFIER TRACE
=========================================================

CALL:
secureDeposit(100)

=========================================================

STEP 1:
Modifier executes.

---------------------------------------------------------

CHECK:
locked == false

RESULT:
true

---------------------------------------------------------

STEP 2:
locked = true

---------------------------------------------------------

STEP 3:
_; reached

Function body executes.

---------------------------------------------------------

STEP 4:
balances[Alice] += 100

---------------------------------------------------------

STEP 5:
Function body finishes.

---------------------------------------------------------

STEP 6:
POST-EXECUTION LOGIC

locked = false

---------------------------------------------------------

FINAL STATE:

locked = false

=========================================================
IMPORTANT EXECUTION MODEL
=========================================================

Modifier wraps function body.

---------------------------------------------------------

FLOW:

modifier start
    ->
function body
    ->
modifier end

=========================================================
VISUAL EXECUTION FLOW
=========================================================

trackExecution()
{
    before logic

    _;

    after logic
}

---------------------------------------------------------

deposit()
is inserted at _;

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
deposit(50)

---------------------------------------------------------

STEP 3:
Call:
balances(your_address)

EXPECTED:
50

---------------------------------------------------------

STEP 4:
Call:
lastAction()

EXPECTED:
"Function completed"

---------------------------------------------------------

STEP 5:
Call:
secureDeposit(100)

---------------------------------------------------------

STEP 6:
Call:
locked()

EXPECTED:
false

---------------------------------------------------------

OBSERVE:
Modifier unlocked AFTER execution.

=========================================================
VERY IMPORTANT SECURITY UNDERSTANDING
=========================================================

Post-execution modifier code
runs ONLY if execution reaches it.

---------------------------------------------------------

If transaction reverts:
post-execution code may NOT execute.

=========================================================
CRITICAL REENTRANCY UNDERSTANDING
=========================================================

noReentrant pattern:

1. lock before execution
2. execute function
3. unlock after execution

---------------------------------------------------------

This protects:
against nested reentrant calls.

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. HIDDEN POST-STATE MUTATIONS
---------------------------------------------------------

Modifiers may silently:
change storage AFTER execution.

---------------------------------------------------------
2. LOCK NEVER RELEASED
---------------------------------------------------------

If unlock logic incorrect:
contract may freeze.

---------------------------------------------------------
3. EXECUTION ORDER BUGS
---------------------------------------------------------

Post-execution logic may:
break assumptions.

---------------------------------------------------------
4. MODIFIER SIDE EFFECTS
---------------------------------------------------------

Complex modifiers increase audit difficulty.

=========================================================
GAS OBSERVATION
=========================================================

Post-execution logic:
adds additional gas cost.

---------------------------------------------------------

Complex modifier chains:
increase execution complexity.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- What executes after _; ?
- Can post-logic fail?
- Are locks always released?
- Does modifier mutate state?
- Is execution order safe?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Developer forgets:
unlock step after execution.

Result:
permanent DOS/frozen contract.

---------------------------------------------------------

ANOTHER RISK

Post-execution modifier
changes state unexpectedly.

Result:
hidden accounting bug.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. Pre-modifier logic
2. Function execution
3. Post-modifier logic
4. Revert behavior
5. Lock/unlock guarantees

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add execution counter modifier
2. Increment counter AFTER function
3. Add failed-attempt tracker
4. Add event emission after execution

BONUS:
Build complete custom:
nonReentrant modifier.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Modifiers can execute after function body
- _; represents function insertion point
- Post-execution logic wraps function execution
- Reentrancy guards use post-execution unlock flow
- Modifiers may mutate state after execution
- Execution order matters heavily
- Failed execution may skip post-logic
- Hidden modifier effects increase audit complexity
- Auditors trace modifier wrapping carefully
- Modifier flow is critical for smart contract security

=========================================================
*/
/*
=========================================================
AUDIT REPORT
=========================================================

Title: Missing Execution Monitoring and Failure Tracking

Severity: Low

Reason:
The contract lacks execution-accounting and
failure-tracking mechanisms for post-execution flows.

---------------------------------------------------------
Location
---------------------------------------------------------

Contract: PostExecutionModifierVul

Affected Functions:
- deposit()
- secureDeposit()

Affected Modifier:
- trackExecution()

---------------------------------------------------------
Vulnerability Description
---------------------------------------------------------

The contract demonstrates post-execution modifier
behavior correctly but lacks additional execution
monitoring protections commonly used in production systems.

The implementation does NOT include:

1. execution counter tracking
2. failed-attempt accounting
3. execution event emission

As a result:

- successful executions are not tracked
- failed interactions leave no audit trail
- off-chain monitoring visibility is reduced
- execution analytics cannot be maintained

The contract only updates:

- balances
- lastAction
- locked state

without maintaining operational execution statistics.

---------------------------------------------------------
Impact
---------------------------------------------------------

This issue does NOT directly allow:

- theft of funds
- unauthorized access
- reentrancy exploitation

However, the lack of execution monitoring may cause:

- poor protocol observability
- incomplete forensic analysis
- weaker debugging capability
- missing execution analytics
- reduced operational transparency

In production systems, missing execution tracking
may complicate:

- protocol monitoring
- incident investigation
- accounting analysis
- security review processes

---------------------------------------------------------
Proof of Concept
---------------------------------------------------------

STEP 1:
Deploy contract.

---------------------------------------------------------

STEP 2:
Call:

deposit(50)

---------------------------------------------------------

STATE:

balances[user] = 50

---------------------------------------------------------

Observation:

No execution counter increments.

No execution statistics recorded.

---------------------------------------------------------

STEP 3:
Call:

deposit(0)

---------------------------------------------------------

Transaction reverts.

---------------------------------------------------------

Observation:

No failed-attempt tracking exists.

No failure accounting is stored.

---------------------------------------------------------

STEP 4:
Call:

secureDeposit(100)

---------------------------------------------------------

STATE:

balances[user] += 100

locked = false

---------------------------------------------------------

Observation:

The lock releases correctly after execution.

However:

- no execution metrics are recorded
- no execution event emitted
- no post-execution accounting exists

---------------------------------------------------------
Root Cause
---------------------------------------------------------

The contract focuses only on demonstrating:

- modifier wrapping flow
- post-execution behavior
- reentrancy-style locking

but omits:

- execution accounting
- failed-attempt monitoring
- execution event logging

---------------------------------------------------------
Recommendation
---------------------------------------------------------

Add:

1. execution counter modifier
2. failed-attempt tracker
3. execution event emission
4. enhanced execution monitoring

Example improvements:

- increment counters after execution
- emit execution events
- track failed validation attempts
- improve operational observability
*/
// patched code 
/*
contract PostExecutionModifier{
    mapping (address=>uint256)public balances;
    uint256 public executionCount;
    uint256 public failedAttempts;

    bool public locked;

    event Deposited(address user,uint256 amount);
    /*
    =====================================================
    EXECUTION COUNTER MODIFIER
    =====================================================

    AFTER function executes:
    increase execution count.
    
    modifier executionCounter(){
        _; // execute function
        executionCount += 1; // increment counter
    }

     /*
    =====================================================
    FAILED ATTEMPT TRACKER
    =====================================================

    If validation fails:
    increase failedAttempts.
    
    event FailedAttempt(address user);
    modifier validateAmt(uint256 _amt){
        if(_amt==0){
        emit FailedAttempt(msg.sender);
        revert("Invalid Amount");

            //this code commented becoz revert un does all the chnages and failedAttempts is not updated
            // failedAttempts += 1;
            // revert("Invalid Amount") ;
        }
        _;
    }

     /*
    =====================================================
    CUSTOM NON-REENTRANT MODIFIER
    =====================================================
    
    modifier noReentrant(){
        /*
            PRE-EXECUTION CHECK
        
        require(locked == false, "Reentrant call blocked");
        /*
            LOCK CONTRACT
        
        locked = true;
           _;

         /*
            POST-EXECUTION UNLOCK
        
        locked = false;
    }

    function deposit(uint256 _amt)external validateAmt(_amt) executionCounter noReentrant{
        balances[msg.sender] += _amt;
        emit Deposited(msg.sender, _amt);

    }

}*/

contract postExecutionModifierVul {
    /*
    OWNER ADDRESS
    */
    address public owner;
    /*
    EXECUTION STATUS
    */
    bool public locked;
    /*
    LAST ACTION TRACKER
    */
    string public lastAction;
    /*
    USER BALANCES
    */
    mapping(address => uint256) public balances;
    /*
    EXECUTION COUNTER
    stores total number of successful
    function execution
    */
    uint256 public executionCount;
    /*
    FAILED ATTEMPT TRACKER
    Stores number of failed attempts
    for each userr
    */
    mapping(address => uint256) public failedAttempts;
    /*
    EVENT
    Emitted after successful execution.
    */
    event ExecutionCompleted(
        address indexed user,
        string action,
        uint256 executionNumber
    );
    /*
    CONSTRUCTOR
    */
    constructor() {
        owner = msg.sender;
    }
    /*
    =====================================
    EXECUTIN COUNTER MODIFIER
    =====================================
    Function body executes first
    counter is increased AFTER
    THE FUNCTION SUCCESSFULLY COMPLETES
    */
    modifier countExecution() {
        /*
        FUNCTION BODY EXECUTES
        */
        _;
        /*
        POST-EXECUTION LOGIC
        Increase counter after execution.
        */
        executionCount++;
    }
 /*
    =====================================================
    FAILED ATTEMPT TRACKER
    =====================================================

    This modifier tracks failed attempts.

    Important:
    Solidity reverts roll back state changes
    made in the same transaction.

    Therefore, to permanently store a failed
    attempt, we use an event here.
    */
    modifier trackFailedAttempt() {

        /*
            FUNCTION BODY EXECUTES
        */
        _;

    }


    /*
    =====================================================
    EXECUTION TRACKING MODIFIER
    =====================================================
    */
    modifier trackExecution() {

        /*
            PRE-EXECUTION
        */
        lastAction = "Function started";

        /*
            FUNCTION BODY
        */
        _;

        /*
            POST-EXECUTION
        */
        lastAction = "Function completed";

        /*
            EVENT AFTER EXECUTION
        */
        emit ExecutionCompleted(
            msg.sender,
            "Function completed",
            executionCount + 1
        );
    }


    /*
    =====================================================
    BONUS: CUSTOM NON-REENTRANT MODIFIER
    =====================================================
    */
    modifier nonReentrant() {

        /*
            CHECK

            Function cannot execute if already locked.
        */
        require(
            locked == false,
            "Reentrant call blocked"
        );

        /*
            LOCK
        */
        locked = true;

        /*
            FUNCTION BODY
        */
        _;

        /*
            UNLOCK AFTER FUNCTION EXECUTION
        */
        locked = false;
    }


    /*
    =====================================================
    DEPOSIT FUNCTION
    =====================================================
    */
    function deposit(
        uint256 _amount
    )
        external
        trackExecution
        countExecution
    {
        /*
            VALIDATION
        */
        if (_amount == 0) {

            /*
                Emit failed attempt event.
            */
            emit ExecutionCompleted(
                msg.sender,
                "Deposit failed",
                executionCount
            );

            revert("Invalid amount");
        }

        /*
            UPDATE BALANCE
        */
        balances[msg.sender] += _amount;
    }


    /*
    =====================================================
    SECURE DEPOSIT
    =====================================================
    */
    function secureDeposit(
        uint256 _amount
    )
        external
        nonReentrant
        trackExecution
        countExecution
    {
        /*
            VALIDATION
        */
        if (_amount == 0) {
            revert("Invalid amount");
        }

        /*
            FUNCTION BODY
        */
        balances[msg.sender] += _amount;
    }
}