// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Modify storage through function
CONCEPT: State mutation
=========================================================

OBJECTIVE

- Learn how functions modify blockchain storage
- Understand state mutation in Solidity
- Learn difference between read and write operations
- Understand why state-changing functions cost gas

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

State mutation means:
changing contract storage.

Example:
- updating balances
- changing owner
- modifying configuration
- updating counters

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Functions that modify state:
- require transactions
- consume gas
- permanently change blockchain state

---------------------------------------------------------
VIEW VS STATE-CHANGING
---------------------------------------------------------

view function:
- reads storage only
- no state modification

non-view function:
- modifies storage
- changes blockchain state

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

State mutation is used in:

- token transfers
- staking systems
- ownership updates
- governance voting
- DeFi protocols
- NFT minting

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Who can mutate state?
- Is state updated safely?
- Can mutation corrupt protocol?
- Are validations missing?
- Is mutation atomic?

=========================================================
*/
/*
contract StateMutationVul {

    uint256 public value;

    function updateValue(uint256 _newValue) public {

        value = _newValue;
    }

    function increaseValue(uint256 _amount) public {

        value = value + _amount;
    }

    function getValue() public view returns (uint256) {

        return value;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

INITIAL STATE

value = 0

---------------------------------------------------------

CALL:
updateValue(100)

EVM ACTIONS:

1. Transaction reaches contract
2. _newValue arrives through calldata
3. Storage slot loaded
4. Storage updated
5. New state persisted

FINAL STATE:

value = 100

---------------------------------------------------------

CALL:
increaseValue(50)

BEFORE TX:
value = 100

EVM ACTIONS:

1. Current storage value read
2. Addition performed
3. Result written back to storage

AFTER TX:
value = 150

---------------------------------------------------------

CALL:
getValue()

RESULT:
Reads latest stored value.

No state mutation occurs.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

EXPECTED:
value() => 0

---------------------------------------------------------

STEP 2:
Call:
updateValue(100)

EXPECTED:
value() => 100

---------------------------------------------------------

STEP 3:
Call:
increaseValue(50)

EXPECTED:
value() => 150

---------------------------------------------------------

STEP 4:
Call:
increaseValue(1)

EXPECTED:
value() => 151

---------------------------------------------------------

STEP 5:
Refresh Remix

EXPECTED:
State persists permanently

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Set value to 0

EXPECTED:
State resets to zero

---------------------------------------------------------

TEST:
Increase by 0

EXPECTED:
No effective change

---------------------------------------------------------

TEST:
Use large uint256 values

EXPECTED:
Solidity ^0.8.x protects from overflow

---------------------------------------------------------

TEST:
Repeated mutations

EXPECTED:
Each transaction updates latest state

=========================================================
IMPORTANT STORAGE UNDERSTANDING
=========================================================

STATE MUTATION PROCESS

1. Read storage
2. Perform computation
3. Write updated value
4. Persist new state

---------------------------------------------------------

VERY IMPORTANT

Storage writes are expensive.

Reason:
Blockchain state changes permanently.

---------------------------------------------------------

TEMPORARY VS PERMANENT

Temporary computation:
- stack
- memory

Permanent data:
- storage

=========================================================
GAS OBSERVATION
=========================================================

READING STORAGE:
Cheaper

WRITING STORAGE:
Expensive

---------------------------------------------------------

Reason:
Storage updates modify blockchain state.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. ACCESS CONTROL
---------------------------------------------------------

Current issue:
ANYONE can mutate state.

Danger if variable controls:
- treasury
- fees
- rewards
- ownership

---------------------------------------------------------
2. INVALID STATE TRANSITIONS
---------------------------------------------------------

Auditors verify:
- state remains valid
- mutations follow protocol rules
- impossible states prevented

---------------------------------------------------------
3. OVERFLOW / UNDERFLOW
---------------------------------------------------------

Older Solidity versions vulnerable.

Solidity ^0.8.x automatically checks:
- overflow
- underflow

---------------------------------------------------------
4. PARTIAL STATE UPDATES
---------------------------------------------------------

Complex protocols may:
- update multiple variables
- fail midway
- create inconsistent state

Auditors inspect atomicity carefully.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Suppose value controls protocol fee.

Attacker calls:

updateValue(0)

Result:
Protocol fees removed.

---------------------------------------------------------

ANOTHER ATTACK

Attacker repeatedly mutates storage
to manipulate:
- rewards
- voting
- balances
- protocol behavior

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Only owner can mutate state
2. Emit event after every mutation

BONUS:
Store previous value before update.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- State mutation changes blockchain storage
- Storage writes require transactions
- State-changing functions consume gas
- view functions only read state
- Storage persists permanently
- Mutations overwrite previous values
- Access control protects state
- Storage writes are expensive
- Solidity ^0.8.x prevents overflow
- Auditors inspect state transitions carefully

=========================================================
*/

