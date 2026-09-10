// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Use multiple require checks
CONCEPT: Execution guards
=========================================================

OBJECTIVE

- Learn how multiple require() checks work
- Understand execution guards in Solidity
- Learn defensive validation patterns
- Understand fail-fast security design

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

require() acts as an execution guard.

If ANY require() fails:
- execution stops
- transaction reverts
- state changes rollback

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Multiple require() checks create:
layered protection.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Smart contracts must validate:
- caller
- values
- balances
- permissions
- timing
- protocol rules

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Multiple require() checks used in:

- ERC20 transfers
- staking contracts
- governance systems
- lending protocols
- NFT minting
- DEX routers

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- missing validations
- incorrect validation order
- bypass possibilities
- access control flaws
- logic assumptions

=========================================================
*/
/*
contract MultipleRequireChecksVul {
    /*
        OWNER ADDRESS
        Set during deployment.
    
    address public owner;
    /*
        USER BALNCES
    
    mapping(address => uint256) public balances;
    /*
        MAX LIMIT
    
    uint256 public constant MAX_DEPOSIT = 100 ether;
    /*
        CONSTRUCTOR
        Runs once during deployment.
    
    constructor() {
        owner = msg.sender;
    }

    /*
    =====================================================
    DEPOSIT FUNCTION
    =====================================================
    

    function deposit(uint256 _amount)external{
        /*
            REQUIRE #1
            Amount must be positive.
        
        require(_amount > 0,"Amount must be > 0");
        /*
            REQUIRE #2
            Amount must not exceed max limit.
        
        require(
            _amount <= MAX_DEPOSIT,"Deposit too large");
        /*
            REQUIRE #3
            Prevent overflow-like balance growth.
        
        require(balances[msg.sender] + _amount<= 1000 ether,"Balance limit exceeded");
        /*
            EXECUTION REACHES HERE
            ONLY IFALL CHECKS PASS.
        
        balances[msg.sender] += _amount;
    }

    /*
    =====================================================
    OWNER-ONLY RESET
    =====================================================
    
    function resetBalance(
        address _user
    )
        external
    {

        /*
            REQUIRE #1

            Access control.
        
        require(
            msg.sender == owner,
            "Not owner"
        );

        /*
            REQUIRE #2

            Reject zero address.
        
        require(
            _user != address(0),
            "Invalid address"
        );

        /*
            REQUIRE #3

            User must have balance.
        
        require(
            balances[_user] > 0,
            "No balance"
        );

        /*
            RESET USER BALANCE
        
        balances[_user] = 0;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
deposit(10)

=========================================================

STEP 1:
require(10 > 0)

RESULT:
true

---------------------------------------------------------

STEP 2:
require(10 <= MAX_DEPOSIT)

RESULT:
true

---------------------------------------------------------

STEP 3:
Balance limit check

RESULT:
true

---------------------------------------------------------

ALL CHECKS PASSED

---------------------------------------------------------

STORAGE UPDATE:

balances[msg.sender] += 10

=========================================================
FAILURE TRACE
=========================================================

CALL:
deposit(0)

---------------------------------------------------------

STEP 1:
require(0 > 0)

RESULT:
false

---------------------------------------------------------

TRANSACTION REVERTS IMMEDIATELY

---------------------------------------------------------

IMPORTANT:
Other require() checks never execute.

=========================================================
ANOTHER FAILURE TRACE
=========================================================

CALL:
resetBalance(user)

BY:
non-owner

---------------------------------------------------------

STEP 1:
require(msg.sender == owner)

RESULT:
false

---------------------------------------------------------

EXECUTION STOPS IMMEDIATELY

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
deposit(10)

EXPECTED:
Success

---------------------------------------------------------

STEP 3:
Call:
balances(your_address)

EXPECTED:
10

---------------------------------------------------------

STEP 4:
Call:
deposit(0)

EXPECTED:
Revert

---------------------------------------------------------

STEP 5:
Call:
deposit(500 ether)

EXPECTED:
Revert

---------------------------------------------------------

STEP 6:
Switch account in Remix

---------------------------------------------------------

STEP 7:
Call:
resetBalance(your_address)

EXPECTED:
Revert (not owner)

=========================================================
IMPORTANT REQUIRE UNDERSTANDING
=========================================================

require() acts as:
EXECUTION GUARD.

---------------------------------------------------------

If condition fails:
- execution stops
- revert triggered
- state rolled back

=========================================================
FAIL-FAST PRINCIPLE
=========================================================

Solidity follows:
FAIL FAST design.

---------------------------------------------------------

Bad input:
Stop immediately.

=========================================================
ORDER OF REQUIRE CHECKS
=========================================================

BEST PRACTICE:

1. Cheapest checks first
2. Expensive checks later

---------------------------------------------------------

Reason:
Save gas on early failure.

=========================================================
GOOD VALIDATION ORDER
=========================================================

GOOD:

1. msg.sender checks
2. zero-address checks
3. value checks
4. expensive loops/calls

=========================================================
BAD VALIDATION ORDER
=========================================================

BAD:

1. expensive computation
2. external calls
3. validation later

---------------------------------------------------------

Problem:
Wasted gas and risk.

=========================================================
GAS OBSERVATION
=========================================================

FAILED REQUIRE:
Still consumes gas.

---------------------------------------------------------

Earlier failure:
Usually cheaper.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. MISSING REQUIRE CHECKS
---------------------------------------------------------

Very common vulnerability source.

---------------------------------------------------------
2. INCORRECT ACCESS CONTROL
---------------------------------------------------------

Missing owner checks
can destroy protocols.

---------------------------------------------------------
3. VALIDATION ORDER
---------------------------------------------------------

Cheap checks should happen first.
---------------------------------------------------------
4. DEFENSE IN DEPTH
---------------------------------------------------------

Multiple require() checks
create layered security.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Missing require() allows:
- unauthorized access
- invalid balances
- protocol corruption

---------------------------------------------------------

ANOTHER RISK

Incorrect ordering may:
waste gas or expose reentrancy.

=========================================================
REAL AUDITOR QUESTIONS
=========================================================

Auditors ask:

- What assumptions exist?
- Are all assumptions validated?
- Can attacker bypass checks?
- Is access control enforced?
- Are limits bounded safely?

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add withdraw() function
2. Add:
   - pause check
   - balance check
   - owner blacklist check

BONUS:
Replace require strings
with custom errors.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- require() creates execution guards
- Failed require() reverts transaction
- Multiple require() checks add layered protection
- Validation order matters
- Cheap checks should execute first
- Fail-fast principle improves safety
- Missing checks create vulnerabilities
- Access control is critical
- Auditors inspect validation carefully
- Defense-in-depth improves smart contract security

=========================================================
*/

