// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Use storage reference variable
CONCEPT: Direct storage pointer
=========================================================

OBJECTIVE

- Learn how storage reference variables work
- Understand direct pointers to storage
- Learn difference between storage and memory
- Understand how modifying storage references
  directly changes blockchain state

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

A storage reference variable points directly
to an existing storage location.

Example:

User storage user = users[id];

This does NOT create copy.

Instead:
user becomes POINTER to storage.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Modifying storage reference:

user.age = 50;

directly updates blockchain storage.

---------------------------------------------------------
STORAGE VS MEMORY
---------------------------------------------------------

STORAGE:
- permanent
- expensive
- modifies blockchain state
- acts like pointer/reference

MEMORY:
- temporary copy
- disappears after execution
- modifying memory does NOT update storage

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Storage references are heavily used in:

- DeFi protocols
- staking systems
- NFT marketplaces
- governance contracts
- user profile systems

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Are storage references intentional?
- Is accidental mutation possible?
- Are references pointing correctly?
- Is storage corruption possible?
- Is memory/storage confusion present?

=========================================================
*/
/*
contract StorageReferenceVul {

    struct User {

        uint256 age;

        bool active;
    }

    mapping(address => User) public users;

    function createUser(uint256 _age) public {

        users[msg.sender] = User(_age, true);
    }

    function updateAge(uint256 _newAge) public {

        
            STORAGE REFERENCE VARIABLE

            This creates POINTER to actual storage.

            user is NOT copy.

            user directly references:
            users[msg.sender]
        
        User storage user = users[msg.sender];

        
            DIRECT STORAGE MUTATION

            Since user points to storage,
            this updates blockchain state directly.
        
        user.age = _newAge;
    }

    function deactivateUser() public {

        
            Another storage reference example
        
        User storage user = users[msg.sender];

        user.active = false;
    }

    function getMyData()
        public
        view
        returns (uint256, bool)
    {
        User storage user = users[msg.sender];

        return (user.age, user.active);
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

INITIAL STATE

users[msg.sender]:

age = 0
active = false

---------------------------------------------------------

CALL:
createUser(25)

RESULT:

users[msg.sender]:
age = 25
active = true

---------------------------------------------------------

CALL:
updateAge(40)

EVM ACTIONS:

1. Mapping storage slot located
2. Storage reference created
3. user points directly to storage
4. user.age updated
5. Blockchain state mutated

---------------------------------------------------------

FINAL STATE

users[msg.sender]:
age = 40
active = true

---------------------------------------------------------

IMPORTANT

No copy created.

Storage reference directly modifies storage.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
createUser(25)

---------------------------------------------------------

STEP 3:
Call:
getMyData()

EXPECTED:
25, true

---------------------------------------------------------

STEP 4:
Call:
updateAge(99)

---------------------------------------------------------

STEP 5:
Call:
getMyData()

EXPECTED:
99, true

OBSERVE:
Storage updated permanently.

---------------------------------------------------------

STEP 6:
Call:
deactivateUser()

EXPECTED:
99, false

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Update before createUser()

EXPECTED:
Works on default struct values

---------------------------------------------------------

TEST:
Repeated updates

EXPECTED:
Latest storage state persists

---------------------------------------------------------

TEST:
Different Remix accounts

EXPECTED:
Each address has isolated struct storage

=========================================================
IMPORTANT STORAGE UNDERSTANDING
=========================================================

THIS LINE:

User storage user = users[msg.sender];

creates STORAGE POINTER.

---------------------------------------------------------

VERY IMPORTANT

This is NOT copy:

User memory user = users[msg.sender];

would create temporary copy instead.

---------------------------------------------------------

STORAGE REFERENCE

Changes affect blockchain storage immediately.

---------------------------------------------------------

MEMORY COPY

Changes affect temporary copy only.

=========================================================
STORAGE VS MEMORY EXAMPLE
=========================================================

---------------------------------------------------------
STORAGE
---------------------------------------------------------

User storage user = users[msg.sender];

user.age = 50;

RESULT:
Blockchain storage updated.

---------------------------------------------------------
MEMORY
---------------------------------------------------------

User memory user = users[msg.sender];

user.age = 50;

RESULT:
Only temporary copy changes.

Original storage unchanged.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. ACCIDENTAL STORAGE MUTATION
---------------------------------------------------------

Developers may accidentally modify
real storage when expecting copy.

This causes unintended state changes.

---------------------------------------------------------
2. MEMORY/STORAGE CONFUSION
---------------------------------------------------------

Very common Solidity bug source.

Auditors carefully inspect:
- reference types
- assignment behavior
- mutation side effects

---------------------------------------------------------
3. UNEXPECTED SIDE EFFECTS
---------------------------------------------------------

Changing storage references may:
- alter protocol state unexpectedly
- corrupt accounting
- bypass assumptions

---------------------------------------------------------
4. GAS CONSIDERATIONS
---------------------------------------------------------

Storage writes are expensive.

Unnecessary mutations waste gas.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Improper storage references may allow:
- accidental balance updates
- corrupted staking records
- unintended ownership changes

---------------------------------------------------------

REAL-WORLD RISK

Many Solidity bugs happen because:
developers expect copy
but receive storage reference instead.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add function using MEMORY copy
2. Change memory values
3. Observe storage remains unchanged

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- storage creates direct reference/pointer
- Storage references mutate blockchain state
- memory creates temporary copy
- Storage persists permanently
- Storage writes consume gas
- Reference types behave differently
- Memory/storage confusion causes bugs
- Structs inside mappings commonly use storage refs
- Storage references can create side effects
- Auditors inspect pointer behavior carefully

=========================================================
*/

