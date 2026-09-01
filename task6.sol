// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Store struct data
CONCEPT: Complex storage layout
=========================================================

OBJECTIVE

- Learn how Solidity stores struct data
- Understand grouped data storage
- Learn complex storage organization
- Understand struct-related security concerns

---------------------------------------------------------
WHAT IS A STRUCT?
---------------------------------------------------------

A struct allows multiple variables
to be grouped together into one object.

Example:
A user may contain:
- name
- age
- wallet
- active status

Instead of separate variables,
struct combines them into one unit.

---------------------------------------------------------
REAL-WORLD USES
---------------------------------------------------------

Structs are heavily used in:

- user profiles
- staking positions
- NFT metadata
- order books
- voting systems
- DeFi positions
- marketplace listings

---------------------------------------------------------
IMPORTANT CONCEPT
---------------------------------------------------------

Struct data is stored sequentially
inside blockchain storage.

Each field occupies storage slots
depending on variable size.

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors check:

- Is struct data initialized safely?
- Can users overwrite others' structs?
- Is stale data left behind?
- Is storage packing optimized?
- Are nested structs handled correctly?

=========================================================
*/
/*
contract StructStorageVul {

    struct User {

        string name;

        uint256 age;

        address wallet;

        bool isActive;
    }

    User public user;

    function storeUser(
        string memory _name,
        uint256 _age,
        address _wallet,
        bool _isActive
    ) public {

        user = User(_name, _age, _wallet, _isActive);
    }

    function getUser()
        public
        view
        returns (
            string memory,
            uint256,
            address,
            bool
        )
    {
        return (
            user.name,
            user.age,
            user.wallet,
            user.isActive
        );
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

INITIAL STATE

Struct fields contain default values:

name      => ""
age       => 0
wallet    => 0x0000000000000000000000000000000000000000
isActive  => false

---------------------------------------------------------

CALL:
storeUser("Imran", 25, 0x123..., true)

EVM ACTIONS:

1. Function parameters arrive via calldata
2. _name copied into memory
3. Struct object created temporarily
4. Struct fields written into storage
5. Existing struct data overwritten
6. Gas consumed for storage writes

---------------------------------------------------------

STORAGE RESULT

user.name      = "Imran"
user.age       = 25
user.wallet    = 0x123...
user.isActive  = true

---------------------------------------------------------

CALL:
getUser()

EVM:
1. Reads struct fields from storage
2. Returns all values

=========================================================
REMIX TESTING
=========================================================

NORMAL FLOW

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:

storeUser(
    "Alice",
    30,
    <wallet address>,
    true
)

---------------------------------------------------------

STEP 3:
Call:
getUser()

EXPECTED:
- name = Alice
- age = 30
- wallet = provided address
- isActive = true

---------------------------------------------------------

STEP 4:
Store new user data

EXPECTED:
Old struct data overwritten completely

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Empty string

storeUser("", 0, address(0), false)

EXPECTED:
Works successfully

---------------------------------------------------------

TEST:
Overwrite struct multiple times

EXPECTED:
Latest values replace old values

---------------------------------------------------------

TEST:
Very large string input

OBSERVE:
Higher gas usage due to dynamic string storage

transaction cost	91192 gas 
execution cost	68988 gas 
=========================================================
IMPORTANT STORAGE UNDERSTANDING
=========================================================

STRUCT STORAGE LAYOUT

Struct fields are stored sequentially.

Example layout:

slot0 => string reference/data
slot1 => age
slot2 => wallet + bool (possible packing)

---------------------------------------------------------

STORAGE PACKING

Smaller variables may share slots.

Example:
- bool
- uint8
- address

can sometimes pack together
to reduce gas usage.

---------------------------------------------------------

DYNAMIC TYPES

string is dynamic type.

Dynamic data requires:
- extra storage handling
- additional gas

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. COMPLETE OVERWRITE RISK
---------------------------------------------------------

Current logic replaces ENTIRE struct.

Danger:
Partial updates may accidentally erase fields.

---------------------------------------------------------
2. USER OWNERSHIP VALIDATION
---------------------------------------------------------

Current contract stores only one global user.

In real systems,
structs are often stored in mappings:

mapping(address => User)

Auditors verify:
- users cannot overwrite others' data
- ownership checks exist

---------------------------------------------------------
3. STORAGE BLOAT
---------------------------------------------------------

Large structs increase:
- gas cost
- deployment complexity
- execution cost

Auditors inspect:
- unnecessary fields
- inefficient storage layout

---------------------------------------------------------
4. DYNAMIC DATA RISKS
---------------------------------------------------------

Strings consume more gas.

Attackers may abuse:
- massive inputs
- storage flooding
- gas griefing

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Suppose struct stores:

- KYC data
- admin config
- staking positions
- reward settings

Without access control,
attacker may overwrite entire struct.

---------------------------------------------------------

ANOTHER RISK

If partial updates are implemented incorrectly:

old values may unintentionally reset.

Example:
wallet becomes zero address accidentally.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Multiple users can store profiles
2. Use mapping(address => User)

BONUS:
Allow only msg.sender to modify own profile.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Structs group multiple variables together
- Structs are stored in blockchain storage
- Struct data persists permanently
- Struct updates overwrite old data
- Dynamic types consume more gas
- Storage packing affects optimization
- Strings require special storage handling
- Struct misuse can cause serious vulnerabilities
- Auditors inspect storage layout carefully
- Access control is critical for struct updates

=========================================================
*/

