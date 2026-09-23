// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Trace execution in debugger
CONCEPT: Real audit tracing
=========================================================

OBJECTIVE

- Learn how auditors trace transactions
- Understand step-by-step EVM execution
- Learn storage-change analysis
- Practice debugger-based auditing

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Professional auditors manually trace:
EVERY important transaction.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Auditing is NOT:
just reading code.

Auditors:
- step through execution
- inspect storage changes
- inspect stack flow
- inspect revert paths

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Most vulnerabilities become visible only during:
real execution tracing.

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Debug tracing used in:

- smart contract audits
- exploit analysis
- reentrancy debugging
- DeFi protocol reviews
- invariant analysis
- forensic investigation

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- execution order
- storage mutations
- call stack
- revert points
- external interactions

=========================================================
*/
/*
contract DebugExecutionTracing {

    /*
        USER BALANCES
    
    mapping(address => uint256) public balances;

    /*
        GLOBAL TOTAL
    
    uint256 public totalDeposits;

    /*
        BONUS TRACKER
    
    mapping(address => uint256) public bonuses;

    /*
    =====================================================
    DEPOSIT FUNCTION
    =====================================================
    

    function deposit(
        uint256 _amount
    )
        external
    {

        /*
            LINE A:
            Validation
        
        require(
            _amount > 0,
            "Invalid amount"
        );

        /*
            LINE B:
            Balance update
        
        balances[msg.sender] += _amount;

        /*
            LINE C:
            Bonus calculation
        
        bonuses[msg.sender] =
            balances[msg.sender] / 10;

        /*
            LINE D:
            Global accounting
        
        totalDeposits += _amount;
    }

    /*
    =====================================================
    WITHDRAW FUNCTION
    =====================================================


    function withdraw(
        uint256 _amount
    )
        external
    {

        /*
            LINE E:
            Balance check
        
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        /*
            LINE F:
            Balance reduction
        
        balances[msg.sender] -= _amount;

        /*
            LINE G:
            Global accounting update
        
        totalDeposits -= _amount;
    }

    /*
    =====================================================
    VULNERABLE FUNCTION
    =====================================================
    

    function vulnerableReward(
        uint256 _amount
    )
        external
    {

        /*
            LINE H:
            Reward uses OLD balance
        
        bonuses[msg.sender] =
            balances[msg.sender] / 10;

        /*
            LINE I:
            Balance updated later
        
        balances[msg.sender] += _amount;
    }
}
*/
/*
=========================================================
HOW REAL AUDITORS TRACE EXECUTION
=========================================================

Auditors manually inspect:

1. current line
2. storage before
3. storage after
4. branch decisions
5. revert paths

=========================================================
REMIX DEBUGGER SETUP
=========================================================

STEP 1:
Open Remix IDE

---------------------------------------------------------

STEP 2:
Compile contract

---------------------------------------------------------

STEP 3:
Deploy contract

---------------------------------------------------------

STEP 4:
Call:

deposit(100)

---------------------------------------------------------

STEP 5:
Open:
"Transactions" panel

---------------------------------------------------------

STEP 6:
Click:
Debug button

=========================================================
WHAT YOU WILL SEE
=========================================================

Debugger shows:

- current opcode
- current line
- stack values
- memory values
- storage values

=========================================================
TRACE:
deposit(100)
=========================================================

INITIAL STATE

balances[Alice] = 0

bonuses[Alice] = 0

totalDeposits = 0

=========================================================
DEBUG STEP-BY-STEP
=========================================================

---------------------------------------------------------
STEP 1
---------------------------------------------------------

Current line:
LINE A

require(_amount > 0)

---------------------------------------------------------

CHECK:
100 > 0

RESULT:
true

---------------------------------------------------------

No storage changes yet.

=========================================================
STEP 2
=========================================================

Current line:
LINE B

balances[msg.sender] += _amount

---------------------------------------------------------

STORAGE BEFORE:

balances[Alice] = 0

---------------------------------------------------------

STORAGE AFTER:

balances[Alice] = 100

=========================================================
STEP 3
=========================================================

Current line:
LINE C

bonuses[msg.sender] =
balances[msg.sender] / 10

---------------------------------------------------------

READ:
balances[Alice] = 100

---------------------------------------------------------

WRITE:
bonuses[Alice] = 10

=========================================================
STEP 4
=========================================================

Current line:
LINE D

totalDeposits += _amount

---------------------------------------------------------

STORAGE BEFORE:

totalDeposits = 0

---------------------------------------------------------

STORAGE AFTER:

totalDeposits = 100

=========================================================
FINAL STATE
=========================================================

balances[Alice] = 100

bonuses[Alice] = 10

totalDeposits = 100

=========================================================
VULNERABILITY TRACE
=========================================================

CALL:
vulnerableReward(50)

=========================================================

INITIAL STATE

balances[Alice] = 100

=========================================================
STEP 1
=========================================================

LINE H:

bonuses[Alice] =
balances[Alice] / 10

---------------------------------------------------------

READ:
100 / 10 = 10

---------------------------------------------------------

WRITE:
bonuses[Alice] = 10

=========================================================
STEP 2
=========================================================

LINE I:

balances[Alice] += 50

---------------------------------------------------------

NEW VALUE:

balances[Alice] = 150

=========================================================
FINAL STATE
=========================================================

balances[Alice] = 150

bonuses[Alice] = 10

---------------------------------------------------------

BUG FOUND:
reward used stale balance.

=========================================================
WHAT AUDITORS LOOK FOR
=========================================================

---------------------------------------------------------
1. EXECUTION ORDER
---------------------------------------------------------

Which line executes first?

---------------------------------------------------------
2. STORAGE MUTATIONS
---------------------------------------------------------

Which variables changed?

---------------------------------------------------------
3. STALE READS
---------------------------------------------------------

Was old state used incorrectly?

---------------------------------------------------------
4. REVERT POINTS
---------------------------------------------------------

Where can execution stop?

---------------------------------------------------------
5. EXTERNAL INTERACTIONS
---------------------------------------------------------

Any dangerous external call timing?

=========================================================
IMPORTANT DEBUGGER PANELS
=========================================================

---------------------------------------------------------
STACK
---------------------------------------------------------

Temporary EVM execution values.

---------------------------------------------------------
MEMORY
---------------------------------------------------------

Temporary runtime memory.

---------------------------------------------------------
STORAGE
---------------------------------------------------------

Persistent blockchain state.

---------------------------------------------------------
CALLDATA
---------------------------------------------------------

Transaction input data.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Professional auditors:

1. simulate attack paths
2. step through transactions
3. inspect state transitions
4. verify invariants
5. trace edge cases

=========================================================
VERY IMPORTANT AUDIT SKILL
=========================================================

Reading code is NOT enough.

---------------------------------------------------------

Real auditing requires:
mental + debugger execution tracing.

=========================================================
COMMON AUDIT RISKS FOUND VIA DEBUGGING
=========================================================

- stale storage reads
- incorrect ordering
- hidden state mutation
- reentrancy windows
- incorrect branching
- failed invariant maintenance

=========================================================
ATTACK THINKING
=========================================================

Attackers exploit:

- temporary inconsistent state
- stale calculations
- incorrect sequencing
- hidden execution branches

---------------------------------------------------------

Debug tracing reveals:
where exploit windows exist.

=========================================================
REMIX DEBUGGING TIPS
=========================================================

---------------------------------------------------------
TIP 1
---------------------------------------------------------

Watch storage tab carefully.

---------------------------------------------------------
TIP 2
---------------------------------------------------------

Trace line-by-line slowly.

---------------------------------------------------------
TIP 3
---------------------------------------------------------

Compare:
before vs after state.

---------------------------------------------------------
TIP 4
---------------------------------------------------------

Focus heavily on:
external calls + state updates.

=========================================================
MINI CHALLENGE
=========================================================

Using Remix debugger:

1. Deploy contract
2. Call deposit()
3. Step through every line
4. Record storage changes
5. Trace vulnerableReward()
6. Identify stale-state bug manually

BONUS:
Add external call and analyze:
reentrancy risk.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Auditors trace execution step-by-step
- Debuggers reveal real execution flow
- Storage mutations must be tracked carefully
- Execution order matters heavily
- Stale reads create vulnerabilities
- EVM stack/memory/storage differ
- Real auditing requires transaction tracing
- Vulnerabilities often appear during execution
- Debugging is critical for smart contract security
- Manual tracing is a core auditor skill

=========================================================
*/