/*
AUDIT REPORT
Title: Missing Access Control in setNumber() Allows Unauthorized State Modification
Severity: Medium
Reason:

The setNumber() function is publicly accessible and allows any user to modify critical contract state without proper authorization checks.

Location:
Contract: DeploymentReset
Function: setNumber(uint256 _number)
Vulnerability Description:

The function setNumber() is declared as public and does not enforce any access control.

This allows any external user to modify the number state variable, which can lead to unauthorized state changes in the contract.

Impact:

An attacker can overwrite the stored value with arbitrary data.

If this variable is used in:

protocol configuration
business logic
system parameters
user-dependent calculations

then it can lead to complete protocol manipulation.

Proof of Concept (PoC):
        1. Deploy Contract
             Deploy the DeploymentReset contract.

        2. Initial State Check
            Call:
                getNumber()
            Expected:
                 0
        3. Attacker State Change
            Any user calls:
                 setNumber(123)
        4. Malicious State Override
                Another attacker calls:
                setNumber(999999)
        5. Final State

        6.Call:
            getNumber()

        7.Result:
            999999

Root Cause:
    The function lacks access control validation.

No restriction such as:
    require(msg.sender == owner, "Not Owner");
is implemented.

Recommendation:
    Restrict access to authorized users only.

Fix Example:
function setNumber(uint256 _number) public {
    require(msg.sender == owner, "Not Owner");
    number = _number;
}
*/

//patched code 
/*
contract StorageReference {
    struct User {
        uint256 age;
        bool active;
    }

    mapping(address => User) public users;

    function createUser(uint256 _age) public {
        users[msg.sender] = User(_age, true);
    }

    function updateAge(uint256 _newAge) public {
        User storage user = users[msg.sender];
        user.age = _newAge;
    }

    function memoryStorage()public view returns (uint256,bool){
        User memory user=users[msg.sender];   // temporary copy
        // modifying COPY only
        user.age=25;
        user.active=true;
         // returns modified memory values
        return (user.age,user.active);
    }

    function deactivateUser() public {
        /*
            Another storage reference example
        
        User storage user = users[msg.sender];
        user.active = false;
    }

    function getMyData()public view returns (uint256, bool){
        User storage user = users[msg.sender];
        return (user.age, user.active);
    }
}
*/
contract StorageReference {
    struct User {
        uint256 age;
        bool active;
    }
    mapping(address => User) public users;
    function createUser(uint256 _age) public {
        users[msg.sender] = User(_age, true);
    }
    //Storage reference - changes actual blockchain storage
    function updateAge(uint256 _newAge) public {
        User storage user = users[msg.sender];
        user.age = _newAge;
    }
    //Storage reference - changes actual blockchain storage 
    function deactivateUser() public {
        User storage user = users[msg.sender];
        user.active = false;
    }
    //Memory copy
    function changeMemoryCopy()
    public 
    view 
    returns (uint256, bool)
    {
        //create a COPY in memory
        User memory user = users[msg.sender];
        //change only thre memory copy
        user.age = 100;
        user.active = false;
        //return changed memory values
        return (user.age, user.active);
    }
    function getMyData()
    public 
    view 
    returns (uint256, bool)
    {
        User storage user = users[msg.sender];
        return (user.age, user.active);
    }
}