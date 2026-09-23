// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Trace external call execution
CONCEPT: Control transfer awareness
=========================================================

OBJECTIVE

- Learn how execution control moves externally
- Understand execution-context switching
- Trace msg.sender across contracts
- Think like auditor during external interactions

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

When Contract A calls Contract B:

execution control LEAVES A
and ENTERS B.

---------------------------------------------------------

This is one of the MOST IMPORTANT
security concepts in Solidity.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

External calls are NOT normal jumps.

---------------------------------------------------------

Execution temporarily transfers to:

UNTRUSTED CODE.

---------------------------------------------------------

The called contract controls execution flow
until it returns or reverts.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Most Solidity vulnerabilities involve:

- external execution
- reentrancy
- callback attacks
- malicious contracts
- trust assumptions

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

External calls exist in:

- token transfers
- swaps
- lending protocols
- NFT marketplaces
- staking systems
- bridges

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors trace:

- execution switching
- msg.sender transitions
- state before/after calls
- reentrancy windows
- callback opportunities

=========================================================
TARGET CONTRACT
=========================================================
*/
/*
contract ExternalTargetVul {
    /*
        STORE LAST CALLER
    
    address public lastCaller;

    /*
        TRACK EXECUTIONS
    
    uint256 public executionCounter;

    /*
    =====================================================
    TARGET FUNCTION
    =====================================================
    

    function targetFunction() external {
        /*
        =================================================
        EXECUTION CONTEXT NOW INSIDE TARGET CONTRACT
        =================================================

        msg.sender becomes:
        calling contract address.
        

        lastCaller = msg.sender;

        /*
            Increment execution count.
        
        executionCounter++;
    }
}

/*
=========================================================
CALLER CONTRACT
=========================================================


contract ExecutionTracerVul {

    /*
        TARGET CONTRACT REFERENCE
    
    ExternalTargetVul public target;

    /*
        LOCAL EXECUTION TRACKING
    
    uint256 public localCounter;

    /*
        TRACK EXECUTION STEPS
    
    string public executionStage;

    /*
        TRACK LAST msg.sender
    
    address public lastObservedSender;

    /*
        CONSTRUCTOR
    
    constructor(address _target)
    {

        /*
            Save target contract.
        
        target = ExternalTargetVul(_target);
    }

    /*
    =====================================================
    TRACE EXTERNAL EXECUTION
    =====================================================
    

    function traceExecution()external{
        /*
        =================================================
        STEP 1
        =================================================

        Execution currently inside:
        ExecutionTracer contract.
        

        executionStage =
            "Before external call";

        /*
            msg.sender here:
            ORIGINAL USER.
        
        lastObservedSender =
            msg.sender;

        /*
            Local state update.
        
        localCounter++;

        /*
        =================================================
        STEP 2
        =================================================

        EXTERNAL CALL HAPPENS HERE.

        CONTROL LEAVES:
        ExecutionTracer

        CONTROL ENTERS:
        ExternalTarget
        

        target.targetFunction();

        /*
        =================================================
        STEP 3
        =================================================

        External execution finished.

        CONTROL RETURNS:
        back to ExecutionTracer.
        

        executionStage ="After external call";
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy ExternalTarget

---------------------------------------------------------

STEP 2:
Deploy ExecutionTracer

Constructor input:
ExternalTarget address

=========================================================
TRACE:
traceExecution()
=========================================================

STEP 1:
User calls:

traceExecution()

=========================================================
STEP 2
=========================================================

Execution enters:
ExecutionTracer

---------------------------------------------------------

Current contract:
ExecutionTracer

---------------------------------------------------------

msg.sender:
ORIGINAL USER

=========================================================
STEP 3
=========================================================

executionStage =
"Before external call"

---------------------------------------------------------

localCounter++

=========================================================
STEP 4
=========================================================

CRITICAL MOMENT:

target.targetFunction()

=========================================================
IMPORTANT
=========================================================

CONTROL LEAVES:
ExecutionTracer

---------------------------------------------------------

Execution CONTEXT switches externally.

=========================================================
STEP 5
=========================================================

Execution enters:
ExternalTarget

---------------------------------------------------------

Current contract:
ExternalTarget

=========================================================
IMPORTANT msg.sender CHANGE
=========================================================

Inside ExternalTarget:

msg.sender =
ExecutionTracer contract

---------------------------------------------------------

NOT original user.

=========================================================
STEP 6
=========================================================

ExternalTarget executes:

---------------------------------------------------------

lastCaller = ExecutionTracer

---------------------------------------------------------

executionCounter++

=========================================================
STEP 7
=========================================================

ExternalTarget finishes execution.

---------------------------------------------------------

CONTROL RETURNS:
ExecutionTracer

=========================================================
STEP 8
=========================================================

Execution continues AFTER external call.

---------------------------------------------------------

executionStage =
"After external call"

=========================================================
FINAL RESULT
=========================================================

---------------------------------------------------------
ExecutionTracer.localCounter
---------------------------------------------------------

1

---------------------------------------------------------
ExternalTarget.executionCounter
---------------------------------------------------------

1

---------------------------------------------------------
ExternalTarget.lastCaller
---------------------------------------------------------

ExecutionTracer address

=========================================================
CRITICAL SECURITY UNDERSTANDING
=========================================================

During external call:

---------------------------------------------------------
YOUR CONTRACT STOPS EXECUTING
---------------------------------------------------------

and

---------------------------------------------------------
ANOTHER CONTRACT TAKES CONTROL
---------------------------------------------------------

=========================================================
THIS IS DANGEROUS BECAUSE
=========================================================

External contract may:

- revert
- reenter
- consume gas
- manipulate execution
- attack assumptions

=========================================================
VERY IMPORTANT AUDITOR MINDSET
=========================================================

Every external call means:

---------------------------------------------------------
TRUSTING UNKNOWN EXECUTION
---------------------------------------------------------

=========================================================
CONTROL TRANSFER VISUALIZATION
=========================================================

User
  |
  v
ExecutionTracer
  |
  | external call
  v
ExternalTarget
  |
  | return
  v
ExecutionTracer resumes

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy ExternalTarget

---------------------------------------------------------

STEP 2:
Deploy ExecutionTracer

Input:
ExternalTarget address

---------------------------------------------------------

STEP 3:
Call:
traceExecution()

=========================================================
STEP 4
=========================================================

Check:
executionStage()

EXPECTED:
"After external call"

=========================================================
STEP 5
=========================================================

Check:
localCounter()

EXPECTED:
1

=========================================================
STEP 6
=========================================================

Open ExternalTarget

---------------------------------------------------------

Check:
executionCounter()

EXPECTED:
1

---------------------------------------------------------

Check:
lastCaller()

EXPECTED:
ExecutionTracer address

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

External calls create:

---------------------------------------------------------
EXECUTION BOUNDARIES
---------------------------------------------------------

and

---------------------------------------------------------
TRUST BOUNDARIES
---------------------------------------------------------

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. REENTRANCY
---------------------------------------------------------

External contract calls back unexpectedly.

---------------------------------------------------------
2. msg.sender CONFUSION
---------------------------------------------------------

Authentication assumptions fail.

---------------------------------------------------------
3. FAILURE PROPAGATION
---------------------------------------------------------

External revert breaks execution.

---------------------------------------------------------
4. MALICIOUS CALLBACKS
---------------------------------------------------------

Execution flow manipulated externally.

=========================================================
IMPORTANT ATTACK THINKING
=========================================================

Attackers abuse:

- external execution windows
- callback opportunities
- temporary state exposure
- trust assumptions

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. Every external jump
2. Control-transfer timing
3. State before call
4. State after call
5. Reentrancy possibilities

=========================================================
WHY CONTROL TRANSFER IS CRITICAL
=========================================================

Most major Solidity exploits happen
during external execution.

---------------------------------------------------------

Understanding control transfer
is foundational for auditing.

=========================================================
MINI CHALLENGE
=========================================================

Modify contracts so that:

1. Add ETH transfer
2. Add malicious callback
3. Add reentrancy attack
4. Add nested external chain

BONUS:
Trace execution using Remix debugger.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- External calls transfer execution control
- msg.sender changes during nested calls
- Contracts temporarily stop execution
- External contracts are untrusted
- Control eventually returns after execution
- Reentrancy occurs during external execution
- Auditors trace every external jump
- Execution context changes externally
- External calls create attack surface
- Control-transfer awareness is critical for auditing

=========================================================
*/

