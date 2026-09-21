// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Call multiple state updates
CONCEPT: Order dependency
=========================================================

OBJECTIVE

- Learn how multiple storage updates execute
- Understand order dependency in Solidity
- Learn why update sequence matters
- Understand state consistency risks

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

State updates execute:
line-by-line in exact order.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Changing execution order can:
completely change final state.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Incorrect update ordering causes:

- accounting bugs
- balance corruption
- reentrancy vulnerabilities
- invariant violations

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Order dependency matters in:

- ERC20 transfers
- DeFi lending
- staking systems
- liquidation engines
- AMMs
- vault accounting

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- update sequencing
- external-call ordering
- invariant preservation
- partial state assumptions
- race-condition risks

=========================================================
*/
/*
contract OrderDependencyExampleVul {

    /*
        USER BALANCES
    
    mapping(address => uint256) public balances;

    /*
        GLOBAL TOTAL
    
    uint256 public totalSupply;

    /*
        REWARD TRACKER
    
    mapping(address => uint256) public rewards;

    /*
    =====================================================
    CORRECT ORDER EXAMPLE
    =====================================================
    
    function depositCorrect(
        uint256 _amount
    )
        external
    {

        /*
            STEP 1:
            Validate input FIRST.
        
        require(
            _amount > 0,
            "Invalid amount"
        );

        /*
            STEP 2:
            Update user balance.
        
        balances[msg.sender] += _amount;

        /*
            STEP 3:
            Update total supply.

            Depends on balance update.
        
        totalSupply += _amount;

        /*
            STEP 4:
            Reward based on NEW balance.
        
        rewards[msg.sender] =
            balances[msg.sender] / 10;
    }

    /*
    =====================================================
    BAD ORDER EXAMPLE
    =====================================================
    

    function depositWrong(
        uint256 _amount
    )
        external
    {

        /*
            STEP 1:
            Reward calculated BEFORE
            balance update.
        
        rewards[msg.sender] =
            balances[msg.sender] / 10;

        /*
            STEP 2:
            Balance updated later.
        
        balances[msg.sender] += _amount;

        /*
            STEP 3:
            Total updated.
        
        totalSupply += _amount;
    }

    /*
    =====================================================
    TRANSFER EXAMPLE
    =====================================================
    

    function transfer(
        address _to,
        uint256 _amount
    )
        external
    {

        /*
            Validate sender balance FIRST.
        
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            CORRECT ORDER:
            subtract sender first.
        
        balances[msg.sender] -= _amount;

        /*
            Then add receiver.
        
        balances[_to] += _amount;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

INITIAL STATE

balances[Alice] = 100

rewards[Alice] = 0

=========================================================
TRACE:
depositCorrect(50)
=========================================================

---------------------------------------------------------
STEP 1
---------------------------------------------------------

require(50 > 0)

RESULT:
true

---------------------------------------------------------
STEP 2
---------------------------------------------------------

balances[Alice] += 50

NEW VALUE:
150

---------------------------------------------------------
STEP 3
---------------------------------------------------------

totalSupply += 50

---------------------------------------------------------
STEP 4
---------------------------------------------------------

rewards[Alice] =
balances[Alice] / 10

150 / 10 = 15

---------------------------------------------------------
FINAL STATE
---------------------------------------------------------

balances[Alice] = 150

rewards[Alice] = 15

=========================================================
BAD ORDER TRACE
=========================================================

INITIAL:

balances[Alice] = 100

---------------------------------------------------------

CALL:
depositWrong(50)

---------------------------------------------------------
STEP 1
---------------------------------------------------------

rewards[Alice] =
balances[Alice] / 10

100 / 10 = 10

---------------------------------------------------------
STEP 2
---------------------------------------------------------

balances[Alice] += 50

NEW VALUE:
150

---------------------------------------------------------
FINAL STATE
---------------------------------------------------------

balances[Alice] = 150

rewards[Alice] = 10

---------------------------------------------------------

IMPORTANT:
Reward incorrect because
order was wrong.

=========================================================
IMPORTANT EXECUTION UNDERSTANDING
=========================================================

Solidity executes:
TOP -> DOWN

---------------------------------------------------------

Every storage update affects:
future lines immediately.

=========================================================
ORDER DEPENDENCY
=========================================================

Later logic depends on:
earlier state changes.

---------------------------------------------------------

Changing line order may:
change protocol behavior.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
depositCorrect(100)

---------------------------------------------------------

STEP 3:
Call:
balances(your_address)

EXPECTED:
100

---------------------------------------------------------

STEP 4:
Call:
rewards(your_address)

EXPECTED:
10

---------------------------------------------------------

STEP 5:
Deploy fresh contract

---------------------------------------------------------

STEP 6:
Call:
depositWrong(100)

---------------------------------------------------------

STEP 7:
Call:
rewards(your_address)

EXPECTED:
0

---------------------------------------------------------

OBSERVE:
Reward used OLD balance.

=========================================================
VERY IMPORTANT SECURITY CONCEPT
=========================================================

Incorrect update order can create:

- stale reads
- broken accounting
- exploit opportunities

=========================================================
CHECKS-EFFECTS-INTERACTIONS
=========================================================

BEST PRACTICE:

1. CHECKS
2. EFFECTS
3. INTERACTIONS

---------------------------------------------------------

Known as:
CEI pattern.

=========================================================
WHY CEI MATTERS
=========================================================

Correct ordering helps prevent:
reentrancy vulnerabilities.

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. STALE STATE READS
---------------------------------------------------------

Logic reads old values accidentally.

---------------------------------------------------------
2. EXTERNAL CALL BEFORE UPDATE
---------------------------------------------------------

Major reentrancy risk.

---------------------------------------------------------
3. INVARIANT BREAKAGE
---------------------------------------------------------

Incorrect order corrupts accounting.

---------------------------------------------------------
4. DOUBLE-SPEND RISKS
---------------------------------------------------------

Incorrect balance sequencing dangerous.

=========================================================
GAS OBSERVATION
=========================================================

More state updates:
higher gas usage.

---------------------------------------------------------

Repeated storage reads/writes:
especially expensive.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- What updates happen first?
- Which values depend on prior state?
- Are stale reads possible?
- Are invariants preserved?
- Does execution order prevent exploits?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

External call before balance reduction.

Attacker reenters repeatedly.

Result:
fund theft.

---------------------------------------------------------

ANOTHER RISK

Reward calculated before update.

Attacker gains incorrect rewards.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. Exact execution order
2. Storage reads/writes
3. Dependency chains
4. External-call timing
5. Invariant preservation

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add withdraw function
2. Intentionally place external call
   before balance update
3. Observe vulnerability risk
4. Fix using CEI pattern

BONUS:
Track previousBalance and newBalance.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Solidity executes line-by-line
- State updates affect later execution immediately
- Execution order changes final behavior
- Incorrect ordering creates vulnerabilities
- CEI pattern improves security
- Stale reads are dangerous
- External-call ordering is critical
- Auditors trace exact state-update sequence
- Dependency chains matter heavily
- Order dependency is fundamental in smart contracts

=========================================================
*/