contract DebugExecutionTracing {

    mapping(address => uint256) public balances;
    uint256 public totalDeposits;
    mapping(address => uint256) public bonuses;

    /*
        DEPOSIT
    */
    function deposit(uint256 _amount) external {

        require(_amount > 0, "Invalid amount");

        balances[msg.sender] += _amount;

        bonuses[msg.sender] =
            balances[msg.sender] / 10;

        totalDeposits += _amount;
    }


    /*
        WITHDRAW
    */
    function withdraw(uint256 _amount) external {

        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        balances[msg.sender] -= _amount;

        totalDeposits -= _amount;
    }


    /*
        VULNERABLE REWARD

        Intentionally uses OLD balance.
    */
    function vulnerableReward(
        uint256 _amount
    )
        external
    {
        // ❌ Uses old balance
        bonuses[msg.sender] =
            balances[msg.sender] / 10;

        // External call
        (bool success, ) =
            payable(msg.sender).call{value: 0}("");

        require(success, "Call failed");

        // Balance updated AFTER external call
        balances[msg.sender] += _amount;
    }


    /*
        SAFE VERSION

        Uses CEI pattern.
    */
    function safeReward(
        uint256 _amount
    )
        external
    {
        // EFFECT first
        balances[msg.sender] += _amount;

        bonuses[msg.sender] =
            balances[msg.sender] / 10;

        // INTERACTION last
        (bool success, ) =
            payable(msg.sender).call{value: 0}("");

        require(success, "Call failed");
    }


    /*
        RECEIVE ETH
    */
    receive() external payable {}
}