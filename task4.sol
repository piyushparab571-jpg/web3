// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Store bool in state
CONCEPT: Boolean storage
=========================================================

OBJECTIVE

- Learn how Solidity stores boolean values
- Understand true/false state handling
- Learn how bool variables control contract logic
- Understand security implications of boolean flags

---------------------------------------------------------
WHAT IS A BOOLEAN?
---------------------------------------------------------

Boolean values can only be:

- true
- false

Solidity type:
bool

---------------------------------------------------------
COMMON REAL-WORLD USES
---------------------------------------------------------

Boolean variables are heavily used for:

- pause/unpause systems
- access permissions
- voting status
- transaction execution tracking
- reentrancy locks
- feature enable/disable switches

---------------------------------------------------------
IMPORTANT CONCEPT
---------------------------------------------------------

State bool variables are stored permanently
inside blockchain storage.

Their values persist across transactions.

---------------------------------------------------------
DEFAULT VALUE
---------------------------------------------------------

bool default value = false

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors check:

- Who can change boolean flags?
- Can attackers bypass restrictions?
- Is pause mechanism secure?
- Can critical flags be manipulated?
- Are flags reset correctly?

=========================================================
*/
/*
contract StoreBooleanVul {

    bool public isActive;

    function setStatus(bool _status) public {
        isActive = _status;
    }

    function getStatus() public view returns (bool) {
        return isActive;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

INITIAL STATE

isActive = false

Reason:
Default bool value is false.

---------------------------------------------------------

CALL:
setStatus(true)

EVM ACTIONS:

1. Transaction reaches contract
2. Boolean value arrives through calldata
3. Storage slot updated
4. isActive becomes true
5. Gas consumed

transaction cost	43798 gas 
execution cost	22594 gas 
---------------------------------------------------------

CALL:
setStatus(false)

RESULT:
Storage updated again

isActive becomes false

Old value overwritten.

---------------------------------------------------------

CALL:
getStatus()

EVM reads storage value
and returns current boolean state.

=========================================================
REMIX TESTING
=========================================================

NORMAL FLOW

STEP 1:
Deploy contract

EXPECTED:
isActive() => false

---------------------------------------------------------

STEP 2:
Call:
setStatus(true)

EXPECTED:
isActive() => true

---------------------------------------------------------

STEP 3:
Call:
setStatus(false)

EXPECTED:
isActive() => false

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Repeated toggling

Call:
setStatus(true)
setStatus(false)
setStatus(true)

EXPECTED:
Latest value stored successfully

---------------------------------------------------------

OBSERVE:
Boolean state changes permanently
after each transaction.

=========================================================
STORAGE OBSERVATION
=========================================================

Storage example:

Initial:
slot0 => false

After:
setStatus(true)

slot0 => true

After:
setStatus(false)

slot0 => false

Only latest value exists in storage.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

IMPORTANT SECURITY FACT

Boolean flags often control CRITICAL LOGIC.

Example uses:
- contract paused?
- user verified?
- transaction executed?
- admin approved?
- reentrancy locked?

---------------------------------------------------------
1. MISSING ACCESS CONTROL
---------------------------------------------------------

Current issue:
ANYONE can change status.

Real-world danger:
Attacker may:
- pause protocol
- unpause protocol
- bypass protections
- manipulate system behavior

---------------------------------------------------------
2. BOOLEAN MISUSE
---------------------------------------------------------

Incorrect boolean handling can cause:
- stuck funds
- bypassed validations
- repeated execution
- double spending

---------------------------------------------------------
3. STATE DESYNCHRONIZATION
---------------------------------------------------------

Auditors verify:
- flags updated correctly
- flags reset properly
- logic cannot become inconsistent

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Suppose:

isActive controls withdrawals.

Logic:
- true => withdrawals allowed
- false => withdrawals blocked

Attacker calls:

setStatus(true)

Impact:
Restricted functionality becomes enabled.

---------------------------------------------------------

ANOTHER REAL-WORLD ISSUE

Reentrancy guards use booleans.

If boolean reset fails:
- contract may lock forever
OR
- reentrancy protection may fail

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add toggleStatus() function
2. Function should reverse current state

Example:
true -> false
false -> true

HINT:

Use:
isActive = !isActive;

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- bool stores true/false values
- Default bool value is false
- Boolean state persists on blockchain
- Storage updates overwrite old values
- Boolean flags often control critical logic
- Access control is essential
- Incorrect flag handling causes vulnerabilities
- Reentrancy guards commonly use booleans

=========================================================
*/

/*
Audit Report

Title: Missing Access Control in setStatus() and toggleStatus()

Severity: Medium
Because unauthorized users can modify critical boolean state.

Location:
        Contract: StoreBooleanVul
        Function: setStatus()
        Function: toggleStatus()

Vulnerability Description:
    The setStatus() and toggleStatus() functions allow
    any external user to modify the isActive state variable
    because no access control mechanism is implemented.

Boolean variables often control important protocol logic
such as:
- pause/unpause systems
- withdrawal permissions
- feature activation
- reentrancy protection

Since the contract does not restrict who can update
the boolean flag, attackers may manipulate protocol behavior.

Impact:
An attacker can arbitrarily enable or disable
critical contract functionality.

If isActive controlled:
- withdrawals
- trading
- staking
- protocol pause state

then attackers could:
- bypass restrictions
- disable functionality
- manipulate system state

Proof of Concept:
        1. Deploy contract

        2. Initial state:
        isActive() => false

        3. User A calls:
        setStatus(true)

        4. Attacker calls:
        setStatus(false)

        5. Contract state changes successfully

------------------------------------------------

Another attack:

        1. Attacker repeatedly calls:
        toggleStatus()

        2. Boolean state continuously changes:
        true -> false
        false -> true

        3. Protocol behavior becomes unstable

Root Cause:
    The functions are declared public without authorization validation.

No require() statement verifies:
msg.sender == owner

As a result, any user can modify
critical boolean state.

Recommendation:
    Restrict status updates to authorized users only.

Example:

require(msg.sender == owner, "Not owner");

Additionally:
- use proper access control
- protect critical flags carefully
- audit boolean logic thoroughly

*/

// patched code 
/*
contract StoreBoolean {

    bool public isActive;
    address public owner;

    constructor(){
        owner=msg.sender;
    }

    function setStatus(bool _status) public {
        require(msg.sender==owner,"Not owner");
        isActive = _status;
    }

    function toggleStatus() public {
        require(msg.sender==owner,"Not owner");
        isActive=!isActive;
    }

    function getStatus() public view returns (bool) {
        return isActive;
    }
}
*/

contract StoreBoolean {
    bool public isActive;
    function setStatus(bool _status) public {
        isActive = _status;
    }
    function toogleStatus() public {
        isActive = !isActive;      
    }
    function getStatus() public view returns (bool) {
        return isActive;
    }
}