/*
AUDIT REPORT

Title: Reentrancy Exposure Through External Control Transfer

Severity: Medium

Reason: Contract transfers execution control to an external contract before finishing its own execution, creating a potential reentrancy window.

Location:

Contract: ExecutionTracerVul
Function: traceExecution()

VULNERABILITY DESCRIPTION

The traceExecution() function performs state updates before making
an external call:

localCounter++;

target.targetFunction();

During the external call, execution control leaves
ExecutionTracerVul and enters ExternalTargetVul.

Although the current ExternalTargetVul implementation is benign,
the pattern creates a reentrancy window if the target contract
is later replaced or upgraded with malicious behavior.

The calling contract temporarily loses execution control and
trusts external code execution.


IMPACT
A malicious external contract could:

- Reenter ExecutionTracerVul
- Manipulate execution flow
- Trigger unexpected state changes
- Exploit temporary contract state
- Cause denial-of-service conditions

If critical protocol logic existed before the external call,
funds or protocol state could become vulnerable.

PROOF OF CONCEPT
    1. Deploy a malicious target contract.
    2. Replace ExternalTargetVul with malicious contract.
    3. User calls:
    traceExecution()

    4. Execution reaches:
    target.targetFunction();

    5. Malicious contract reenters:
    ExecutionTracerVul.traceExecution()
    before original execution finishes.

    6. Multiple executions occur unexpectedly.


ROOT CAUSE
The contract performs an external call before completing all
sensitive internal execution.

External contracts are treated as trusted even though they
control execution during the call.

RECOMMENDATION
Follow Checks-Effects-Interactions pattern.

Complete all internal state changes before external interaction.
For critical systems:

- Use ReentrancyGuard
- Minimize external calls
- Treat all external contracts as untrusted
*/

