// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Send ETH to non-payable contract
CONCEPT: Revert behavior
=========================================================

OBJECTIVE

- Learn why ETH transfers may fail
- Understand payable vs non-payable behavior
- Learn revert propagation mechanics
- Understand safe ETH transfer handling

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

A contract CANNOT receive ETH unless:

- receive() exists
OR
- fallback() is payable
OR
- target function is payable

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Sending ETH to a non-payable contract:

REVERTS the transaction.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

ETH transfer assumptions cause:

- failed withdrawals
- stuck funds
- broken integrations
- DOS vulnerabilities

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

ETH transfer logic exists in:

- vaults
- bridges
- staking systems
- exchanges
- DAO treasuries
- payment protocols

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- payable correctness
- ETH acceptance logic
- transfer failure handling
- unchecked call results
- DOS possibilities

=========================================================
NON-PAYABLE CONTRACT
=========================================================
*/
/*
contract NonPayableReceiverVul {

    /*
        TRACK EXECUTION
    
    uint256 public counter;

    /*
    =====================================================
    NORMAL FUNCTION
    =====================================================

    NOT payable.
    

    function increment()
        external
    {

        counter++;
    }

    /*
    =====================================================
    IMPORTANT
    =====================================================

    NO receive()
    NO payable fallback()

    Therefore:
    direct ETH transfers fail.
    
}

/*
=========================================================
PAYABLE CONTRACT
=========================================================


contract PayableReceiverVul {

    /*
        TRACK RECEIVED ETH
    
    uint256 public receivedAmount;

    /*
    =====================================================
    RECEIVE ETH
    =====================================================
    

    receive()
        external
        payable
    {

        /*
            Store received ETH amount.
        
        receivedAmount += msg.value;
    }
}

/*
=========================================================
SENDER CONTRACT
=========================================================


contract ETHSenderVul {

    /*
        TRACK LAST RESULT
    
    bool public lastSuccess;

    /*
        TRACK TOTAL SENT

    uint256 public totalSent;

    /*
    =====================================================
    SEND ETH SAFELY
    =====================================================
    

    function sendETH(
        address payable _receiver
    )
        external
        payable
    {

        /*
            Attempt ETH transfer using call().
        
        (bool success, ) =
            _receiver.call{
                value: msg.value
            }("");

        /*
            Save result.
        
        lastSuccess = success;

        /*
            SAFE HANDLING.

            Revert if transfer failed.
        
        require(
            success,
            "ETH transfer failed"
        );

        /*
            Update accounting ONLY after success.
        
        totalSent += msg.value;
    }

    /*
    =====================================================
    DANGEROUS SEND
    =====================================================

    Ignores success boolean.
    

    function dangerousSend(
        address payable _receiver
    )
        external
        payable
    {

        /*
            Attempt ETH transfer.
        
        _receiver.call{
            value: msg.value
        }("");

        /*
            DANGEROUS:
            Execution continues even if transfer failed.
        

        totalSent += msg.value;
    }

    /*
    =====================================================
    CHECK CONTRACT BALANCE
    =====================================================
    

    function contractBalance()
        external
        view
        returns (uint256)
    {

        return address(this).balance;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy NonPayableReceiver

---------------------------------------------------------

STEP 2:
Deploy PayableReceiver

---------------------------------------------------------

STEP 3:
Deploy ETHSender

=========================================================
TRACE:
sendETH() TO NON-PAYABLE CONTRACT
=========================================================

STEP 1:
User calls:

sendETH()

---------------------------------------------------------

VALUE:
1 ETH

---------------------------------------------------------

Receiver:
NonPayableReceiver

=========================================================
STEP 2
=========================================================

Low-level call executes:

_receiver.call{value: 1 ether}("")

=========================================================
STEP 3
=========================================================

Ethereum attempts to send ETH.

=========================================================
IMPORTANT
=========================================================

Target contract has:

---------------------------------------------------------
NO receive()
---------------------------------------------------------

AND

---------------------------------------------------------
NO payable fallback()
---------------------------------------------------------

=========================================================
STEP 4
=========================================================

ETH transfer automatically fails.

---------------------------------------------------------

success = false

=========================================================
STEP 5
=========================================================

require(success)

---------------------------------------------------------

FAILS

---------------------------------------------------------

FULL TRANSACTION REVERTS

=========================================================
FINAL RESULT
=========================================================

---------------------------------------------------------
ETH transferred?
---------------------------------------------------------

NO

---------------------------------------------------------
totalSent updated?
---------------------------------------------------------

NO

---------------------------------------------------------
Transaction status?
---------------------------------------------------------

REVERTED

=========================================================
WHY?
=========================================================

Contract cannot accept ETH.

=========================================================
TRACE:
sendETH() TO PAYABLE CONTRACT
=========================================================

STEP 1:
Call:
sendETH()

---------------------------------------------------------

VALUE:
1 ETH

---------------------------------------------------------

Receiver:
PayableReceiver

=========================================================
STEP 2
=========================================================

receive() executes successfully.

---------------------------------------------------------

success = true

=========================================================
STEP 3
=========================================================

require(success)

---------------------------------------------------------

PASSES

=========================================================
STEP 4
=========================================================

totalSent += 1 ether

=========================================================
FINAL RESULT
=========================================================

ETH transfer succeeds safely.

=========================================================
DANGEROUS TRACE
=========================================================

CALL:
dangerousSend()

---------------------------------------------------------

Receiver:
NonPayableReceiver

=========================================================

STEP 1:
ETH transfer fails.

---------------------------------------------------------

success = false

=========================================================
STEP 2
=========================================================

IMPORTANT:

success ignored completely.

=========================================================
STEP 3
=========================================================

Execution continues.

---------------------------------------------------------

totalSent += msg.value

=========================================================
CRITICAL PROBLEM
=========================================================

Internal accounting says:
ETH sent.

---------------------------------------------------------

Reality:
ETH transfer FAILED.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy NonPayableReceiver

---------------------------------------------------------

STEP 2:
Deploy PayableReceiver

---------------------------------------------------------

STEP 3:
Deploy ETHSender

=========================================================
TEST 1
=========================================================

Call:
sendETH()

---------------------------------------------------------

Receiver:
NonPayableReceiver address

---------------------------------------------------------

VALUE:
1 ether

---------------------------------------------------------

EXPECTED:
Transaction reverts

=========================================================
TEST 2
=========================================================

Call:
sendETH()

---------------------------------------------------------

Receiver:
PayableReceiver address

---------------------------------------------------------

VALUE:
1 ether

---------------------------------------------------------

EXPECTED:
Success

=========================================================
TEST 3
=========================================================

Call:
dangerousSend()

---------------------------------------------------------

Receiver:
NonPayableReceiver address

---------------------------------------------------------

VALUE:
1 ether

---------------------------------------------------------

EXPECTED:
Transaction succeeds incorrectly

=========================================================
STEP 4
=========================================================

Check:
totalSent()

---------------------------------------------------------

IMPORTANT:
Accounting corrupted.

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

ETH transfers are NOT guaranteed.

---------------------------------------------------------

Receiving contracts control acceptance behavior.

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. UNCHECKED ETH TRANSFERS
---------------------------------------------------------

Silent failures corrupt logic.

---------------------------------------------------------
2. NON-PAYABLE TARGETS
---------------------------------------------------------

Unexpected revert conditions.

---------------------------------------------------------
3. DOS VIA REVERT
---------------------------------------------------------

Malicious contracts reject ETH intentionally.

---------------------------------------------------------
4. ACCOUNTING INCONSISTENCY
---------------------------------------------------------

Protocol state diverges from reality.

=========================================================
IMPORTANT ATTACK THINKING
=========================================================

Attackers may:

- reject ETH intentionally
- revert receive()
- break protocol assumptions
- trigger DOS conditions

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- Can target receive ETH?
- Is success checked?
- Are failures handled safely?
- Can ETH rejection DOS protocol?
- Is accounting updated correctly?

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. ETH transfer behavior
2. Payable correctness
3. Failure propagation
4. Accounting consistency
5. External trust assumptions

=========================================================
BEST PRACTICE
=========================================================

Always:

---------------------------------------------------------
(bool success, ) = receiver.call{value: x}("");

require(success)
---------------------------------------------------------

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add payable fallback()
2. Add try/catch handling
3. Add event logging
4. Compare transfer/send/call

BONUS:
Create malicious ETH-rejecting DOS contract.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Non-payable contracts reject ETH
- ETH transfers may revert
- receive() enables ETH reception
- call() returns success manually
- Ignoring success is dangerous
- External ETH handling is untrusted
- Reverts rollback transaction state
- Accounting must follow successful transfers
- Auditors inspect ETH-transfer assumptions
- Safe ETH handling is critical in Solidity

=========================================================
*/
/*
=========================================================
AUDIT REPORT
=========================================================
*/

