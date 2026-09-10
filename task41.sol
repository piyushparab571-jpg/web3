// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Return early from function
CONCEPT: Execution stopping
=========================================================

OBJECTIVE

- Learn how early return works
- Understand execution stopping behavior
- Learn control-flow optimization
- Understand auditor-style execution tracing

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

return immediately stops:
- function execution
- remaining code execution
- further state changes

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Once return executes:

Everything after it is skipped.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Early return is heavily used for:

- validation
- optimization
- branch control
- error handling
- gas reduction

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Used in:

- ERC20 logic
- DeFi routers
- staking systems
- access control
- governance systems
- liquidation checks

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- skipped code paths
- unreachable logic
- missed state updates
- incorrect return placement
- authorization bypasses

=========================================================
*/
/*
contract EarlyReturnExampleVul {
    /*
        STORAGE VARIABLES
    
    mapping(address => uint256) public balances;

    bool public paused;

    /*
    =====================================================
    TOGGLE PAUSE
    =====================================================
    


    function setPaused(
        bool _status
    )
        external
    {

        paused = _status;
    }

    /*
    =====================================================
    EARLY RETURN EXAMPLE
    =====================================================
    

    function deposit(
        uint256 _amount
    )
        external
    {

        /*
            STEP 1:
            Check paused state.
        
        if (paused == true) {

            /*
                EARLY RETURN

                Function stops here.
            
            return;
        }

        /*
            STEP 2:
            Reject zero amount.
        
        if (_amount == 0) {

            /*
                EARLY RETURN

                Remaining code skipped.
            
            return;
        }

        /*
            STEP 3:
            Update balance.

            Executes ONLY if:
            - not paused
            - amount > 0
    
        balances[msg.sender] += _amount;
    }

    /*
    =====================================================
    RETURN VALUE EARLY
    =====================================================
    

    function checkLevel(
        uint256 _score
    )
        external
        pure
        returns (string memory)
    {

        /*
            FIRST BRANCH
        
        if (_score >= 90) {

            return "Elite";
        }

        /*
            SECOND BRANCH
        
        if (_score >= 50) {

            return "Standard";
        }

        /*
            DEFAULT BRANCH
        
        return "Rejected";
    }

    /*
    =====================================================
    UNREACHABLE CODE DEMO
    =====================================================
    

    function unreachableExample()
        external
        pure
        returns (uint256)
    {

        /*
            FUNCTION RETURNS HERE
        
        return 100;

        /*
            UNREACHABLE CODE

            Never executes.
        

        // uint256 x = 999;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

INITIAL STATE

paused = false

balances[Alice] = 0

=========================================================
TRACE:
deposit(10)
=========================================================

---------------------------------------------------------
STEP 1
---------------------------------------------------------

if (paused == true)

CHECK:
false == true

RESULT:
false

Execution continues.

---------------------------------------------------------
STEP 2
---------------------------------------------------------

if (_amount == 0)

CHECK:
10 == 0

RESULT:
false

Execution continues.

---------------------------------------------------------
STEP 3
---------------------------------------------------------

balances[Alice] += 10

FINAL STATE:

balances[Alice] = 10

=========================================================
EARLY RETURN TRACE
=========================================================

SET:
paused = true

---------------------------------------------------------

CALL:
deposit(10)

---------------------------------------------------------
STEP 1
---------------------------------------------------------

if (paused == true)

CHECK:
true == true

RESULT:
true

---------------------------------------------------------

RETURN EXECUTES

---------------------------------------------------------

FUNCTION STOPS IMMEDIATELY

---------------------------------------------------------

STEP 2 and STEP 3 NEVER EXECUTE

---------------------------------------------------------

FINAL STATE:

balances[Alice] unchanged

=========================================================
ANOTHER TRACE
=========================================================

CALL:
checkLevel(95)

---------------------------------------------------------

FIRST IF:
95 >= 90

RESULT:
true

---------------------------------------------------------

RETURN "Elite"

---------------------------------------------------------

FUNCTION ENDS IMMEDIATELY

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
deposit(10)

---------------------------------------------------------

STEP 3:
Call:
balances(your_address)

EXPECTED:
10

---------------------------------------------------------

STEP 4:
Call:
setPaused(true)

---------------------------------------------------------

STEP 5:
Call:
deposit(50)

---------------------------------------------------------

STEP 6:
Call:
balances(your_address)

EXPECTED:
Still 10

---------------------------------------------------------

OBSERVE:
Function returned early.

---------------------------------------------------------

STEP 7:
Call:
checkLevel(95)

EXPECTED:
"Elite"

---------------------------------------------------------

STEP 8:
Call:
checkLevel(60)

EXPECTED:
"Standard"

---------------------------------------------------------

STEP 9:
Call:
checkLevel(20)

EXPECTED:
"Rejected"

=========================================================
IMPORTANT EXECUTION UNDERSTANDING
=========================================================

return does TWO things:

1. optionally returns value
2. STOPS execution immediately

=========================================================
VERY IMPORTANT
=========================================================

Any code AFTER return:
is unreachable.

---------------------------------------------------------

Unreachable code:
never executes.

=========================================================
EARLY RETURN VS REQUIRE
=========================================================

---------------------------------------------------------
EARLY RETURN
---------------------------------------------------------

- Stops execution silently
- No revert
- State before return persists

---------------------------------------------------------
REQUIRE
---------------------------------------------------------

- Reverts transaction
- Undoes state changes
- Throws error

=========================================================
WHEN EARLY RETURN IS USEFUL
=========================================================

GOOD FOR:

- optional execution
- gas optimization
- branch exits
- skip logic
- read-only checks

=========================================================
WHEN REQUIRE IS BETTER
=========================================================

GOOD FOR:

- validation
- security rules
- invariant enforcement
- authorization

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. SKIPPED SECURITY CHECKS
---------------------------------------------------------

Early return may bypass logic accidentally.

---------------------------------------------------------
2. UNREACHABLE CODE
---------------------------------------------------------

Dead code increases confusion.

---------------------------------------------------------
3. PARTIAL EXECUTION
---------------------------------------------------------

Some state may update
before early return.

---------------------------------------------------------
4. LOGIC FRAGMENTATION
---------------------------------------------------------

Too many returns make auditing harder.

=========================================================
GAS OBSERVATION
=========================================================

Early return:
can reduce gas usage.

---------------------------------------------------------

Reason:
remaining code skipped.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- Which paths return early?
- What code becomes unreachable?
- Are security checks skipped?
- Can attacker abuse branch exits?
- Does state remain consistent?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Developer places return incorrectly.

Critical validation skipped.

Result:
authorization bypass.

---------------------------------------------------------

ANOTHER RISK

Partial state update before return
may break invariants.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. Every return point
2. Remaining skipped logic
3. State before return
4. State after return
5. Reachable vs unreachable code

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add blacklist logic
2. Return early for blacklisted users
3. Add require() version too
4. Compare behavior carefully

BONUS:
Create function with:
multiple nested early returns.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- return stops execution immediately
- Remaining code becomes unreachable
- Early return does NOT revert transaction
- require() and return behave differently
- Early returns can optimize gas
- Incorrect returns may skip security checks
- Auditors trace all execution exits
- Branch analysis is critical
- Partial execution must be understood
- Control flow impacts security heavily

=========================================================
*/

