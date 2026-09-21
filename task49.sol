// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Reorder logic intentionally
CONCEPT: Vulnerability creation
=========================================================

OBJECTIVE

- Learn how bad execution order creates vulnerabilities
- Understand dangerous state-update sequencing
- Learn reentrancy-style ordering issues
- Think like a smart contract auditor

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Execution order is SECURITY CRITICAL.

Changing line order may:
- break invariants
- expose reentrancy
- corrupt accounting
- enable fund theft

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Same logic
+
Different order
=
Completely different security outcome.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Many real-world hacks happened because:
logic executed in wrong order.

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Ordering mistakes affected:

- DAO hack
- lending protocols
- vault systems
- reward systems
- staking protocols
- AMMs

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- state-update order
- external-call timing
- validation placement
- stale-state reads
- invariant preservation

=========================================================
*/
/*
contract ReorderLogicVulnerabilityVul {

    /*
        USER BALANCES
    
    mapping(address => uint256) public balances;

    /*
        TOTAL SYSTEM BALANCE
    
    uint256 public totalBalance;

    /*
    =====================================================
    SAFE DEPOSIT
    =====================================================
    

    function safeDeposit()
        external
        payable
    {

        /*
            STEP 1:
            Validate FIRST.
        
        require(
            msg.value > 0,
            "No ETH sent"
        );

        /*
            STEP 2:
            Update user balance.
        
        balances[msg.sender] += msg.value;

        /*
            STEP 3:
            Update global accounting.
        
        totalBalance += msg.value;
    }

    /*
    =====================================================
    SAFE WITHDRAW
    =====================================================

    Uses:
    Checks -> Effects -> Interactions
    

    function safeWithdraw(
        uint256 _amount
    )
        external
    {

        /*
            CHECKS
        
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            EFFECTS

            Update storage BEFORE external call.
        
        balances[msg.sender] -= _amount;

        totalBalance -= _amount;

        /*
            INTERACTION

            External ETH transfer LAST.
        
        payable(msg.sender).transfer(_amount);
    }

    /*
    =====================================================
    VULNERABLE WITHDRAW
    =====================================================

    INTENTIONALLY BAD ORDER
    

    function vulnerableWithdraw(
        uint256 _amount
    )
        external
    {

        /*
            CHECK:
            User balance validation.
        
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            DANGEROUS ORDER:

            External call BEFORE state update.
        
        payable(msg.sender).call{ value: _amount}("");

        /*
            STATE UPDATED TOO LATE
        
        balances[msg.sender] -= _amount;

        totalBalance -= _amount;
    }

    /*
    =====================================================
    BAD REWARD ORDER
    =====================================================
    

    mapping(address => uint256) public rewards;

    function badRewardUpdate(
        uint256 _deposit
    )
        external
    {

        /*
            WRONG ORDER:

            Reward calculated BEFORE
            balance update.
        
        rewards[msg.sender] =
            balances[msg.sender] / 10;

        /*
            Balance updated later.
        
        balances[msg.sender] += _deposit;
    }

    /*
    =====================================================
    SAFE REWARD ORDER
    =====================================================
    

    function safeRewardUpdate(
        uint256 _deposit
    )
        external
    {

        /*
            Correct order:
            update balance first.
        
        balances[msg.sender] += _deposit;

        /*
            Reward uses NEW balance.
        
        rewards[msg.sender] =
            balances[msg.sender] / 10;
    }
}
*/
/*
=========================================================
IMPORTANT SECURITY UNDERSTANDING
=========================================================

BAD ORDER:
interaction before state update

=
classic reentrancy vulnerability.

=========================================================
SAFE WITHDRAW TRACE
=========================================================

CALL:
safeWithdraw(10)

=========================================================

STEP 1:
Balance check.

---------------------------------------------------------

STEP 2:
balances[Alice] -= 10

---------------------------------------------------------

STEP 3:
totalBalance -= 10

---------------------------------------------------------

STEP 4:
ETH transfer occurs LAST.

---------------------------------------------------------

SAFE:
state already updated.

=========================================================
VULNERABLE TRACE
=========================================================

CALL:
vulnerableWithdraw(10)

=========================================================

STEP 1:
Balance validated.

---------------------------------------------------------

STEP 2:
External ETH call occurs FIRST.

---------------------------------------------------------

DANGER:
Attacker contract can reenter NOW.

---------------------------------------------------------

STEP 3:
Balance reduced TOO LATE.

---------------------------------------------------------

ATTACK RESULT:
multiple withdrawals possible.

=========================================================
WHY REORDERING CREATES VULNERABILITIES
=========================================================

Security depends on:
WHEN state changes occur.

---------------------------------------------------------

Incorrect ordering may expose:
temporary inconsistent state.

=========================================================
REWARD BUG TRACE
=========================================================

INITIAL:

balances[Alice] = 100

---------------------------------------------------------

CALL:
badRewardUpdate(50)

---------------------------------------------------------

STEP 1:
Reward calculated.

100 / 10 = 10

---------------------------------------------------------

STEP 2:
Balance updated later.

balances[Alice] = 150

---------------------------------------------------------

FINAL:
Reward stale and incorrect.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
safeRewardUpdate(100)

---------------------------------------------------------

STEP 3:
Call:
rewards(your_address)

EXPECTED:
10

---------------------------------------------------------

STEP 4:
Deploy fresh contract

---------------------------------------------------------

STEP 5:
Call:
badRewardUpdate(100)

---------------------------------------------------------

STEP 6:
Call:
rewards(your_address)

EXPECTED:
0

---------------------------------------------------------

OBSERVE:
Wrong order caused stale calculation.

=========================================================
CRITICAL AUDITOR CONCEPT
=========================================================

Auditors care deeply about:

EXECUTION ORDER

---------------------------------------------------------

Because:
same code + different order
can create exploits.

=========================================================
CHECKS-EFFECTS-INTERACTIONS
=========================================================

SAFE PATTERN:

1. CHECKS
2. EFFECTS
3. INTERACTIONS

---------------------------------------------------------

Prevents:
many reentrancy attacks.

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. EXTERNAL CALL BEFORE STATE UPDATE
---------------------------------------------------------

Classic reentrancy risk.

---------------------------------------------------------
2. STALE STATE READS
---------------------------------------------------------

Logic reads outdated values.

---------------------------------------------------------
3. INVARIANT VIOLATIONS
---------------------------------------------------------

Temporary inconsistent state exposed.

---------------------------------------------------------
4. PARTIAL EXECUTION ASSUMPTIONS
---------------------------------------------------------

Incorrect ordering breaks accounting.

=========================================================
GAS OBSERVATION
=========================================================

Incorrect ordering may:
waste gas during revert paths.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- What executes first?
- When is state updated?
- Are external calls dangerous?
- Can temporary state be abused?
- Are invariants preserved throughout execution?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker deploys malicious contract.

---------------------------------------------------------

During vulnerableWithdraw():

1. receives ETH
2. fallback triggers
3. reenters withdraw()
4. balance still unchanged
5. steals funds repeatedly

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. Exact execution order
2. Storage update timing
3. External interaction timing
4. Revert points
5. Reentrancy windows

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add external token transfer
2. Intentionally place it before
   balance reduction
3. Analyze vulnerability
4. Fix using CEI pattern

BONUS:
Implement nonReentrant modifier.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Execution order is security critical
- Reordering logic can create vulnerabilities
- External calls before state updates are dangerous
- CEI pattern prevents many attacks
- Stale reads create incorrect accounting
- Temporary inconsistent state is exploitable
- Reentrancy depends heavily on ordering
- Auditors trace exact execution sequence
- Same logic with different order changes security
- Order dependency is fundamental to smart contract auditing

=========================================================
*/