/*
Title: Unsafe ETH Transfer and Missing Payable Handling in ETHSenderVul

Severity: Medium

Reason: ETH is sent using low-level call() without ensuring receiver can accept ETH safely, and unsafe accounting exists in dangerousSend().

Location:

Contract: ETHSenderVul
Functions: sendETH(), dangerousSend()


VULNERABILITY DESCRIPTION

The ETHSenderVul contract sends ETH to external contracts using:
_receiver.call{value: msg.value}("")
However, the contract assumes the receiver can accept ETH.

If the receiver is NonPayableReceiverVul (no receive() or payable fallback),
the call will fail and revert the entire transaction when require(success) is used.

Additionally, in dangerousSend(), the success value is ignored completely,
leading to incorrect internal accounting.

IMPACT
1. ETH transfer failure leads to full transaction revert
2. DangerousSend allows incorrect accounting even when transfer fails
3. Potential loss of accounting integrity
4. Protocol may assume ETH was sent when it was not
5. Integration failures with non-payable contracts


PROOF OF CONCEPT
    1. Deploy NonPayableReceiverVul
    2. Call ETHSenderVul.sendETH(NonPayableReceiverVul) with 1 ETH
    -> Transaction reverts due to non-payable receiver

    3. Call ETHSenderVul.sendETH(PayableReceiverVul) with 1 ETH
    -> Success (receive() exists)

    4. Call ETHSenderVul.dangerousSend(NonPayableReceiverVul) with 1 ETH
    -> Call fails but execution continues
    -> totalSent incorrectly increases

ROOT CAUSE
- No pre-check for payable capability of receiver
- Unsafe reliance on low-level call without proper handling
- Ignoring success value in dangerousSend()

RECOMMENDATION

1. Always check success return value:
   require(success, "ETH transfer failed");
2. Update state AFTER successful transfer only
3. Avoid dangerousSend pattern completely
4. Optionally use pull-based payment system instead of push transfers

*/
//patched code
/*
contract NonPayableReceiver {
    uint256 public counter;

    event fallbackTriggeres(address sender,uint256 amount);

    /*
    =====================================================
    NORMAL FUNCTION
    =====================================================

    NOT payable.
    

    function increment()  external{
        counter++;
    }
// fallback with receive
     fallback() external payable { 
        emit fallbackTriggeres(msg.sender, msg.value);
    }

    receive() external payable { }

    /*
    =====================================================
    IMPORTANT
    =====================================================

    NO receive()
    NO payable fallback()

    Therefore:
    direct ETH transfers fail.
    
}

/*
=========================================================
PAYABLE CONTRACT
=========================================================


contract PayableReceiver {

    /*
        TRACK RECEIVED ETH
    
    uint256 public receivedAmount;

    /*
    =====================================================
    RECEIVE ETH
    =====================================================
    

    receive()
        external
        payable
    {

        /*
            Store received ETH amount.
        
        receivedAmount += msg.value;
    }
}

// interface
interface IReceiver{
    function increment() external ;
}

/*
=========================================================
SENDER CONTRACT
=========================================================


contract ETHSender {

    event TransferAttempt( address receiver, uint256 amount);
    event TransferResult( bool success);

    /*
        TRACK LAST RESULT
    
    bool public lastSuccess;

    /*
        TRACK TOTAL SENT
    
    uint256 public totalSent;

    string public lastError;

    /*
    =====================================================
    SEND ETH SAFELY
    =====================================================
    

    function sendETH( address payable _receiver ) external payable{
        /*
            Attempt ETH transfer using call().
        
        emit TransferAttempt( _receiver, msg.value);
        (bool success, ) = _receiver.call{ value: msg.value }("");
        emit TransferResult(success);

        require(success, "ETH transfer failed");
        /*
            Save result.
        
        lastSuccess = success;

        /*
            SAFE HANDLING.

            Revert if transfer failed.
    
        require(  success, "ETH transfer failed" );
        /*
            Update accounting ONLY after success.
        
        totalSent += msg.value;
    }
    

    /*
    =====================================================
    DANGEROUS SEND
    =====================================================

    Ignores success boolean.
    

    function dangerousSend( address payable _receiver)  external  payable {
        /*
            Attempt ETH transfer.
        
        _receiver.call{   value: msg.value }("");
        /*
            DANGEROUS:
            Execution continues even if transfer failed.
        

        totalSent += msg.value;
    }

    /*
    =====================================================
    CHECK CONTRACT BALANCE
    =====================================================
    

    function contractBalance() external view  returns (uint256) {
        return address(this).balance;
    }

    function tryCatchEx(address receiver)external {
        try IReceiver(receiver).increment(){

        }catch Error(string memory reason){
            lastError = reason;
        }catch {
        lastError = "Unknown error";
        }
    }

    // transfer():
// Sends ETH with fixed 2300 gas. If it fails, it automatically reverts the transaction. No return value.
     function sendWithTransfer(address payable receiver)external   payable{
        receiver.transfer(msg.value);
    }

    //send():
//Also sends ETH with 2300 gas, but does NOT revert on failure. Returns true or false,
// so you must check it manually.

    function sendWithSend( address payable receiver)external payable{
    bool success =receiver.send(msg.value);
    lastSuccess = success;
    }

    // call():
// Sends ETH with all available gas and returns (success, data). Must check success manually,
// otherwise failures can be ignored.
    function sendWithCall(address payable receiver)external payable{
    (bool success,) =receiver.call{value: msg.value}("");
      require(success, "ETH transfer failed");
    lastSuccess = success;
     }
}


contract RejectETH {
    receive() external payable {
        revert("ETH rejected");
    }
}
*/
/*
=========================================================
NON-PAYABLE RECEIVER
=========================================================
*/