/*
Audit Report

Title: Missing Access Control and Silent Execution Failure in deposit()

Severity: Medium

Reason: Unauthorized users can pause the contract, and early return silently skips execution without reverting.

Location:
    Contract: EarlyReturnExampleVul

Functions:
    * setPaused()
    * deposit()

Vulnerability Description:

The `setPaused()` function allows any external user to modify the `paused` state variable because no access control mechanism is implemented.

Additionally, the `deposit()` function uses early `return` statements instead of `require()` checks.

When the contract is paused or `_amount == 0`, the function silently exits without reverting the transaction or showing an error.

This may confuse users because transactions appear successful while no state update occurs.

Impact:

An attacker can:

* pause the contract
* block deposit functionality
* disrupt protocol behavior

Users may:

* believe deposits succeeded
* receive no failure message
* misunderstand contract state

Proof of Concept:
    1..Deploy the contract.
    2.User A calls:
        deposit(10)
    3.State becomes:
        balances[UserA] = 10
    4.Attacker calls:
        setPaused(true)

    Now any user calling:
    deposit(50)

    Triggers:

    if (paused == true) {
        return;
    }
    Execution stops silently.

    Final state:
    balances[user] unchanged

    No revert occurs.

Root Cause:

    1. Missing access control in:

    function setPaused(bool _status) external

    2. Use of early return instead of validation checks:

    if (paused == true) {
        return;
    }

    and

    if (_amount == 0) {
        return;
    }

Recommendation:

    1. Restrict pause functionality using owner-based authorization.

    Example:

    require(msg.sender == owner, "not owner");

    2. Use `require()` for security-critical validation instead of silent early returns.

Example:

    require(!paused, "Contract is Paused");
    require(_amt > 0, "Invalid Amount");

*/