/*
Audit Report

Title: Order Dependency in depositWrong() Leading to Incorrect Reward Calculation

Severity: Medium

Reason: Reward calculation depends on stale balance due to incorrect execution order.

Location:

Contract: OrderDependencyExampleVul
Function: depositWrong()

---------------------------------------------------------

Vulnerability Description:

The depositWrong() function calculates rewards BEFORE updating the user balance.

This results in the reward being computed using outdated (stale) state instead of the updated balance.

---------------------------------------------------------

Impact:

- Users receive incorrect reward values
- Reward system becomes inconsistent with actual balances
- Breaks internal accounting logic
- Can lead to unfair reward distribution in incentive-based systems

If used in systems like:

- staking rewards
- yield farming
- bonus distribution

this bug can lead to financial inconsistency and reward misallocation.

---------------------------------------------------------

Proof of Concept:
        Initial State:
        balances[Alice] = 100

        Call:
        depositWrong(50)

        Step 1:
        rewards[Alice] = 100 / 10 = 10   (stale(outdated ) balance used)

        Step 2:
        balances[Alice] += 50 → 150

        Final State:
        balances[Alice] = 150
        rewards[Alice] = 10  (incorrect reward)

---------------------------------------------------------

Root Cause:

- Reward is computed BEFORE balance update
- Function uses stale state value for calculation
- No dependency-aware ordering of state updates

---------------------------------------------------------

Recommendation:

Update balance BEFORE calculating rewards:

balances[msg.sender] += _amount;
rewards[msg.sender] = balances[msg.sender] / 10;
*/

