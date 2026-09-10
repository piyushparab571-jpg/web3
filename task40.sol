// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Add nested if conditions
CONCEPT: Branching logic
=========================================================

OBJECTIVE

- Learn nested if-condition execution
- Understand branching logic in Solidity
- Learn multi-level decision flow
- Understand auditor-style path tracing

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Nested if statements create:
multiple execution branches.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Different inputs cause:
different execution paths.

Auditors must trace:
EVERY possible branch.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Many vulnerabilities hide inside:
rare execution branches.

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Nested branching appears in:

- access control
- DeFi fee systems
- staking rewards
- liquidation logic
- governance rules
- NFT minting limits

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- unreachable branches
- incorrect conditions
- missing else logic
- privilege escalation
- inconsistent state updates

=========================================================
*/
/*
contract NestedIfConditionsVul {

    /*
        OWNER ADDRESS
    
    address public owner;

    /*
        USER SCORES
    
    mapping(address => uint256) public scores;

    /*
        USER LEVELS
    
    mapping(address => string) public levels;

    /*
        CONSTRUCTOR
    
    constructor() {

        owner = msg.sender;
    }

    /*
    =====================================================
    NESTED IF LOGIC
    =====================================================
    

    function evaluateUser(uint256 _score,bool _premium)external{
        /*
            FIRST BRANCH
            Check minimum score.
        
        if (_score >= 50) {

            /*
                SECOND BRANCH

                Check premium status.
            
            if (_premium == true) {

                /*
                    THIRD BRANCH

                    Check elite score.
                
                if (_score >= 90) {

                    levels[msg.sender] =
                        "Elite Premium";

                } else {

                    levels[msg.sender] =
                        "Premium";
                }

            } else {

                /*
                    NON-PREMIUM USER
                
                levels[msg.sender] =
                    "Standard";
            }

            /*
                SAVE SCORE
            
            scores[msg.sender] = _score;

        } else {

            /*
                LOW SCORE BRANCH
            
            levels[msg.sender] =
                "Rejected";
        }
    }

    /*
    =====================================================
    OWNER BONUS FUNCTION
    =====================================================
    

    function ownerBonus(
        address _user
    )
        external
    {

        /*
            FIRST CONDITION:
            owner check
        
        if (msg.sender == owner) {

            /*
                SECOND CONDITION:
                user must exist
            
            if (scores[_user] > 0) {

                /*
                    THIRD CONDITION:
                    high score required
                
                if (scores[_user] >= 80) {

                    scores[_user] += 20;
                }
            }
        }
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
evaluateUser(95, true)

=========================================================

STEP 1:
if (_score >= 50)

CHECK:
95 >= 50

RESULT:
true

---------------------------------------------------------

STEP 2:
if (_premium == true)

CHECK:
true == true

RESULT:
true

---------------------------------------------------------

STEP 3:
if (_score >= 90)

CHECK:
95 >= 90

RESULT:
true

---------------------------------------------------------

EXECUTION PATH:

Elite Premium branch

---------------------------------------------------------

FINAL STORAGE:

levels[user] = "Elite Premium"

scores[user] = 95

=========================================================
ANOTHER TRACE
=========================================================

CALL:
evaluateUser(60, false)

---------------------------------------------------------

STEP 1:
60 >= 50

RESULT:
true

---------------------------------------------------------

STEP 2:
premium == true

RESULT:
false

---------------------------------------------------------

EXECUTION PATH:

Standard branch

---------------------------------------------------------

FINAL STATE:

levels[user] = "Standard"

=========================================================
LOW SCORE TRACE
=========================================================

CALL:
evaluateUser(20, true)

---------------------------------------------------------

STEP 1:
20 >= 50

RESULT:
false

---------------------------------------------------------

EXECUTION JUMPS TO:

else branch

---------------------------------------------------------

FINAL STATE:

levels[user] = "Rejected"

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
evaluateUser(95, true)

---------------------------------------------------------

STEP 3:
Call:
levels(your_address)

EXPECTED:
"Elite Premium"

---------------------------------------------------------

STEP 4:
Call:
evaluateUser(60, false)

EXPECTED:
"Standard"

---------------------------------------------------------

STEP 5:
Call:
evaluateUser(20, true)

EXPECTED:
"Rejected"

---------------------------------------------------------

STEP 6:
Call:
ownerBonus(your_address)

FROM:
owner account

---------------------------------------------------------

STEP 7:
Call:
scores(your_address)

OBSERVE:
Bonus added if conditions met

=========================================================
IMPORTANT BRANCHING UNDERSTANDING
=========================================================

Nested if statements create:
multiple execution paths.

---------------------------------------------------------

Every branch may:
- modify state differently
- skip logic
- create vulnerabilities

=========================================================
EXECUTION TREE
=========================================================

Example:

IF score >= 50
    |
    +-- premium?
          |
          +-- elite?
          |
          +-- standard

---------------------------------------------------------

Auditors mentally trace:
ALL branches.

=========================================================
WHY NESTED LOGIC IS DANGEROUS
=========================================================

Complex branching may cause:

- forgotten edge cases
- inconsistent updates
- bypass conditions
- privilege escalation

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. MISSING ELSE BRANCH
---------------------------------------------------------

State may remain unchanged unexpectedly.

---------------------------------------------------------
2. UNREACHABLE CODE
---------------------------------------------------------

Incorrect condition order
may block execution paths.

---------------------------------------------------------
3. INCONSISTENT STATE
---------------------------------------------------------

Different branches may:
update state differently.

---------------------------------------------------------
4. PRIVILEGE ESCALATION
---------------------------------------------------------

Incorrect nested checks
may bypass authorization.

=========================================================
GAS OBSERVATION
=========================================================

More branching:
More execution complexity.

---------------------------------------------------------

Deeper nesting:
Harder auditing.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- Can attacker reach hidden branch?
- Are all paths validated?
- Does every path maintain invariants?
- Are branches mutually exclusive?
- Is state updated consistently?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Developer forgets else branch.

Attacker triggers unexpected path.

Result:
stale or corrupted state.

---------------------------------------------------------

ANOTHER RISK

Incorrect nested access-control logic
may allow unauthorized execution.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. Every condition
2. Every branch
3. Every state update
4. Every revert path
5. Every skipped operation

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add blacklist logic
2. Add VIP user branch
3. Add paused-contract branch

Then manually trace:
ALL execution paths.

BONUS:
Convert nested ifs into:
require() + early returns.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Nested if creates multiple execution paths
- Branching changes execution flow
- Auditors must trace every branch
- Missing branches create vulnerabilities
- Complex logic increases audit difficulty
- State updates differ across branches
- Incorrect nesting may bypass checks
- Edge cases matter heavily
- Branch analysis is critical in auditing
- Execution tracing is essential for security reviews

=========================================================
*/