//patched code
/*
contract EarlyReturnExample {
    /*
        STORAGE VARIABLES
    
      address public owner;
    mapping(address => uint256) public balances;
    mapping (address=>bool)public blackList;

    bool public paused;

    constructor(){
        owner=msg.sender;
    }


    function setPaused( bool _status )external{
        require(msg.sender==owner,"not owner");
        paused = _status;
        }

    function blackListUser(address _user)external{
        require(msg.sender==owner,"not owner");
        blackList[_user] = true;
    }
    /*
    =====================================================
    EARLY RETURN EXAMPLE
    =====================================================
    
    function depositReturn(uint256 _amount)external{
            //Check paused state.
        if (paused == true) {
            /*
                EARLY RETURN
                Function stops here.
            
            return;
        }

        if(blackList[msg.sender]){
            return ;
        }

        if (_amount == 0) {
            /*
                EARLY RETURN
                Remaining code skipped.
            
            return;
        }

        balances[msg.sender] += _amount;
    }

/*
    =====================================================
    REQUIRE VERSION
    =====================================================


    function depositRequire(uint256 _amt)external {
        require(!paused,"Contract is Paused"); // Continue only if contract is NOT paused (paused==false)

        require(!blackList[msg.sender],"User is Blacklisted"); // Continue only if caller is NOT blacklisted

        require(_amt>0,"Invalid Amount");  // Continue only if amount is greater than 0
        balances[msg.sender] += _amt;
    }
}
*/
/*
contract EarlyReturnExampleVul {

    mapping(address => uint256) public balances;
    mapping(address => bool) public blacklisted;
    bool public paused;

    function setPaused(bool _status) external {
        paused = _status;
    }

    function setBlacklist(address _user, bool _status)
        external
    {
        blacklisted[_user] = _status;
    }

    // Early return version
    function deposit(uint256 _amount) external {

        if (paused)
            return;

        if (blacklisted[msg.sender])
            return;

        if (_amount == 0)
            return;

        balances[msg.sender] += _amount;
    }

    // require() version
    function depositRequire(uint256 _amount) external {

        require(!paused, "Paused");
        require(!blacklisted[msg.sender], "Blacklisted");
        require(_amount > 0, "Invalid amount");

        balances[msg.sender] += _amount;
    }

    // Multiple early returns
    function checkUser(uint256 _score)
        external
        view
        returns (string memory)
    {
        if (paused)
            return "Paused";

        if (blacklisted[msg.sender])
            return "Blacklisted";

        if (_score == 0)
            return "No Score";

        if (_score >= 90)
            return "Elite";

        if (_score >= 50)
            return "Standard";

        return "Rejected";
    }
}
```
*/