/*
Audit Report

Title: Single Global Struct Overwrite Risk

Severity: Medium
Because any user can overwrite the globally stored struct data.

Location:
Contract: StructStorageVul
Function: storeUser()

Vulnerability Description:
The storeUser() function stores all user data
inside a single global User struct variable:

User public user;

This means every new call completely overwrites
previously stored user information.

Any external user can replace:
- name
- age
- wallet
- active status

of the previously stored profile.

The contract does not isolate user-specific data.

Impact:
An attacker can overwrite previously stored
user profile information.

If the struct represented:
- KYC records
- staking positions
- admin configurations
- marketplace listings
- governance data

then attackers could:
- corrupt protocol state
- erase user information
- manipulate stored records
- replace important configuration data

Proof of Concept:
1. Deploy contract

2. User A calls:

storeUser(
    "Alice",
    25,
    0xAAA...,
    true
)

3. Call:
   getUser()

Result:
- Alice
- 25
- 0xAAA...
- true

------------------------------------------------

4. Attacker calls:

storeUser(
    "Hacker",
    99,
    0xBBB...,
    false
)

5. Call:
   getUser()

Result:
- Hacker
- 99
- 0xBBB...
- false

Previous user data overwritten successfully.

Root Cause:
The contract uses a single global struct:

User public user;

instead of maintaining separate user profiles.

The function directly overwrites
the entire struct:

user = User(_name, _age, _wallet, _isActive);

No user isolation mechanism exists.

Recommendation:
Store profiles separately for each user
using mapping(address => User).

Additionally:
- allow users to modify only their own profile
- avoid global shared user storage
- validate critical struct updates carefully

Example:

mapping(address => User) public users;

users[msg.sender] = User(
    _name,
    _age,
    msg.sender,
    _isActive
);
*/
// patched code
/*
contract StructStorage {
    address public wallet=msg.sender;
    struct User {
        string name;
        uint256 age;
        address  wallet;
        bool isActive;
    }
    
    User public user;

    mapping (address=>User) public users;

    function storeUser(string memory _name,uint256 _age,bool _isActive) public {
        users[msg.sender] = User(_name, _age, msg.sender, _isActive);
    }

    function getUser()public view returns (string memory,uint256,address,bool)
    {
        User memory user=users[msg.sender];
        return (user.name,user.age,user.wallet,user.isActive);
    }
}
*/
contract StructStorage {
    struct User {
        string name;
        uint256 age;
        address wallet;
        bool isActive;
    }
    mapping(address => User) public users;
    function storeUser(string memory _name, uint _age, bool _isActive) public {
        users[msg.sender] = User(_name, _age, msg.sender, _isActive);
    }
}