// patched code
/*
contract ExternalTarget {

    /*
        STORE LAST CALLER
    
    address public lastCaller;

    /*
        TRACK EXECUTIONS
    
    uint256 public executionCounter;

    /*
    =====================================================
    TARGET FUNCTION
    =====================================================
    

    function targetFunction()
        external
    {

        /*
        =================================================
        EXECUTION CONTEXT NOW INSIDE TARGET CONTRACT
        =================================================

        msg.sender becomes:
        calling contract address.
        
        lastCaller = msg.sender;

        /*
            Increment execution count.
        
        executionCounter++;
    }
}

/*
=========================================================
CALLER CONTRACT
=========================================================


contract ExecutionTracer {

    /*
        TARGET CONTRACT REFERENCE
    
    ExternalTarget public target;

    /*
        LOCAL EXECUTION TRACKING
    
    uint256 public localCounter;

    /*
        TRACK EXECUTION STEPS
    
    string public executionStage;

    /*
        TRACK LAST msg.sender
    
    address public lastObservedSender;

    /*
        CONSTRUCTOR
    
    constructor(address _target)
    {

        /*
            Save target contract.
        
        target = ExternalTarget(_target);
    }

    /*
    =====================================================
    TRACE EXTERNAL EXECUTION
    =====================================================
    

    function traceExecution()
        external
    {

        /*
        =================================================
        STEP 1
        =================================================

        Execution currently inside:
        ExecutionTracer contract.
        

        executionStage =
            "Before external call";

        /*
            msg.sender here:
            ORIGINAL USER.
        
        lastObservedSender =
            msg.sender;

        /*
            Local state update.
        
        localCounter++;

        /*
        =================================================
        STEP 2
        =================================================

        EXTERNAL CALL HAPPENS HERE.

        CONTROL LEAVES:
        ExecutionTracer

        CONTROL ENTERS:
        ExternalTarget
        

        target.targetFunction();

        /*
        =================================================
        STEP 3
        =================================================

        External execution finished.

        CONTROL RETURNS:
        back to ExecutionTracer.
        

        executionStage ="After external call";
    }
}



contract MiddleContract {

    ExternalTarget public target;

    constructor(address _target) {
        target = ExternalTarget(_target);
    }

    function chainCall() external {
        target.targetFunction();
    }
}

contract Vault {
    mapping(address => uint256) public balance;

    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amt = balance[msg.sender];

        // external call FIRST (this is the bug)
        (bool success, ) = msg.sender.call{value: amt}("");
        require(success);

        // state update AFTER (wrong order)
        balance[msg.sender] = 0;
    }
    receive() external payable {}
}


contract Attacker {
    Vault public vault;

    constructor(address _vault) {
        vault = Vault(payable (_vault));
    }

    function attack() external payable {
        vault.deposit{value: msg.value}();
        vault.withdraw();
    }

    receive() external payable {
        // re-enter while vault is still executing old logic
        if (address(vault).balance >= 1 ether) {
            vault.withdraw();
        }
    }
}
*/
/*
=========================================================
TARGET CONTRACT
=========================================================
*/

contract ExternalTargetVul {

    address public lastCaller;
    uint256 public executionCounter;
    uint256 public balance;

    event Called(address caller, uint256 value);

    // ETH receiver + malicious callback
    receive() external payable {
        balance += msg.value;
        executionCounter++;

        emit Called(msg.sender, msg.value);

        // Callback to sender
        if (msg.sender.code.length > 0) {
            ICallback(msg.sender).callback();
        }
    }

    function targetFunction() external payable {
        lastCaller = msg.sender;
        executionCounter++;
    }

    // ETH transfer
    function withdraw(address payable to, uint256 amount) external {
        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer failed");
    }
}


/*
=========================================================
CALLBACK INTERFACE
=========================================================
*/

interface ICallback {
    function callback() external;
}


/*
=========================================================
CALLER + REENTRANCY CONTRACT
=========================================================
*/

contract ExecutionTracerVul is ICallback {

    ExternalTargetVul public target;

    uint256 public localCounter;
    uint256 public balance;

    string public executionStage;
    address public lastObservedSender;

    constructor(address _target) {
        target = ExternalTargetVul(_target);
    }

    // Nested external call
    function traceExecution() external payable {

        executionStage = "Before call";
        lastObservedSender = msg.sender;
        localCounter++;

        // Contract A -> Contract B
        target.targetFunction{value: msg.value}();

        // Contract B -> Contract A callback
        executionStage = "After call";
    }

    /*
    =====================================================
    MALICIOUS CALLBACK / REENTRANCY
    =====================================================
    */

    function callback() external {

        // Re-enter target contract
        if (localCounter < 3) {
            localCounter++;

            target.targetFunction();
        }
    }

    /*
    =====================================================
    RECEIVE ETH
    =====================================================
    */

    receive() external payable {
        balance += msg.value;
    }
}