/*
Audit Report

Title: Missing Access Control and Incorrect Event Emission in State Mutation Functions

Severity: Medium

Reason: Unauthorized users could mutate contract state and event parameters are incorrectly ordered causing misleading logs.

Location:

Contract: StateMutationVul
Functions: updateValue(), increaseValue()

Vulnerability Description:
The StateMutationVul contract allows any external user to modify the state variable value using updateValue() and increaseValue() functions. There is no access control mechanism restricting who can perform state mutations.

Additionally, the contract incorrectly emits event parameters in the wrong order, which may lead to inaccurate off-chain tracking of state changes.

Impact:
An attacker can freely modify the value state variable, which may lead to:
Unauthorized state manipulation
Corruption of protocol logic if value is used in business rules
Incorrect reward or fee calculations
Misleading event logs due to incorrect parameter ordering

If the value variable is used in:

fee logic
reward distribution
governance calculations

then attackers can manipulate system behavior.

Proof of Concept:
        1.Deploy the contract.
        2.User A calls:
            updateValue(100)
            value becomes 100
        3.Attacker calls:
            increaseValue(50)
            value becomes 150 without restriction
        4.Event logs may show incorrect value order due to wrong parameter placement.

Root Cause:
    Both updateValue() and increaseValue() are declared public without access control.
    No require() statement validates msg.sender permissions.
    Event parameters are emitted in incorrect order:
        emit valueUpdated(value, prevValue);

Recommendation:

Add access control using owner check:
    require(msg.sender == owner, "Not owner");

Ensure correct event parameter ordering:
    emit valueUpdated(prevValue, value);

Store previous state before updating:
    prevValue = value;
*/
//patched code 
/*
contract StateMutation {

    uint256 public value;
    uint256 public prevValue;
    address public owner;

    constructor(){
        owner=msg.sender;
    }

    event valueUpdated(uint256 prevValue, uint256 value);

    function updateValue(uint256 _newValue) public {
        require(msg.sender==owner,"Not owner");
        prevValue = value;
        value = _newValue;
    
        emit valueUpdated(value, prevValue);
    }

    function increaseValue(uint256 _amount) public {
        require(msg.sender==owner,"Not owner");
        prevValue=value;
        value = value + _amount;

        emit valueUpdated(prevValue, value);
    }

    function getValue() public view returns (uint256) {

        return value;
    }
}
*/
contract StateMutation {
    uint256 public value;
    uint256 public previousValue;
    address public owner;
    //Event showing old value -> new valuw
    event ValueUpdated(
        uint256 oldValue,
        uint256 newValue
    );
    //set deployer as owner
    constructor() {
        owner = msg.sender;
    }
    //only owner can call this function
    function updateValue(uint256 _newValue) public {
        require(msg.sender == owner, "Only owner can update");
        //save old value
        previousValue = value;
        //update value
        value = _newValue;
        //emit event
        emit ValueUpdated(previousValue, value);
    }
    // only owner can call this function
    function increaseValue(uint256 _amount) public {
        require(msg.sender == owner, "Only owner can increase");
        //save old value
        previousValue = value;
        //update value
        value = value + _amount;
        //emit event
        emit ValueUpdated(previousValue, value);
    }
    function getValue() public view returns (uint256) {
        return value;
    }
}