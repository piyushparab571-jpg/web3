// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Ignore success boolean from call
CONCEPT: Dangerous coding
=========================================================

OBJECTIVE

- Learn why unchecked call() is dangerous
- Understand silent external-call failures
- Learn inconsistent state vulnerabilities
- Think like professional auditor

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Low-level call() returns:

(bool success, bytes memory data)

---------------------------------------------------------

If success is ignored:

execution may continue
even when external call FAILED.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

This creates:
silent failure vulnerabilities.

---------------------------------------------------------

Protocol may assume:
external interaction succeeded.

---------------------------------------------------------

Reality:
it failed completely.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Unchecked external calls caused:

- stuck funds
- accounting corruption
- broken logic
- DOS vulnerabilities
- protocol inconsistencies

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

External calls exist in:

- token transfers
- swaps
- governance execution
- vault withdrawals
- bridges
- staking systems

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors ALWAYS inspect:

- ignored success booleans
- unchecked external calls
- silent failures
- accounting assumptions
- inconsistent state

=========================================================
MALICIOUS / FAILING CONTRACT
=========================================================
*/
/*
contract RejectETHVul {
    /*
        Track calls

    uint256 public counter;
    /*
    =====================================================
    ALWAYS REVERT ON ETH
    =====================================================
    
    receive() external payable{
        revert("ETH rejected");
    }

    /*
    =====================================================
    ALWAYS FAIL FUNCTION
    =====================================================
    

    function failFunction()  external pure {
        revert("Function failed");
    }

    /*
    =====================================================
    SUCCESS FUNCTION
    =====================================================
    

    function successFunction()  external{
        /*
            Increment counter.
        
        counter++;
    }
}

/*
=========================================================
VULNERABLE CONTRACT
=========================================================


contract DangerousUncheckedCallVul {
    /*
        USER BALANCES
    
    mapping(address => uint256) public balances;

    /*
        TRACK WITHDRAWALS
    
    mapping(address => bool) public withdrawn;

    /*
    =====================================================
    DEPOSIT ETH
    =====================================================
    

    function deposit()   external payable {
        balances[msg.sender] += msg.value;
    }

    /*
    =====================================================
    DANGEROUS WITHDRAW
    =====================================================

    PROBLEM:
    ignores success boolean.
    
    function dangerousWithdraw( address payable _receiver, uint256 _amount)external{
        /*
            Validate balance.
        
        require(balances[msg.sender] >= _amount,"Insufficient balance");
        /*
            EFFECTS:
            Update storage FIRST.
        
        balances[msg.sender] -= _amount;

        withdrawn[msg.sender] = true;

        /*
        =================================================
        DANGEROUS EXTERNAL CALL
        =================================================

        ETH transfer may FAIL.

        BUT:
        success boolean ignored.
        

        _receiver.call{ value: _amount }("");

        /*
            Execution continues regardless.

            HUGE PROBLEM.
        
    }

    /*
    =====================================================
    SAFE VERSION
    =====================================================
    

    function safeWithdraw( address payable _receiver,  uint256 _amount)    external {
        /*
            Validate balance.
        
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            Update storage.
        
        balances[msg.sender] -= _amount;

        /*
            Properly check success.
    
        (bool success, ) =_receiver.call{value: _amount  }("");
        /*
            Revert if transfer failed.
        
        require( success,"ETH transfer failed");
    }

    /*
    =====================================================
    CHECK CONTRACT BALANCE
    =====================================================
    

    function contractBalance()  external view   returns (uint256) {
        return address(this).balance;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy RejectETH

---------------------------------------------------------

STEP 2:
Deploy DangerousUncheckedCall

=========================================================
TRACE:
dangerousWithdraw()
=========================================================

STEP 1:
User deposits ETH.

---------------------------------------------------------

balances[user] = 1 ETH

=========================================================
STEP 2
=========================================================

Call:
dangerousWithdraw()

---------------------------------------------------------

Receiver:
RejectETH contract

=========================================================
STEP 3
=========================================================

Balance validation passes.

=========================================================
STEP 4
=========================================================

Storage updated FIRST.

---------------------------------------------------------

balances[user] -= 1 ETH

---------------------------------------------------------

withdrawn[user] = true

=========================================================
STEP 5
=========================================================

External ETH call executes.

---------------------------------------------------------

Receiver contract:
REVERTS intentionally.

=========================================================
STEP 6
=========================================================

IMPORTANT:

call() returns:

success = false

---------------------------------------------------------

BUT:

success is IGNORED.

=========================================================
STEP 7
=========================================================

Execution continues normally.

---------------------------------------------------------

Transaction DOES NOT revert.

=========================================================
FINAL RESULT
=========================================================

PROBLEM:

---------------------------------------------------------
USER BALANCE REDUCED
---------------------------------------------------------

YES

---------------------------------------------------------
withdrawn FLAG SET
---------------------------------------------------------

YES

---------------------------------------------------------
ETH ACTUALLY TRANSFERRED?
---------------------------------------------------------

NO

=========================================================
CRITICAL VULNERABILITY
=========================================================

Internal accounting says:
withdraw succeeded.

---------------------------------------------------------

Reality:
ETH never transferred.

=========================================================
WHY THIS IS DANGEROUS
=========================================================

Creates:
INCONSISTENT STATE.

---------------------------------------------------------

Protocol assumptions become false.

=========================================================
SAFE VERSION TRACE
=========================================================

safeWithdraw()

=========================================================

STEP 1:
External call fails.

---------------------------------------------------------

success = false

=========================================================
STEP 2
=========================================================

require(success)

---------------------------------------------------------

Transaction REVERTS.

=========================================================
STEP 3
=========================================================

ALL state changes rollback.

---------------------------------------------------------

balances restored.

---------------------------------------------------------

No inconsistent state.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy RejectETH
---------------------------------------------------------

STEP 2:
Deploy DangerousUncheckedCall

---------------------------------------------------------

STEP 3:
Deposit 1 ETH

---------------------------------------------------------

STEP 4:
Call:
dangerousWithdraw()

Inputs:
- RejectETH address
- 1 ether

---------------------------------------------------------

EXPECTED:
Transaction succeeds unexpectedly.

=========================================================
STEP 5
=========================================================

Check:

balances(user)

EXPECTED:
0

---------------------------------------------------------

withdrawn(user)

EXPECTED:
true

---------------------------------------------------------

BUT:
RejectETH received NO ETH.

=========================================================
STEP 6
=========================================================

Test:
safeWithdraw()

---------------------------------------------------------

EXPECTED:
Transaction reverts safely.

=========================================================
IMPORTANT LOW-LEVEL CALL UNDERSTANDING
=========================================================

call() NEVER auto-reverts.

---------------------------------------------------------

Developer MUST manually check:

success

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. UNCHECKED RETURN VALUES
---------------------------------------------------------

Classic Solidity vulnerability.

---------------------------------------------------------
2. ACCOUNTING CORRUPTION
---------------------------------------------------------

Internal state diverges from reality.

---------------------------------------------------------
3. SILENT FAILURES
---------------------------------------------------------

Protocol believes operation succeeded.

---------------------------------------------------------
4. DOS CONDITIONS
---------------------------------------------------------

Malicious contracts block execution silently.

=========================================================
IMPORTANT SECURITY CONCEPT
=========================================================

External calls are:
UNTRUSTED INTERACTIONS.

---------------------------------------------------------

Assume:
external execution may fail.

=========================================================
ATTACK THINKING
=========================================================

Attacker intentionally:

- rejects ETH
- reverts calls
- breaks assumptions
- causes inconsistent state

---------------------------------------------------------

Protocol logic becomes corrupted.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ALWAYS search for:

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

1. External interaction
2. Failure handling
3. Return-value checks
4. Accounting consistency
5. Silent-failure paths

=========================================================
WHY THIS BUG IS SUBTLE
=========================================================

Transaction appears:
successful.

---------------------------------------------------------

But:
protocol state corrupted internally.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add event logging
2. Add try/catch handling
3. Add revert-message decoding
4. Compare checked vs unchecked execution

BONUS:
Create token-transfer version
of unchecked-call bug.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- call() returns success manually
- Ignoring success is dangerous
- External calls may silently fail
- Silent failures corrupt accounting
- Transactions only revert if forced
- require(success) prevents inconsistencies
- Unchecked calls are major audit issue
- External interactions are untrusted
- Auditors inspect return-value handling carefully
- Error handling is critical in Solidity security

=========================================================
*/
/*
//patched code
contract RejectETH {
    /*
        Track calls
    
    uint256 public counter;

    /*
    =====================================================
    ALWAYS REVERT ON ETH
    =====================================================
    

    receive()
        external
        payable
    {

        revert("ETH rejected");
    }

    /*
    =====================================================
    ALWAYS FAIL FUNCTION
    =====================================================
    

    function failFunction()
        external
        pure
    {

        revert("Function failed");
    }

    /*
    =====================================================
    SUCCESS FUNCTION
    =====================================================
    

    function successFunction()
        external
    {

        /*
            Increment counter.
        
        counter++;
    }
}

/*
=========================================================
VULNERABLE CONTRACT
=========================================================


contract DangerousUncheckedCall{

    event CallSuccess(address target);
    event CallFail(address target, string reason);
    event UnsafeCall(address target, uint256 amount);

    /*
        USER BALANCES
    
    mapping(address => uint256) public balances;

    /*
        TRACK WITHDRAWALS
    
    mapping(address => bool) public withdrawn;

    bool public lastSuccess;
    string public lastError;

    /*
    =====================================================
    DEPOSIT ETH
    =====================================================
    

    function deposit()
        external
        payable
    {

        balances[msg.sender] += msg.value;
    }

    /*
    =====================================================
    DANGEROUS WITHDRAW
    =====================================================

    PROBLEM:
    ignores success boolean.
    

    function dangerousWithdraw( address payable _receiver, uint256 _amount)external{
        /*
            Validate balance.
        
        require(balances[msg.sender] >= _amount,"Insufficient balance");
        /*
            EFFECTS:
            Update storage FIRST.
        
        balances[msg.sender] -= _amount;

        withdrawn[msg.sender] = true;

         emit UnsafeCall(_receiver, _amount);

        /*
        =================================================
        DANGEROUS EXTERNAL CALL
        =================================================

        ETH transfer may FAIL.

        BUT:
        success boolean ignored.
        

        _receiver.call{ value: _amount }("");

        /*
            Execution continues regardless.

            HUGE PROBLEM.
        
    }

    /*
    =====================================================
    SAFE VERSION
    =====================================================
    

    function safeWithdraw( address payable _receiver,  uint256 _amount)    external {
        /*
            Validate balance.
        
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            Update storage.
        
        balances[msg.sender] -= _amount;

        /*
            Properly check success.
        
        (bool success, ) =_receiver.call{value: _amount  }("");
        /*
            Revert if transfer failed.
        
        if (!success) {
            emit CallFail(_receiver, "ETH transfer failed");
            revert("Transfer failed");
        }

        emit CallSuccess(_receiver);
    }

      function tryWithdraw(address _receiver) external {

        try RejectETHVul(payable(_receiver)).successFunction() {
            lastSuccess = true;
            lastError = "successFunction worked";
            emit CallSuccess(_receiver);
        }catch Error(string memory reason) {
            lastSuccess = false;
            lastError = reason;
            emit CallFail(_receiver, reason);
        }catch {
            lastSuccess = false;
            lastError = "Unknown error";
            emit CallFail(_receiver, "unknown");
        }
    }
// calling another contract using low-level call
    function callWithDecode(address _target)internal{
        (bool success,bytes memory data)=_target.call(abi.encodeWithSignature("failfunction()"));
        if (!success) {
            // converts raw bytes → human readable error
            string memory reason = _getRevertMsg(data);

            lastError = reason;
            lastSuccess = false;

            emit CallFail(_target, reason);
        } else {
            emit CallSuccess(_target);
        }
    }

     function _getRevertMsg(bytes memory data) internal pure returns (string memory) {
        if (data.length < 68) return "Unknown error";
        assembly {
            data := add(data, 0x04)
        }
        return abi.decode(data, (string));
    }

    function contractBalance()external view returns (uint256){
        return address(this).balance;
    }
}

contract TokenVul {
    mapping(address => uint256) public balance;

    event Transfer(address from, address to, uint amount);

    function mint(address user, uint amount) external {
        balance[user] += amount;
    }

    //  BUG VERSION (unchecked external call style logic)
    function transfer(address to, uint amount) external {
        require(balance[msg.sender] >= amount, "no balance");
        balance[msg.sender] -= amount;
        // assume success blindly (simulated external hook)
        to.call("");
        emit Transfer(msg.sender, to, amount);
    }

  
    function safeTransfer(address to, uint amount) external {
        require(balance[msg.sender] >= amount, "no balance");
        balance[msg.sender] -= amount;
        (bool success,) = to.call("");
        require(success, "transfer failed");
        emit Transfer(msg.sender, to, amount);
    }
}
*/
contract RejectETHVul {
    uint public counter;
    receive() external payable {
        revert("ETH rejected");
    }
    function failFunction() external pure {
        revert("Function failed");
    }
    function successFunction() external {
        counter++;
    }
}
contract DangerousUncheckedCallVul {
    mapping(address => uint) public balances;
    event Withdraw(address user, uint amount, bool success);
    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }
    // Unchecked call
    function uncheckedWithdraw(
        address payable receiver,
        uint amount
    ) external {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        receiver.call{value: amount}("");
        emit Withdraw(msg.sender, amount, false);
    }
    // Checked call
    function checkedWithdraw(
        address payable receiver,
        uint amount
    ) external {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        (bool success, ) =
            receiver.call{value: amount}("");
        emit Withdraw(msg.sender, amount, success);
        require(success, "Transfer failed");
    }
    // Try / Catch
 function tryCatch(address target) external {
    try RejectETHVul(payable(target)).failFunction() {
        emit Withdraw(msg.sender, 0, true);
    }
    catch {
        emit Withdraw(msg.sender, 0, false);
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
        if (success) return "Success";
        if (data.length >= 68) {
            assembly {
                data := add(data, 4)
            }
            return abi.decode(data, (string));
        }
        return "Unknown error";
    }
}