// patched code 
/*
contract OrderDependencyExample {

    /*
        USER BALANCES
    
    mapping(address => uint256) public balances;

    /*
        GLOBAL TOTAL
    
    uint256 public totalSupply;

    uint256 public previousBalance;
    uint256 public newBalance;

    /*
        REWARD TRACKER
    
    mapping(address => uint256) public rewards;

    /*
    =====================================================
    CORRECT ORDER EXAMPLE
    =====================================================
    

    function depositCorrect(
        uint256 _amount
    )
        external
    {

        /*
            STEP 1:
            Validate input FIRST.
        
        require(
            _amount > 0,
            "Invalid amount"
        );

        /*
            STEP 2:
            Update user balance.
        
        balances[msg.sender] += _amount;

        /*
            STEP 3:
            Update total supply.

            Depends on balance update.
        
        totalSupply += _amount;

        /*
            STEP 4:
            Reward based on NEW balance.
        
        rewards[msg.sender] =
            balances[msg.sender] / 10;
    }

    /*
    =====================================================
    BAD ORDER EXAMPLE
    =====================================================
    

    function depositWrong(
        uint256 _amount
    )
        external
    {

        /*
            STEP 1:
            Reward calculated BEFORE
            balance update.
        
        rewards[msg.sender] =
            balances[msg.sender] / 10;

        /*
            STEP 2:
            Balance updated later.
    
        balances[msg.sender] += _amount;

        /*
            STEP 3:
            Total updated.
        
        totalSupply += _amount;
    }

    /*
    =====================================================
    TRANSFER EXAMPLE
    =====================================================
    

    function transfer(
        address _to,
        uint256 _amount
    )
        external
    {

        /*
            Validate sender balance FIRST.
        
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            CORRECT ORDER:
            subtract sender first.
        
        balances[msg.sender] -= _amount;

        /*
            Then add receiver.
        
        balances[_to] += _amount;
    }

    function withdrawWrong(uint256 amount)external {
        require(amount<=balances[msg.sender],"Insufficient balance");
//  EXTERNAL CALL FIRST 
        (bool success,)=msg.sender.call{value:amount}("");
        require(success, "Transfer failed");
  //STATE UPDATE AFTER (BUG)
        balances[msg.sender]-=amount;
    }

    function withdrawCorrect(uint256 amount)external {
    // 1. CHECKS
        require(amount<=balances[msg.sender],"Insufficient balance");
    // store for bonus tracking
        previousBalance=balances[msg.sender];

    // 2. EFFECTS (STATE UPDATE FIRST)
        balances[msg.sender]-=amount;

        newBalance=balances[msg.sender];
    // 3. INTERACTION (EXTERNAL CALL LAST)
        (bool success,)=msg.sender.call{value:amount}("");
        require(success,"Transfer failed");

    }
}
*/
contract OrderDependencyExampleVul {

    mapping(address => uint256) public balances;
    uint256 public totalSupply;
    mapping(address => uint256) public rewards;

    // Bonus: track balances
    event BalanceChanged(
        address indexed user,
        uint256 previousBalance,
        uint256 newBalance
    );

    /*
        DEPOSIT
    */
    function deposit(uint256 _amount)
        external
        payable
    {
        require(_amount > 0, "Invalid amount");
        require(msg.value == _amount, "Wrong ETH amount");

        uint256 previous = balances[msg.sender];

        balances[msg.sender] += _amount;
        totalSupply += _amount;

        rewards[msg.sender] = balances[msg.sender] / 10;

        emit BalanceChanged(
            msg.sender,
            previous,
            balances[msg.sender]
        );
    }


    /*
    =====================================================
    VULNERABLE WITHDRAW
    =====================================================

    External call happens BEFORE balance update.
    This creates a reentrancy risk.
    */

    function withdrawWrong(
        uint256 _amount
    )
        external
    {
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        uint256 previous = balances[msg.sender];

        // External call BEFORE state update
        (bool success, ) = payable(msg.sender).call{
            value: _amount
        }("");

        require(success, "Transfer failed");

        // State updated after external call
        balances[msg.sender] -= _amount;
        totalSupply -= _amount;

        emit BalanceChanged(
            msg.sender,
            previous,
            balances[msg.sender]
        );
    }


    /*
    =====================================================
    FIXED WITHDRAW - CEI
    =====================================================

    Checks → Effects → Interactions
    */

    function withdraw(
        uint256 _amount
    )
        external
    {
        // CHECK
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        uint256 previous = balances[msg.sender];

        // EFFECT
        balances[msg.sender] -= _amount;
        totalSupply -= _amount;

        // INTERACTION
        (bool success, ) = payable(msg.sender).call{
            value: _amount
        }("");

        require(success, "Transfer failed");

        emit BalanceChanged(
            msg.sender,
            previous,
            balances[msg.sender]
        );
    }


    /*
        RECEIVE ETH
    */
    receive() external payable {}
}