/*
Audit Report

Title: Incorrect Execution Order Causes Reentrancy and Stale Reward Calculation

Severity: High

Reason: External interaction occurs before state update and reward calculation uses stale balance values.

Location:
    Contract: ReorderLogicVulnerabilityVul
    Function: vulnerableWithdraw(uint256 _amount)
            badRewardUpdate(uint256 _deposit)

Vulnerability Description:
The contract contains multiple execution-order vulnerabilities.

1. vulnerableWithdraw()

The function performs an external ETH transfer before updating balances.
The following line executes first:
payable(msg.sender).call{ value: _amount }("");

before:

balances[msg.sender] -= _amount;
totalBalance -= _amount;

This violates the Checks → Effects → Interactions (CEI) pattern and creates a reentrancy vulnerability.
An attacker contract can re-enter vulnerableWithdraw() before balances are reduced.

---------------------------------------------------------

2. badRewardUpdate()

The function calculates rewards before updating user balance.

The following executes first:

rewards[msg.sender] =
    balances[msg.sender] / 10;

before:

balances[msg.sender] += _deposit;
This causes stale-state reads and incorrect reward accounting.

Impact:
The vulnerabilities may cause:

- multiple unauthorized withdrawals
- complete ETH drain from contract
- broken accounting
- stale reward calculations
- incorrect reward distribution
- inconsistent protocol state

If integrated into a real DeFi protocol, attackers may steal protocol funds and manipulate reward systems.

Proof of Concept:

    1. Deploy the contract.

    2. Reentrancy Attack:

        User deposits ETH using:
        safeDeposit()

        Attacker deploys malicious contract with receive() or fallback() function.

        Attacker calls:
        vulnerableWithdraw(1 ether)

        The contract executes:
        payable(msg.sender).call{ value: _amount }("");

        Before balances are updated, attacker re-enters:
        vulnerableWithdraw(1 ether)

        The process repeats multiple times and drains contract ETH.

    3. Stale Reward Calculation:

        Assume:
            balances[Alice] = 100

        Alice calls:
            badRewardUpdate(50)

        The contract calculates:
            rewards[Alice] = 100 / 10 = 10

        After calculation:
            balances[Alice] += 50

        Final state becomes:
            balances[Alice] = 150
            rewards[Alice] = 10

        Correct reward should be:
            150 / 10 = 15

The reward calculation becomes stale and incorrect.

Root Cause:
The contract performs logic in incorrect order.

---------------------------------------------------------

In vulnerableWithdraw():
External interaction occurs before internal state updates.

---------------------------------------------------------

In badRewardUpdate():
Reward calculation occurs before balance update.
Both functions violate proper execution sequencing principles.

Recommendation:
Follow the Checks → Effects → Interactions (CEI) pattern.
Update all internal state BEFORE external interactions.
Calculate rewards only AFTER balances are updated.
Additionally, implement a nonReentrant modifier.

Example:

balances[msg.sender] -= _amount;
totalBalance -= _amount;

payable(msg.sender).transfer(_amount);
*/
//patched code 
/*
contract ReorderLogicVulnerability {

    /*
        USER BALANCES
    
    mapping(address => uint256) public balances;

    /*
        TOTAL SYSTEM BALANCE
    
    uint256 public totalBalance;

    bool private locked;

// This prevents:
// same function being called again
// re-entering via external call
    modifier nonReentrant() {
    require(!locked, "Reentrant call blocked");

    locked = true;
    _;
    locked = false;
}

    /*
    =====================================================
    SAFE DEPOSIT
    =====================================================
    

    function safeDeposit()
        external
        payable
    {

        /*
            STEP 1:
            Validate FIRST.
        
        require(
            msg.value > 0,
            "No ETH sent"
        );

        /*
            STEP 2:
            Update user balance.
        
        balances[msg.sender] += msg.value;

        /*
            STEP 3:
            Update global accounting.
        
        totalBalance += msg.value;
    }

    /*
    =====================================================
    SAFE WITHDRAW
    =====================================================

    Uses:
    Checks -> Effects -> Interactions
    

    function safeWithdraw(
        uint256 _amount
    )
        external
    {

        /*
            CHECKS
        
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            EFFECTS

            Update storage BEFORE external call.
        
        balances[msg.sender] -= _amount;

        totalBalance -= _amount;

        /*
            INTERACTION

            External ETH transfer LAST.
        
        payable(msg.sender).transfer(_amount);
    }

    /*
    =====================================================
    VULNERABLE WITHDRAW
    =====================================================

    INTENTIONALLY BAD ORDER
    

    function vulnerableWithdraw(
        uint256 _amount
    )
        external
    {

        /*
            CHECK:
            User balance validation.
    
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            DANGEROUS ORDER:

            External call BEFORE state update.
        
        payable(msg.sender).call{ value: _amount}("");

        /*
            STATE UPDATED TOO LATE
        
        balances[msg.sender] -= _amount;

        totalBalance -= _amount;
    }

    /*
    =====================================================
    BAD REWARD ORDER
    =====================================================
    

    mapping(address => uint256) public rewards;

    function badRewardUpdate(
        uint256 _deposit
    )
        external
    {

        /*
            WRONG ORDER:

            Reward calculated BEFORE
            balance update.
        
        rewards[msg.sender] =
            balances[msg.sender] / 10;

        /*
            Balance updated later.
    
        balances[msg.sender] += _deposit;
    }

    /*
    =====================================================
    SAFE REWARD ORDER
    =====================================================
    
    function safeRewardUpdate(
        uint256 _deposit
    )
        external
    {

        /
            Correct order:
            update balance first.
        
        balances[msg.sender] += _deposit;

        /*
            Reward uses NEW balance.
        
        rewards[msg.sender] =
            balances[msg.sender] / 10;
    }

    function tokenTransfer(address to,uint amount)internal {
        // simulate external interaction
         (bool success, ) = payable(to).call{value: amount}("");
        require(success, "Token transfer failed");
    }

    function vulnerableTokenWithdraw(uint256 _amount)external {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
         //  EXTERNAL CALL FIRST (BAD ORDER)
        tokenTransfer(msg.sender, _amount);

    //  STATE UPDATED LATE
        balances[msg.sender] -= _amount;
    }

    function safeTokenWithdraw(uint256 _amount)
    external
    nonReentrant
{
    require(balances[msg.sender] >= _amount, "Insufficient balance");

    balances[msg.sender] -= _amount;

    tokenTransfer(msg.sender, _amount);
}
}
*/

