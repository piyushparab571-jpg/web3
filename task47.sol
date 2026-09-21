// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Emit events during execution
CONCEPT: Execution tracking
=========================================================

OBJECTIVE

- Learn how Solidity events work
- Understand execution tracking through logs
- Learn event emission flow
- Understand off-chain monitoring architecture

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Events create blockchain logs.

These logs help:
- frontend apps
- indexers
- explorers
- monitoring systems

track contract activity.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Events are NOT contract storage.

They are stored inside:
transaction logs.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Without events:
off-chain systems cannot efficiently
track contract activity.

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Events used in:

- ERC20 transfers
- NFT minting
- swaps
- staking
- governance voting
- liquidations

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- missing events
- incorrect event ordering
- misleading logs
- sensitive-data leakage
- inconsistent state vs event emission

=========================================================
*/
/*
contract EventExecutionTrackingVul {

    /*
        STORAGE VARIABLES
    
    mapping(address => uint256) public balances;

    uint256 public totalDeposits;

    /*
    =====================================================
    EVENT DEFINITIONS
    =====================================================

    Events create blockchain logs.
    
    event DepositStarted(
        address indexed user,
        uint256 amount
    );

    event BalanceUpdated(
        address indexed user,
        uint256 newBalance
    );

    event DepositCompleted(
        address indexed user,
        uint256 amount,
        uint256 totalDeposits
    );

    event ExecutionFailed(
        address indexed user,
        string reason
    );

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
            STEP 1:
            Emit execution-start event.
        
        emit DepositStarted(
            msg.sender,
            _amount
        );

        /*
            STEP 2:
            Validate input.
        
        require(
            _amount > 0,
            "Amount must be > 0"
        );

        require(
            _amount <= 100,
            "Amount too large"
        );

        /*
            STEP 3:
            Update storage.
        
        balances[msg.sender] += _amount;

        /*
            STEP 4:
            Emit balance-update event.
        
        emit BalanceUpdated(
            msg.sender,
            balances[msg.sender]
        );

        /*
            STEP 5:
            Update global storage.
        
        totalDeposits += _amount;

        /*
            STEP 6:
            Emit completion event.
        
        emit DepositCompleted(
            msg.sender,
            _amount,
            totalDeposits
        );
    }

    /*
    =====================================================
    MANUAL FAILURE TRACKING
    =====================================================
    

    function validateNumber(
        uint256 _number
    )
        external
    {

        /*
            Emit failure event before revert.
        
        if (_number > 10) {

            emit ExecutionFailed(
                msg.sender,
                "Number too large"
            );

            revert("Validation failed");
        }
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
deposit(50)

=========================================================

STEP 1:
emit DepositStarted()

---------------------------------------------------------

LOG CREATED:

user = Alice
amount = 50

---------------------------------------------------------

STEP 2:
Validation checks pass.

---------------------------------------------------------

STEP 3:
Storage updated.

balances[Alice] += 50

---------------------------------------------------------

STEP 4:
emit BalanceUpdated()

---------------------------------------------------------

LOG CREATED:

newBalance = 50

---------------------------------------------------------

STEP 5:
totalDeposits += 50

---------------------------------------------------------

STEP 6:
emit DepositCompleted()

---------------------------------------------------------

LOG CREATED:

amount = 50
totalDeposits = 50

---------------------------------------------------------

TRANSACTION SUCCEEDS

=========================================================
IMPORTANT EVENT UNDERSTANDING
=========================================================

Events are stored in:
transaction logs.

---------------------------------------------------------

NOT inside contract storage.

=========================================================
EVENTS VS STORAGE
=========================================================

---------------------------------------------------------
STORAGE
---------------------------------------------------------

- readable on-chain
- expensive
- persistent state

---------------------------------------------------------
EVENTS
---------------------------------------------------------

- cheaper
- optimized for off-chain reading
- not readable by contracts

=========================================================
IMPORTANT REVERT BEHAVIOR
=========================================================

If transaction reverts:

ALL emitted events disappear.

---------------------------------------------------------

Very important EVM property.

=========================================================
REVERT TRACE
=========================================================

CALL:
validateNumber(50)

=========================================================

STEP 1:
emit ExecutionFailed()

---------------------------------------------------------

Temporary log created.

---------------------------------------------------------

STEP 2:
revert()

---------------------------------------------------------

TRANSACTION REVERTS

---------------------------------------------------------

EVENT LOG ALSO REMOVED

---------------------------------------------------------

FINAL RESULT:

NO event persists on-chain.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Open:
Deployed Contracts panel

---------------------------------------------------------

STEP 3:
Call:
deposit(50)

---------------------------------------------------------

STEP 4:
Open transaction log section

---------------------------------------------------------

OBSERVE EVENTS:

- DepositStarted
- BalanceUpdated
- DepositCompleted

---------------------------------------------------------

STEP 5:
Call:
deposit(500)

EXPECTED:
Revert

---------------------------------------------------------

OBSERVE:
No events persist after revert.

---------------------------------------------------------

STEP 6:
Call:
validateNumber(50)

EXPECTED:
Revert

---------------------------------------------------------

OBSERVE:
ExecutionFailed event disappears too.

=========================================================
IMPORTANT INDEXED UNDERSTANDING
=========================================================

indexed parameters:

allow efficient filtering/searching.

---------------------------------------------------------

Example:

event Deposit(
    address indexed user,
    uint amount
)

---------------------------------------------------------

Frontend can efficiently search:
all events for specific user.

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. MISSING EVENTS
---------------------------------------------------------

Critical actions not trackable.

---------------------------------------------------------
2. MISLEADING EVENTS
---------------------------------------------------------

Event says success,
but state update failed.

---------------------------------------------------------
3. EVENT BEFORE EXTERNAL CALL
---------------------------------------------------------

May create misleading logs.

---------------------------------------------------------
4. SENSITIVE DATA LEAKAGE
---------------------------------------------------------

Events are publicly visible forever.

=========================================================
GAS OBSERVATION
=========================================================

Events:
cost less gas than storage.

---------------------------------------------------------

Indexed fields:
slightly more expensive.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- Are critical actions logged?
- Do events match state changes?
- Can events mislead monitoring systems?
- Is sensitive data exposed?
- Are events emitted in correct order?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Malformed event emitted before revert.

Off-chain bots incorrectly react.

---------------------------------------------------------

ANOTHER RISK

Missing liquidation event
prevents monitoring systems
from detecting dangerous activity.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. Event emission order
2. State updates
3. Revert behavior
4. Off-chain monitoring assumptions
5. Event consistency

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add Withdraw event
2. Add AdminAction event
3. Emit event AFTER modifier execution
4. Add indexed tokenId field

BONUS:
Build mini ERC20-style Transfer event.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Events create blockchain logs
- Events help off-chain tracking
- Events are not contract storage
- Events disappear if transaction reverts
- indexed enables efficient searching
- Event ordering matters heavily
- Incorrect events may mislead systems
- Events are cheaper than storage
- Auditors verify event consistency
- Execution tracking is critical in smart contracts

=========================================================
*/