/*
Audit Report

Title: No Critical Vulnerability Detected — Multiple Layered Validation Checks Implemented Correctly

Severity: Informational

Reason:
The vulnerable contract correctly demonstrates
layered require() validation checks and proper
fail-fast(Early validation checks) execution behavior.

No major exploitable vulnerability was identified
in the provided vulnerable contract logic.

The contract properly validates:

- deposit amount
- maximum deposit limits
- balance growth limits
- owner-only access control
- zero-address protection
- existing user balance checks

Location:
    Contract: MultipleRequireChecksVul

Vulnerability Description:

The vulnerable contract was reviewed for:

- missing validation
- access control flaws
- validation bypass
- incorrect require ordering
- balance manipulation risks

The contract correctly applies multiple
execution guards using require() statements.

Example:

require(_amount > 0,"Amount must be > 0");

require(
    _amount <= MAX_DEPOSIT,
    "Deposit too large"
);

require(
    balances[msg.sender] + _amount
        <= 1000 ether,
    "Balance limit exceeded"
);

---------------------------------------------------------

Owner-only protection is also correctly enforced:

require(
    msg.sender == owner,
    "Not owner"
);

---------------------------------------------------------

Zero-address validation exists:

require(
    _user != address(0),
    "Invalid address"
);

---------------------------------------------------------

The contract follows proper
fail-fast validation behavior.

If any require() fails:

- execution stops immediately
- transaction reverts
- state changes rollback

Impact:

No critical security impact identified.

The contract correctly prevents:

- invalid deposits
- oversized deposits
- unauthorized balance reset
- invalid address usage
- excessive balance growth

Proof of Concept:

1.Deploy the contract.

---------------------------------------------------------

    STEP 1:
    Alice calls:
        deposit(10 ether)
    RESULT:
        balances[Alice] = 10 ether
    Transaction succeeds.

---------------------------------------------------------

    STEP 2:
    Alice calls:
        deposit(0)
    RESULT:
        Transaction reverts.
    ERROR:
        "Amount must be > 0"

---------------------------------------------------------

    STEP 3:
    Alice calls:
        deposit(500 ether)
    RESULT:
        Transaction reverts.
    ERROR:
        "Deposit too large"

---------------------------------------------------------

    STEP 4:
    Assume:
        balances[Alice] = 995 ether
    Alice calls:
        deposit(10 ether)
    CHECK:
        995 ether + 10 ether
        = 1005 ether
    RESULT:
        Transaction reverts.
    ERROR:
        "Balance limit exceeded"

---------------------------------------------------------

    STEP 5:
    Non-owner Bob calls:
        resetBalance(Alice)
    RESULT:
        Transaction reverts.
    ERROR:
        "Not owner"

---------------------------------------------------------

    STEP 6:
    Owner calls:
        resetBalance(address(0))
    RESULT:
        Transaction reverts.
    ERROR:
        "Invalid address"

---------------------------------------------------------

Observe:
    - layered validation works correctly
    - unauthorized access is blocked
    - fail-fast execution works properly
    - execution guards behave safely

Root Cause:

No critical vulnerability identified.

The vulnerable contract already implements:

- layered require() validation
- proper access control
- bounded deposit logic
- defensive execution guards

Recommendation:

No major security fix required.

Continue following:

- fail-fast validation
- layered require() checks
- proper access control
- bounded state updates

---------------------------------------------------------

Recommended Improvement:

Add pause and blacklist checks
inside deposit().

Example:

if (paused) {
    revert ContractPaused();
}

if (blacklisted[msg.sender]) {
    revert BlacklistedUser();
}
*/
/* 
// patched code contract MultipleRequireChecks {

    error InsufficientBalance();
    error InvalidAmount();
    error ContractPaused();
    error BlacklistedUser();
    error NotOwner();

    address public owner;

    bool public paused;

    mapping(address => uint256) public balances;

    mapping(address => bool) public blacklisted;

    constructor() {
        owner = msg.sender;
    }
    /*
    =====================================================
    DEPOSIT
    =====================================================
    
    function deposit(uint256 _amount)external{
        if(_amount == 0){
            revert InvalidAmount();
        }
        balances[msg.sender] += _amount;
    }
    /*
    =====================================================
    OWNER FUNCTIONS
    =====================================================
    
    function setPaused(bool _status)external{
        if (msg.sender != owner) {
            revert NotOwner();
        }
        paused = _status;
    }
    function blacklistUser( address _user)external{
        if (msg.sender != owner) {
            revert NotOwner();
        }
        blacklisted[_user] = true;
    }

    /*
    =====================================================
    WITHDRAW
    =====================================================
    

    function withdraw(uint256 _amount)external{
        /*
        =================================================
        REQUIRE #1
        Pause check
        =================================================
        

        if (paused) {
            revert ContractPaused();
        }

        /*
        =================================================
        REQUIRE #2
        Blacklist check
        =================================================
        

        if (blacklisted[msg.sender]) {
            revert BlacklistedUser();
        }

        /*
        =================================================
        REQUIRE #3
        Amount validation
        =================================================
        

        if (_amount == 0) {
            revert InvalidAmount();
        }

        /*
        =================================================
        REQUIRE #4
        Balance validation
        =================================================
        

        if (balances[msg.sender] < _amount) {
            revert InsufficientBalance();
        }

        /*
        =================================================
        EFFECTS
        =================================================
        
        balances[msg.sender] -= _amount;
    }
}
*/
/*

contract MultipleRequireChecksVul {

    address public owner;
    bool public paused;

    mapping(address => uint256) public balances;
    mapping(address => bool) public blacklisted;

    error NotOwner();
    error Paused();
    error Blacklisted();
    error InsufficientBalance();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner)
            revert NotOwner();
        _;
    }

    modifier checks() {
        if (paused)
            revert Paused();

        if (blacklisted[msg.sender])
            revert Blacklisted();
        _;
    }

    function deposit(uint256 _amount)
        external
        checks
    {
        require(_amount > 0, "Invalid amount");
        balances[msg.sender] += _amount;
    }

    function withdraw(uint256 _amount)
        external
        checks
    {
        if (balances[msg.sender] < _amount)
            revert InsufficientBalance();

        balances[msg.sender] -= _amount;

        payable(msg.sender).transfer(_amount);
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function blacklist(address _user)
        external
        onlyOwner
    {
        blacklisted[_user] = true;
    }

    receive() external payable {
        balances[msg.sender] += msg.value;
    }
}
```
*/