contract NonPayableReceiverVul {

    uint256 public counter;

    function increment() external {
        counter++;
    }

    /*
        No receive()
        No payable fallback()

        Direct ETH transfer will fail.
    */
}


/*
=========================================================
PAYABLE RECEIVER
=========================================================
*/

contract PayableReceiverVul {

    uint256 public receivedAmount;

    event ETHReceived(
        address indexed sender,
        uint256 amount
    );

    /*
        RECEIVE ETH
    */
    receive() external payable {
        receivedAmount += msg.value;

        emit ETHReceived(
            msg.sender,
            msg.value
        );
    }

    /*
        PAYABLE FALLBACK
        Runs when:
        - ETH is sent with unknown calldata
        - No matching function is found
    */
    fallback() external payable {

        receivedAmount += msg.value;

        emit ETHReceived(
            msg.sender,
            msg.value
        );
    }
}


/*
=========================================================
SENDER CONTRACT
=========================================================
*/

contract ETHSenderVul {

    bool public lastSuccess;
    uint256 public totalSent;

    /*
        Events
    */

    event ETHSent(
        address indexed receiver,
        uint256 amount,
        string method,
        bool success
    );

    event ETHSendFailed(
        address indexed receiver,
        uint256 amount,
        string reason
    );


    /*
    =====================================================
    1. CALL
    =====================================================
    */

    function sendETH(
        address payable _receiver
    )
        external
        payable
    {
        try this.tryCall(_receiver, msg.value) returns (
            bool success
        ) {

            lastSuccess = success;

            if (success) {

                totalSent += msg.value;

                emit ETHSent(
                    _receiver,
                    msg.value,
                    "call",
                    true
                );

            } else {

                emit ETHSendFailed(
                    _receiver,
                    msg.value,
                    "call failed"
                );
            }

        } catch {

            lastSuccess = false;

            emit ETHSendFailed(
                _receiver,
                msg.value,
                "call reverted"
            );

            revert("ETH transfer failed");
        }
    }


    /*
        Helper function for try/catch.

        call() itself returns false when the
        low-level call fails.
    */

    function tryCall(
        address payable _receiver,
        uint256 _amount
    )
        external
        returns (bool)
    {
        (bool success, ) = _receiver.call{
            value: _amount
        }("");

        return success;
    }


    /*
    =====================================================
    2. TRANSFER
    =====================================================
    */

    function sendUsingTransfer(
        address payable _receiver
    )
        external
        payable
    {
        /*
            transfer() automatically reverts
            when the transfer fails.
        */

        _receiver.transfer(msg.value);

        totalSent += msg.value;

        emit ETHSent(
            _receiver,
            msg.value,
            "transfer",
            true
        );
    }


    /*
    =====================================================
    3. SEND
    =====================================================
    */

    function sendUsingSend(
        address payable _receiver
    )
        external
        payable
    {
        /*
            send() returns true/false.
            It does NOT automatically revert.
        */

        bool success = _receiver.send(msg.value);

        lastSuccess = success;

        if (!success) {

            emit ETHSendFailed(
                _receiver,
                msg.value,
                "send failed"
            );

            revert("ETH send failed");
        }

        totalSent += msg.value;

        emit ETHSent(
            _receiver,
            msg.value,
            "send",
            true
        );
    }


    /*
    =====================================================
    4. DANGEROUS CALL
    =====================================================
    */

    function dangerousSend(
        address payable _receiver
    )
        external
        payable
    {
        /*
            call() returns success.

            We intentionally ignore it here.
        */

        _receiver.call{
            value: msg.value
        }("");

        /*
            Accounting happens even if
            the ETH transfer failed.
        */

        totalSent += msg.value;

        emit ETHSent(
            _receiver,
            msg.value,
            "dangerous call",
            true
        );
    }


    /*
    =====================================================
    CONTRACT BALANCE
    =====================================================
    */

    function contractBalance()
        external
        view
        returns (uint256)
    {
        return address(this).balance;
    }
}