/*
=========================================================
AUDIT REPORT
=========================================================

Title:
Inconsistent State Updates Due to Missing Branch Handling

Severity:
Medium

Contract:
NestedIfConditionsVul

Function:
evaluateUser()

=========================================================
VULNERABILITY DESCRIPTION
=========================================================

The evaluateUser() function uses
deep nested branching logic.

However:

not all execution paths update state
consistently.

The low-score branch updates only:

- levels[msg.sender]

but does NOT update:

- scores[msg.sender]

This creates stale storage values.

=========================================================
IMPACT
=========================================================

A user may become "Rejected"
while still retaining an old high score.

This creates inconsistent protocol state.

Potential risks:

- incorrect reward calculations
- stale ranking information
- invalid eligibility checks
- corrupted future protocol logic

=========================================================
PROOF OF CONCEPT
=========================================================

        1. User calls:
        evaluateUser(95, true)
        RESULT:

        levels[user] = "Elite Premium"
        scores[user] = 95

        2. User later calls:
        evaluateUser(20, true)

        LOW SCORE BRANCH EXECUTES:
        else {
            levels[msg.sender] = "Rejected";
        }

        RESULT:
        levels[user] = "Rejected"
        BUT:
        scores[user] STILL = 95

        FINAL STATE:
        Rejected user still has elite score.

=========================================================
ROOT CAUSE
=========================================================

Different execution branches update
storage differently.

Problematic branch:
else {
    levels[msg.sender] = "Rejected";
}
does not reset or update:
scores[msg.sender]

=========================================================
RECOMMENDATION
=========================================================

Ensure ALL execution branches update
state consistently.

Example fix:

    else {

        levels[msg.sender] = "Rejected";

        scores[msg.sender] = _score;
    }

OR:

    scores[msg.sender] = 0;
    depending on intended business logic.

*/

//patched code
/*
contract NestedIfConditions{
    address public owner;
    bool public paused;

    mapping (address=>uint256)public scores;
    mapping (address=>string)public levels;
    mapping (address=>bool)public blacklisted;

    constructor(){
        owner=msg.sender;
    }

    function setPaused(bool _status)external {
        require(msg.sender==owner,"Not owner");
        paused=_status;
    }

    function blacklistUser(address _user)external {
        require(msg.sender==owner,"Not Owner");
        blacklisted[_user]=true; // blocked user
    }

    function evaluateUser(uint256 _score,bool _premium,bool _vip)external {
        require(paused == false, "Contract paused");
        require(blacklisted[msg.sender] == false,"Blacklisted user");

         if (_score < 50) {
            levels[msg.sender] = "Rejected";
            scores[msg.sender] = _score;
            return; //stop function immediately,skip remaining code
        }

         if (_vip == true) {
            if (_score >= 95) {
                levels[msg.sender] = "VIP Elite";
            } else {
                levels[msg.sender] = "VIP";
            }
            scores[msg.sender] = _score;
            return; //stop function immediately,skip remaining code
        }
         if (_premium == true) {
            if (_score >= 90) {
                levels[msg.sender] = "Elite Premium";
            } else {
                levels[msg.sender] = "Premium";
            }
            scores[msg.sender] = _score;
            return; //stop function immediately,skip remaining code
        }
        levels[msg.sender] = "Standard";
        scores[msg.sender] = _score;
    }
}
*/
/*
contract NestedIfConditionsVul {
    address public owner;
    bool public paused;
    mapping(address => uint) public scores;
    mapping(address => string) public levels;
    mapping(address => bool) public blacklisted;
    mapping(address => bool) public vip;
    constructor() {
        owner = msg.sender;
    }
    function evaluateUser(uint _score, bool _premium)
        external
    {
        require(!paused, "Paused");
        require(!blacklisted[msg.sender], "Blacklisted");
        if (vip[msg.sender]) {
            levels[msg.sender] = "VIP";
            return;
        }
        if (_score < 50) {
            levels[msg.sender] = "Rejected";
            return;
        }
        if (_premium && _score >= 90)
            levels[msg.sender] = "Elite Premium";
        else if (_premium)
            levels[msg.sender] = "Premium";
        else
            levels[msg.sender] = "Standard";
        scores[msg.sender] = _score;
    }
    function setPaused(bool _status) external {
        require(msg.sender == owner, "Not owner");
        paused = _status;
    }
    function setBlacklist(address _user) external {
        require(msg.sender == owner, "Not owner");
        blacklisted[_user] = true;
    }
    function setVIP(address _user) external {
        require(msg.sender == owner, "Not owner");
        vip[_user] = true;
    }
}
*/