// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Handle success boolean properly
CONCEPT: Safe call handling
=========================================================

OBJECTIVE

- Learn proper low-level call() handling
- Understand safe external interaction logic
- Learn transaction rollback protection
- Prevent silent external-call failures

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Low-level call() returns:

(bool success, bytes memory data)

---------------------------------------------------------

SAFE handling requires:

require(success)

---------------------------------------------------------

Otherwise:
external call failures may be ignored.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

External calls are:
UNTRUSTED EXECUTION.

---------------------------------------------------------

Target contracts may:

- revert
- reject ETH
- consume gas
- behave maliciously

---------------------------------------------------------

Safe code ALWAYS checks:
success boolean.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Unchecked calls caused:

- accounting corruption
- lost funds
- broken withdrawals
- inconsistent state
- DOS vulnerabilities

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Safe call handling used in:

- DeFi protocols
- vaults
- token bridges
- DAO systems
- exchanges
- lending protocols

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- require(success)
- unchecked low-level calls
- rollback guarantees
- silent failure risks
- external interaction safety

=========================================================
TARGET CONTRACT
=========================================================
*/

    contract CallTargetVul {
        /*
            TRACK EXECUTIONS
        */
        uint256 public counter;

        /*
        =====================================================
        SUCCESS FUNCTION
        =====================================================
        */

        function successFunction()external{
            /*
                Increment counter.
            */
            counter++;
        }

        /*
        =====================================================
        FAILING FUNCTION
        =====================================================
        */

        function failFunction()   external   pure{
            /*
                Intentionally revert.
            */
            revert("Intentional failure");
        }

        /*
        =====================================================
        REJECT ETH
        =====================================================
        */

        receive() external  payable{
            /*
                Reject ETH transfers.
            */
            revert("ETH rejected");
        }
    }

    /*
    =========================================================
    SAFE CALLER CONTRACT
    =========================================================
    */

    contract SafeCallHandlerVul {
        /*
            TRACK RESULTS
        */
        bool public lastSuccess;

        bytes public lastData;

        uint256 public executionCounter;

        /*
        =====================================================
        SAFE FUNCTION CALL
        =====================================================
        */

        function safeFunctionCall(  address _target ) external{
            /*
                Local state update.
            */
            executionCounter++;

            /*
                Low-level external call.
            */
            (bool success, bytes memory data) = _target.call(abi.encodeWithSignature( "successFunction()"));
            /*
                Store results.
            */
            lastSuccess = success;

            lastData = data;

            /*
            =================================================
            SAFE HANDLING
            =================================================

            If external call failed:
            transaction fully reverts.
            */
            require( success,  "External function call failed" );
        }

        /*
        =====================================================
        SAFE FAILING CALL
        =====================================================
        */

        function safeFailingCall(  address _target)  external{
            /*
                Local state update.
            */
            executionCounter++;

            /*
                External call that fails.
            */
            (bool success, bytes memory data) = _target.call(abi.encodeWithSignature("failFunction()"));
            /*
                Save results.
            */
            lastSuccess = success;

            lastData = data;

            /*
                SAFE FAILURE HANDLING.

                Revert if call failed.
            */
            require(success, "External call reverted");
        }
        /*
        =====================================================
        SAFE ETH TRANSFER
        =====================================================
        */

        function safeETHTransfer(address payable _target)  external payable {
            /*
                Attempt ETH transfer.
            */
            (bool success, bytes memory data) = _target.call{ value: msg.value }("");
            /*
                Store results.
            */
            lastSuccess = success;
            lastData = data;

            /*
                SAFE CHECK.

                Prevent silent ETH-transfer failure.
        */
        require(success,  "ETH transfer failed");
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy CallTarget

---------------------------------------------------------

STEP 2:
Deploy SafeCallHandler

=========================================================
TRACE:
safeFunctionCall()
=========================================================

STEP 1:
executionCounter++

---------------------------------------------------------

NEW VALUE:
1

=========================================================
STEP 2
=========================================================

Low-level call executes:

successFunction()

=========================================================
STEP 3
=========================================================

Target function succeeds.

---------------------------------------------------------

success = true

=========================================================
STEP 4
=========================================================

require(success)

---------------------------------------------------------

PASS

---------------------------------------------------------

Transaction succeeds safely.

=========================================================
FAILING CALL TRACE
=========================================================

CALL:
safeFailingCall()

=========================================================

STEP 1:
executionCounter++

---------------------------------------------------------

NEW VALUE:
2

=========================================================
STEP 2
=========================================================

External call executes:

failFunction()

=========================================================
STEP 3
=========================================================

Target contract reverts.

---------------------------------------------------------

success = false

=========================================================
STEP 4
=========================================================

require(success)

---------------------------------------------------------

FAILS

---------------------------------------------------------

TRANSACTION REVERTS

=========================================================
IMPORTANT ROLLBACK OBSERVATION
=========================================================

Even though:

executionCounter++
executed BEFORE call,
---------------------------------------------------------

ALL state changes rollback.

=========================================================
FINAL RESULT
=========================================================

executionCounter restored
to previous value.

=========================================================
WHY?
=========================================================

Ethereum transactions are:
ATOMIC.

---------------------------------------------------------

Either:
everything succeeds

OR

everything reverts.

=========================================================
ETH FAILURE TRACE
=========================================================

CALL:
safeETHTransfer()

VALUE:
1 ETH

=========================================================

STEP 1:
ETH sent to CallTarget.

=========================================================
STEP 2
=========================================================

receive() executes.

---------------------------------------------------------

receive() reverts intentionally.

=========================================================
STEP 3
=========================================================

call() returns:

success = false

=========================================================
STEP 4
=========================================================

require(success)

---------------------------------------------------------

Transaction fully reverts.

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

Safe external handling requires:

---------------------------------------------------------
CHECKING success
---------------------------------------------------------

on EVERY low-level call.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy CallTarget
---------------------------------------------------------

STEP 2:
Deploy SafeCallHandler
---------------------------------------------------------

STEP 3:
Call:
safeFunctionCall()

Input:
CallTarget address

---------------------------------------------------------

EXPECTED:
Success

=========================================================
STEP 4
=========================================================

Call:
safeFailingCall()

---------------------------------------------------------

EXPECTED:
Revert with:
"External call reverted"

=========================================================
STEP 5
=========================================================

Check:
executionCounter()

---------------------------------------------------------

EXPECTED:
unchanged due to rollback.

=========================================================
STEP 6
=========================================================

In VALUE field:
enter 1 ether

---------------------------------------------------------

STEP 7:
Call:
safeETHTransfer()

---------------------------------------------------------

EXPECTED:
Revert with:
"ETH transfer failed"

=========================================================
IMPORTANT LOW-LEVEL CALL UNDERSTANDING
=========================================================

call() NEVER auto-reverts.

---------------------------------------------------------

It only returns:

success = true/false

---------------------------------------------------------

Developer decides:
how to handle failure.

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. UNCHECKED SUCCESS VALUES
---------------------------------------------------------

Classic Solidity vulnerability.

---------------------------------------------------------
2. SILENT FAILURES
---------------------------------------------------------

Execution continues incorrectly.

---------------------------------------------------------
3. ACCOUNTING CORRUPTION
---------------------------------------------------------

Internal state diverges from reality.

---------------------------------------------------------
4. DOS VIA REVERT
---------------------------------------------------------

Malicious contracts halt execution.

=========================================================
IMPORTANT ATTACK THINKING
=========================================================

Attackers intentionally:

- revert calls
- reject ETH
- break assumptions
- exploit unchecked failures

---------------------------------------------------------

Safe handling blocks these issues.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors search for:

---------------------------------------------------------
.call(
---------------------------------------------------------

without:

---------------------------------------------------------
require(success)
---------------------------------------------------------

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. External interactions
2. Failure paths
3. Return-value handling
4. Rollback guarantees
5. Silent-failure scenarios

=========================================================
BEST PRACTICE
=========================================================

ALWAYS:

---------------------------------------------------------
(bool success, ) = target.call(...)

require(success)
---------------------------------------------------------

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add try/catch
2. Decode revert messages
3. Emit failure events
4. Compare checked vs unchecked calls

BONUS:
Build ERC20 safe-transfer wrapper.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- call() returns success manually
- Low-level calls do not auto-revert
- require(success) ensures safe handling
- Reverts rollback all state changes
- Transactions are atomic
- External calls are untrusted
- Silent failures are dangerous
- Safe call handling prevents inconsistencies
- Auditors inspect low-level calls carefully
- Error handling is critical for Solidity security

=========================================================
*/
/*
=========================================================
AUDIT REPORT
=========================================================

Title: Proper Low-Level Call Handling

Severity: Informational

Reason:
All low-level external calls correctly validate
the returned success boolean.

Location:

Contract: SafeCallHandlerVul
Functions:
- safeFunctionCall()
- safeFailingCall()
- safeETHTransfer()

Vulnerability Description:
The contract performs external interactions using
low-level call().

Each call follows the secure pattern:
(bool success, bytes memory data) = target.call(...);
require(success, "...");

This ensures that:

- failed function calls revert
- failed ETH transfers revert
- state changes rollback automatically
- silent failures cannot occur

No unchecked low-level call vulnerability was found.

Impact:

No security impact identified.
The contract safely handles:

- reverting external functions
- rejected ETH transfers
- failed low-level calls

Transaction atomicity is preserved.

Proof of Concept:
        1. Deploy CallTargetVul.
        2. Deploy SafeCallHandlerVul.
        3. Call:
        safeFunctionCall(CallTargetVul)

        Result:

        - successFunction() executes
        - success = true
        - transaction succeeds

        4. Call:

        safeFailingCall(CallTargetVul)

        Result:

        - failFunction() reverts
        - success = false
        - require(success) triggers
        - transaction reverts safely

        5. Call:
            safeETHTransfer(CallTargetVul)
            Value:
                1 ETH

        Result:
        - receive() reverts
        - success = false
        - require(success) triggers
        - transaction reverts safely

Root Cause:
No vulnerability identified.
The contract correctly validates
all low-level call return values.

Recommendation:
No security changes required.
Continue using:
(bool success, ) = target.call(...);
require(success, "External call failed");
*/
//patched code 
/*
contract CallTarget {
    /*
        TRACK EXECUTIONS
    *
    uint256 public counter;

    /*
    =====================================================
    SUCCESS FUNCTION
    =====================================================
    *

    function successFunction()external{
        /*
            Increment counter.
        *
        counter++;
    }

    /*
    =====================================================
    FAILING FUNCTION
    =====================================================
    *

    function failFunction()   external   pure{
        /*
            Intentionally revert.
        *
        revert("Intentional failure");
    }

    /*
    =====================================================
    REJECT ETH
    =====================================================
    *

    receive() external  payable{
        /*
            Reject ETH transfers.
    
        revert("ETH rejected");
    }
}

/*
=========================================================
SAFE CALLER CONTRACT
=========================================================


contract SafeCallHandler {

    event CallSuccess(address target);
    event CallFailed(address target, string reason);

    string public lastError;
    /*
        TRACK RESULTS
    
    bool public lastSuccess;

    bytes public lastData;

    uint256 public executionCounter;

    /*
    =====================================================
    SAFE FUNCTION CALL
    =====================================================
    

    function safeFunctionCall(  address _target ) external{
        /*
            Local state update.
        
        executionCounter++;

        /*
            Low-level external call.
        
        (bool success, bytes memory data) = _target.call(abi.encodeWithSignature( "successFunction()"));
        /*
            Store results.
        
        lastSuccess = success;

        lastData = data;

        /*
        =================================================
        SAFE HANDLING
        =================================================

        If external call failed:
        transaction fully reverts.
        
        require( success,  "External function call failed" );
    }

    /*
    =====================================================
    SAFE FAILING CALL
    =====================================================
    

    function safeFailingCall(  address _target)  external{
        /*
            Local state update.
        
        executionCounter++;

        /*
            External call that fails.
        
        (bool success, bytes memory data) = _target.call(abi.encodeWithSignature("failFunction()"));
        /*
            Save results.
    
        lastSuccess = success;

        lastData = data;

        /*
            SAFE FAILURE HANDLING.

            Revert if call failed.
        
        require(success, "External call reverted");
    }
    /*
    =====================================================
    SAFE ETH TRANSFER
    =====================================================
    

    function safeETHTransfer(address payable _target)  external payable {
        /*
            Attempt ETH transfer.
        
        (bool success, bytes memory data) = _target.call{ value: msg.value }("");

        emit CallSuccess(_target);
        /*
            Store results.
        
        lastSuccess = success;
        lastData = data;

        /*
            SAFE CHECK.

            Prevent silent ETH-transfer failure.
        
        require(success,  "ETH transfer failed");
    }

   function _getRevertMsg(bytes memory data)internal pure returns (string memory){
    if(data.length<68){
        return "Unknown Error";
    }

    assembly{
        data:=add(data,0x04)
    }
    return abi.decode(data,(string));
   }

   function uncchekedCall(address _target)external {
    executionCounter++;

    _target.call(abi.encodeWithSignature("failFunction()"));


    // func continues even if call failed
   }

   function checkedCall(address _target) external {
    (bool success, ) =_target.call(abi.encodeWithSignature( "failFunction()" ) );

    require( success,  "External call failed");
    executionCounter++;
}

   function callWithDecode(address _target)external {
    (bool success,bytes memory data)=_target.call(abi.encodeWithSignature("failFunction()"));
    lastSuccess=success;
    if(!success){
        string memory reason=_getRevertMsg(data);
        lastError=reason;

        emit CallFailed(_target, reason);
    }
   }

   function tryCatchEx(address _target)external {
    try CallTarget(payable(_target)).successFunction(){
        emit CallSuccess(_target);
    }catch Error(string memory reason){
        lastError=reason;
        emit CallFailed(_target, reason);
    }catch {
        lastError="Unknown Error";
        emit CallFailed(_target, "Unknown Error");
    }
   }
}
*/
contract CallTargetVul {

    uint public counter;

    function successFunction() external {
        counter++;
    }

    function failFunction() external pure {
        revert("Intentional failure");
    }

    receive() external payable {
        revert("ETH rejected");
    }
}

interface ICallTarget {
    function successFunction() external;
    function failFunction() external;
}

contract SafeCallHandlerVul {

    bool public lastSuccess;
    bytes public lastData;
    uint public executionCounter;

    event CallFailed(address target, string reason);
    event CallResult(address target, bool success);

    // Checked call
    function checkedCall(address target) external {
        executionCounter++;

        (bool success, bytes memory data) =
            target.call(
                abi.encodeWithSignature("successFunction()")
            );

        lastSuccess = success;
        lastData = data;

        emit CallResult(target, success);

        require(success, "Call failed");
    }

    // Unchecked call
    function uncheckedCall(address target) external {
        executionCounter++;

        (bool success, bytes memory data) =
            target.call(
                abi.encodeWithSignature("failFunction()")
            );

        lastSuccess = success;
        lastData = data;

        emit CallResult(target, success);

        // No require()
    }

    // Try / Catch
    function tryCatch(address target) external {
        try ICallTarget(target).failFunction() {
            emit CallResult(target, true);
        }
        catch Error(string memory reason) {
            emit CallFailed(target, reason);
        }
        catch {
            emit CallFailed(target, "Unknown error");
        }
    }

    // Decode revert message
    function decodeError(address target)
        external
        returns (string memory)
    {
        (bool success, bytes memory data) =
            target.call(
                abi.encodeWithSignature("failFunction()")
            );

        if (success)
            return "Success";

        if (data.length >= 68) {
            assembly {
                data := add(data, 4)
            }

            return abi.decode(data, (string));
        }

        return "Unknown error";
    }
}