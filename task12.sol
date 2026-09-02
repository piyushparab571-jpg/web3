// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Compare storage before/after tx
CONCEPT: State persistence
=========================================================

OBJECTIVE

- Learn how blockchain state changes after transactions
- Understand persistence of storage variables
- Compare state BEFORE and AFTER execution
- Learn why transactions permanently modify storage

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Before transaction:
Storage contains OLD state

After transaction:
Storage contains UPDATED state

Blockchain permanently stores
latest contract state.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Transactions:
- modify blockchain state
- consume gas
- persist changes permanently

view functions:
- only read state
- do NOT modify storage

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

State persistence is critical in:

- token balances
- staking systems
- ownership tracking
- DeFi protocols
- NFT ownership
- governance systems

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Was state updated correctly?
- Did transaction modify intended storage?
- Can state become corrupted?
- Is old state unexpectedly overwritten?
- Are updates atomic and safe?

=========================================================
*/

contract StatePersistenceVul {

    uint256 public counter;

    function increment() public {
        counter = counter + 1;
    }

    function setCounter(uint256 _value) public {
        counter = _value;
    }

    function getCounter() public view returns (uint256) {
        return counter;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

INITIAL STATE

counter = 0

Stored permanently in blockchain storage.

---------------------------------------------------------

CALL:
increment()

BEFORE TX:
counter = 0

EVM ACTIONS:

1. Transaction reaches contract
2. Current storage value loaded
3. counter + 1 calculated
4. Storage slot updated
5. New value persisted

AFTER TX:
counter = 1

---------------------------------------------------------

CALL:
increment()

BEFORE TX:
counter = 1

AFTER TX:
counter = 2

---------------------------------------------------------

CALL:
setCounter(100)

BEFORE TX:
counter = 2

AFTER TX:
counter = 100

---------------------------------------------------------

IMPORTANT OBSERVATION

State persists BETWEEN transactions.

Every new transaction sees
latest stored value.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

EXPECTED:
counter() => 0

---------------------------------------------------------

STEP 2:
Call:
increment()

EXPECTED:
counter() => 1

---------------------------------------------------------

STEP 3:
Call:
increment()

EXPECTED:
counter() => 2

---------------------------------------------------------

STEP 4:
Call:
setCounter(999)

EXPECTED:
counter() => 999

---------------------------------------------------------

STEP 5:
Refresh Remix UI

EXPECTED:
counter still equals 999

OBSERVE:
Storage persists permanently.

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Set counter to 0

EXPECTED:
Storage resets to 0

---------------------------------------------------------

TEST:
Repeated transactions

increment()
increment()
increment()

EXPECTED:
Counter increases sequentially

---------------------------------------------------------

TEST:
Large uint256 values

EXPECTED:
Works correctly in Solidity ^0.8.x

=========================================================
IMPORTANT STORAGE UNDERSTANDING
=========================================================

STATE BEFORE TX

Storage contains previous blockchain state.

---------------------------------------------------------

STATE AFTER TX

Updated values become new permanent state.

---------------------------------------------------------

VERY IMPORTANT

Each transaction:
- reads current storage
- modifies storage
- commits updated state

---------------------------------------------------------

BLOCKCHAIN PERSISTENCE

Storage survives:
- new transactions
- page refreshes
- node restarts

=========================================================
EVM INTERNAL FLOW
=========================================================

increment()

1. Read counter from storage
2. Load into EVM stack
3. Perform addition
4. Write updated value back to storage
5. Persist state to blockchain

---------------------------------------------------------

counter variable lives in STORAGE.

Temporary computation happens in:
- stack
- memory

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. STATE CONSISTENCY
---------------------------------------------------------

Auditors verify:
- storage updated correctly
- no partial updates
- no unexpected overwrites

---------------------------------------------------------
2. RACE CONDITIONS
---------------------------------------------------------

Multiple users may update same state.

Auditors inspect:
- ordering issues
- stale reads
- transaction assumptions

---------------------------------------------------------
3. ACCESS CONTROL
---------------------------------------------------------

Current issue:
ANYONE can modify counter.

Danger if counter controls:
- protocol settings
- rewards
- treasury logic

---------------------------------------------------------
4. PERSISTENT STATE RISKS
---------------------------------------------------------

Bad state changes persist permanently.

Incorrect updates may:
- corrupt protocol
- lock funds
- break logic forever

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Suppose counter tracks:
- reward multiplier
- treasury percentage
- governance threshold

Attacker calls:

setCounter(999999)

Impact:
Protocol behavior manipulated.

---------------------------------------------------------

ANOTHER RISK

Unexpected state persistence may:
- preserve malicious values
- maintain broken configuration
- cause long-term protocol damage

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Store previousCounter
2. Before every update:
   save old value

BONUS:
Emit event showing:
old value -> new value

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Storage persists across transactions
- Transactions permanently modify state
- view functions only read storage
- State before tx differs from after tx
- EVM reads then writes storage
- Storage updates consume gas
- Blockchain maintains latest state
- Incorrect state updates are dangerous
- Access control protects persistent state
- Auditors inspect state transitions carefully

=========================================================
*/

/*
Audit Report

Title: Missing Access Control and Lack of State Tracking in Counter Updates

Severity: Medium

Reason: Unauthorized users can modify protocol state and previous state was not tracked before updates.

Location:

Contract: StatePersistenceVul
Function: increment(), setCounter()

Vulnerability Description:
The StatePersistenceVul contract allows any external user to modify the counter state variable using increment() and setCounter() functions. There is no access control mechanism implemented to restrict who can update the state.

Additionally, the contract does not store the previous value of counter before updating it. This results in loss of state transition history and makes auditing difficult.

Impact:
An attacker can modify the counter value without restriction, which may lead to:

Unauthorized state modification
Manipulation of protocol logic
Loss of historical state tracking
Incorrect system behavior if counter is used in critical logic

If the counter variable is used in:

reward calculations
governance thresholds
treasury logic

then attackers can manipulate system behavior.

Proof of Concept:
        1.Deploy the contract.
        2.User A calls:
            increment()
            Counter becomes 1
        3.Attacker calls:
            setCounter(999999)
            Counter is updated without any restriction
        4.Previous counter value is not stored before update.

Root Cause:

Functions increment() and setCounter() are declared public without any access control.
No require() statement is used to restrict unauthorized access.
Previous state tracking (previousCounter) was missing in the original implementation.

Recommendation:

Add access control using owner check:
require(msg.sender == owner, "Not Owner");
Store previous state before updating:
previousCounter = counter;

*/

// patched code 
/*
contract StatePersistence {

    uint256 public counter;
    address public owner;
    uint256 public previousCounter;

    constructor(){
        owner=msg.sender;
    }
    function increment() public {
        require(msg.sender==owner,"Not Owner");
        previousCounter = counter;  // stores previous counter
        counter=counter+1;
    }

    function setCounter(uint256 _value) public {
        require(msg.sender==owner,"Not Owner");
        previousCounter=counter; // saves old value
        counter = _value;
    }

    function getCounter() public view returns (uint256) {

        return counter;
    }
}
*/
contract StatePersistence {
    uint256 public counter;
    uint256 public previousCounter;
    //Event: old value -> new value
    event CounterUpdated(
        uint256 oldValue,
        uint256 newValue
    );
    function increment() public {
        //save old value first
        previousCounter = counter;
        //Update counter
        counter = counter +1;

        //Emit old -> new
        emit CounterUpdated(previousCounter, counter);
    }
    function setCounter(uint256 _value) public {
        //Save old value first
        previousCounter = counter;
        //Update counter
        counter = _value;
        //emit old -> new
        emit CounterUpdated(previousCounter, counter);
    }
    function getCounter()
    public 
    view 
    returns (uint256)
    {
        return counter;
    }
}