contract ReorderLogicVulnerabilityVul {

    mapping(address => uint256) public balances;
    uint256 public totalBalance;
    mapping(address => uint256) public rewards;

    /*
        EXTERNAL TOKEN CONTRACT
    */
    IERC20 public token;

    constructor(address _token) {
        token = IERC20(_token);
    }

    /*
    =====================================================
    DEPOSIT
    =====================================================
    */

    function deposit() external payable {
        require(msg.value > 0, "No ETH sent");

        balances[msg.sender] += msg.value;
        totalBalance += msg.value;
    }

    /*
    =====================================================
    VULNERABLE TOKEN WITHDRAW
    =====================================================

    External token transfer happens BEFORE
    balance reduction.
    */

    function vulnerableTokenWithdraw(
        uint256 _amount
    )
        external
    {
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        // External call before state update
        token.transfer(msg.sender, _amount);

        // Balance updated too late
        balances[msg.sender] -= _amount;
        totalBalance -= _amount;
    }

    /*
    =====================================================
    SAFE TOKEN WITHDRAW
    =====================================================

    CHECKS → EFFECTS → INTERACTIONS
    */

    function safeTokenWithdraw(
        uint256 _amount
    )
        external
    {
        // CHECK
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        // EFFECT
        balances[msg.sender] -= _amount;
        totalBalance -= _amount;

        // INTERACTION
        require(
            token.transfer(msg.sender, _amount),
            "Token transfer failed"
        );
    }

    /*
    =====================================================
    BAD REWARD ORDER
    =====================================================
    */

    function badRewardUpdate(
        uint256 _deposit
    )
        external
    {
        rewards[msg.sender] =
            balances[msg.sender] / 10;

        balances[msg.sender] += _deposit;
    }

    /*
    =====================================================
    SAFE REWARD ORDER
    =====================================================
    */

    function safeRewardUpdate(
        uint256 _deposit
    )
        external
    {
        balances[msg.sender] += _deposit;

        rewards[msg.sender] =
            balances[msg.sender] / 10;
    }
}


/*
    SIMPLE ERC20 INTERFACE
*/

interface IERC20 {

    function transfer(
        address to,
        uint256 amount
    )
        external
        returns (bool);
}