/*
Audit Report

Title: Inconsistent Event Emission Strategy (Informational Issue)

Severity: Low (Informational)

Reason: Event emission occurs before validation, which may lead to misleading off-chain logs in reverted transactions.

Location:

Contract: EventExecutionTrackingVul
Function: deposit()
Function: validateNumber()

---------------------------------------------------------

Vulnerability Description:

The contract emits DepositStarted before validation checks are executed. If validation fails, the transaction reverts and the event is discarded. However, off-chain systems may temporarily observe an event that does not represent a successful state transition.

Similarly, ExecutionFailed is emitted before revert in validateNumber(), but does not persist due to transaction rollback.

---------------------------------------------------------

Impact:

- No on-chain security risk
- Off-chain indexers may briefly observe invalid execution traces
- Analytics systems may misinterpret execution intent
- No fund loss or state corruption risk

---------------------------------------------------------

Proof of Concept:

1. Call deposit(500)
2. DepositStarted event is emitted
3. require(_amount <= 100) fails
4. Transaction reverts
5. Event is discarded

---------------------------------------------------------

Root Cause:

Events are emitted before validation and final state commitment.

---------------------------------------------------------

Recommendation:

Emit events only after successful validation and state update:

require(_amount > 0 && _amount <= 100);
balances[msg.sender] += _amount;
emit DepositStarted(msg.sender, _amount);
*/
// patched code
/* 
contract EventExecutionTracking{
    mapping (address=>uint256)public balances;
    uint256 public totalDeposits;

    address public owner;

    constructor(){
        owner=msg.sender;
    }

    // events
    event DepositStarted(address indexed user,uint256 amount);
    event BalanceUpdated(address indexed user, uint256 newBalance);
    event DepositCompleted(address indexed user,uint256 amount,uint256 totalDeposits);

    event WithdrawEvent(address indexed user,uint256 amount,uint256 remainingBalance);
    event AdminAction(address indexed admin,string action,address indexed target);
    event Transfer(address indexed from,address indexed to,uint256 tokenId,uint256 amount);

    modifier onlyOwner(){
        require(msg.sender==owner,"Not owner");
        _;

        emit AdminAction(msg.sender, "OwnerActionExecuted", address(0));
    }

    function deposit(uint256 _amount)external {
        emit DepositStarted(msg.sender, _amount);

        require(_amount>0 && _amount<=100,"Invalid Amount");

        balances[msg.sender]+=_amount;
        totalDeposits+=_amount;
        emit DepositStarted(msg.sender, _amount);
        
        emit BalanceUpdated(msg.sender, balances[msg.sender]);

        emit DepositCompleted(msg.sender, _amount, totalDeposits);
    }

    function withdraw(uint256 _amount)external{
        require(balances[msg.sender]>=_amount,"Insufficient balance");
        balances[msg.sender]-=_amount;

        emit WithdrawEvent(msg.sender, _amount, balances[msg.sender]);
    }

    //admin action
    function blacklist(address user)external onlyOwner{
        emit AdminAction(msg.sender, "Blacklist_Use", user);
    }

    // ERC20 style transfer event 
    function transfer(address to,uint256 amount,uint256 tokenId)external {
        require(balances[msg.sender]>=amount,"No Balance");

        balances[msg.sender]-=amount;
        balances[to]+=amount;

        emit Transfer(msg.sender, to, tokenId, amount);
    }
}
*/
contract EventExecutionTrackingVul {

    mapping(address => uint256) public balances;
    uint256 public totalDeposits;

    /*
        EVENTS
    */

    event DepositStarted(
        address indexed user,
        uint256 amount
    );

    event BalanceUpdated(
        address indexed user,
        uint256 newBalance
    );

    event DepositCompleted(
        address indexed user,
        uint256 amount,
        uint256 totalDeposits,
        uint256 indexed tokenId
    );

    // Withdraw event
    event Withdraw(
        address indexed user,
        uint256 amount
    );

    // Admin action event
    event AdminAction(
        address indexed admin,
        string action
    );

    // Failure event
    event ExecutionFailed(
        address indexed user,
        string reason
    );

    // Bonus: ERC20-style Transfer event
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );


    /*
        MODIFIER
    */

    modifier afterExecution() {
        _;
        emit AdminAction(
            msg.sender,
            "Function executed"
        );
    }


    /*
        DEPOSIT
    */

    function deposit(
        uint256 _amount
    )
        external
        afterExecution
    {
        emit DepositStarted(msg.sender, _amount);

        require(_amount > 0, "Invalid amount");
        require(_amount <= 100, "Amount too large");

        balances[msg.sender] += _amount;
        totalDeposits += _amount;

        emit BalanceUpdated(
            msg.sender,
            balances[msg.sender]
        );

        emit DepositCompleted(
            msg.sender,
            _amount,
            totalDeposits,
            1
        );

        emit Transfer(
            address(0),
            msg.sender,
            _amount
        );
    }


    /*
        WITHDRAW
    */

    function withdraw(
        uint256 _amount
    )
        external
        afterExecution
    {
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );

        balances[msg.sender] -= _amount;
        totalDeposits -= _amount;

        emit Withdraw(
            msg.sender,
            _amount
        );

        emit Transfer(
            msg.sender,
            address(0),
            _amount
        );
    }


    /*
        FAILURE TRACKING
    */

    function validateNumber(
        uint256 _number
    )
        external
    {
        if (_number > 10) {

            emit ExecutionFailed(
                msg.sender,
                "Number too large"
            );

            revert("Validation failed");
        }
    }
}