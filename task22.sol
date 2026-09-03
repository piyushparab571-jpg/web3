// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Use memory struct
CONCEPT: Temporary structs
=========================================================

OBJECTIVE

- Learn how memory structs work
- Understand temporary struct allocation
- Learn difference between memory structs and storage structs
- Understand temporary object lifecycle

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Memory structs:
- exist temporarily
- live only during execution
- disappear after function ends

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Memory structs do NOT persist
on blockchain storage.

They are useful for:
- temporary calculations
- data transformation
- returning grouped data
- processing information safely

---------------------------------------------------------
MEMORY STRUCT VS STORAGE STRUCT
---------------------------------------------------------

MEMORY STRUCT:
- temporary
- isolated copy
- cheaper
- disappears after execution

STORAGE STRUCT:
- permanent
- stored on blockchain
- expensive
- persists forever

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Memory structs used in:

- temporary user objects
- order processing
- calculations
- validation logic
- returned API-style responses

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Is struct temporary or persistent?
- Is developer expecting storage mutation?
- Are copies handled safely?
- Are references intentional?
- Can large structs waste gas?

=========================================================
*/
/*
contract MemoryStructExampleVul {

    /*
        STRUCT DEFINITION

        Groups related data together.
    
    struct User {

        string name;

        uint256 age;

        bool active;
    }

    /*
        STORAGE STRUCT

        Stored permanently on blockchain.
    
    User public storedUser;

    function createMemoryStruct()
        public
        pure
        returns (
            string memory,
            uint256,
            bool
        )
    {

        /*
            MEMORY STRUCT CREATION

            Temporary struct allocated in memory.
        
        User memory tempUser = User({

            name: "Alice",

            age: 25,

            active: true
        });

        /*
            tempUser exists only during execution.
        
        return (
            tempUser.name,
            tempUser.age,
            tempUser.active
        );
    }

    function createAndModifyMemoryStruct()
        public
        pure
        returns (
            string memory,
            uint256,
            bool
        )
    {

        /*
            Temporary memory struct
        
        User memory tempUser = User({

            name: "Bob",

            age: 30,

            active: true
        });

        /*
            MODIFY MEMORY STRUCT

            Changes affect only temporary copy.
        
        tempUser.age = 99;

        tempUser.active = false;

        return (
            tempUser.name,
            tempUser.age,
            tempUser.active
        );
    }

    function storeUser() public {

        /*
            STORAGE MUTATION

            This persists permanently.
        
        storedUser = User({

            name: "Charlie",

            age: 40,

            active: true
        });
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
createMemoryStruct()

EVM ACTIONS:

1. Temporary memory allocated
2. Struct created in memory
3. Values assigned
4. Data returned
5. Memory cleared after execution

---------------------------------------------------------

IMPORTANT

tempUser does NOT persist permanently.

---------------------------------------------------------

CALL:
createAndModifyMemoryStruct()

INITIAL MEMORY STRUCT:

{
    name: "Bob",
    age: 30,
    active: true
}

---------------------------------------------------------

AFTER MODIFICATION:

{
    name: "Bob",
    age: 99,
    active: false
}

---------------------------------------------------------

AFTER FUNCTION ENDS:
Memory struct destroyed.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
createMemoryStruct()

EXPECTED:
"Alice", 25, true

---------------------------------------------------------

STEP 3:
Call:
createAndModifyMemoryStruct()

EXPECTED:
"Bob", 99, false

---------------------------------------------------------

STEP 4:
Call:
storedUser()

EXPECTED:
Empty/default values

OBSERVE:
Memory structs did NOT persist.

---------------------------------------------------------

STEP 5:
Call:
storeUser()

---------------------------------------------------------

STEP 6:
Call:
storedUser()

EXPECTED:
"Charlie", 40, true

OBSERVE:
Storage struct persists permanently.

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Modify memory struct repeatedly

EXPECTED:
Fresh struct created each execution

---------------------------------------------------------

TEST:
Use empty strings

EXPECTED:
Works correctly

---------------------------------------------------------

TEST:
Large struct data

OBSERVE:
More memory allocation
= higher gas usage

=========================================================
IMPORTANT MEMORY UNDERSTANDING
=========================================================

THIS CREATES MEMORY STRUCT:

User memory tempUser

---------------------------------------------------------

STRUCT EXISTS ONLY:
during function execution.

---------------------------------------------------------

AFTER EXECUTION:
Memory cleared automatically.

---------------------------------------------------------

VERY IMPORTANT

Memory structs:
do NOT persist on blockchain.

=========================================================
MEMORY STRUCT MUTABILITY
=========================================================

MEMORY STRUCTS ARE MUTABLE

Example:

tempUser.age = 99;

---------------------------------------------------------

HOWEVER:
Changes remain temporary only.

=========================================================
MEMORY VS STORAGE STRUCT
=========================================================

---------------------------------------------------------
MEMORY STRUCT
---------------------------------------------------------

Temporary

Cheap

Destroyed after execution

---------------------------------------------------------
STORAGE STRUCT
---------------------------------------------------------

Permanent

Expensive

Stored on blockchain forever

=========================================================
GAS OBSERVATION
=========================================================

MEMORY STRUCTS:
Cheaper than storage

---------------------------------------------------------

LARGE STRUCTS:
Still increase memory cost

---------------------------------------------------------

STORAGE WRITES:
Most expensive operations

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. MEMORY/STORAGE CONFUSION
---------------------------------------------------------

Common Solidity bug source.

Developers may think:
memory modifications persist.

They do NOT.

---------------------------------------------------------
2. COPY ASSUMPTIONS
---------------------------------------------------------

Auditors verify:
whether struct is:
- temporary copy
OR
- storage reference

---------------------------------------------------------
3. LARGE MEMORY STRUCTS
---------------------------------------------------------

Huge structs may:
- waste gas
- increase execution cost

---------------------------------------------------------
4. SILENT LOGIC FAILURES
---------------------------------------------------------

Protocol may expect:
storage mutation

but only memory updated.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Developer modifies memory struct
expecting permanent update.

Critical state never changes.

Possible impact:
- broken access control
- failed accounting
- incorrect balances

---------------------------------------------------------

ANOTHER RISK

Attacker supplies huge struct data.

Result:
high gas consumption.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Copy storage struct into memory
2. Modify memory copy
3. Show storage remains unchanged

BONUS:
Compare:
memory struct vs storage struct behavior

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Memory structs are temporary
- Memory structs disappear after execution
- Memory structs are mutable
- Storage structs persist permanently
- Memory changes do not affect storage
- Memory cheaper than storage
- Large structs increase gas usage
- Copy/reference confusion causes bugs
- Structs group related data together
- Auditors inspect struct semantics carefully

=========================================================
*/

/*
AUDIT REPORT

Title: Memory Struct Modification Does Not Persist to Storage

Severity: Low

Reason:
Modifying a memory struct only changes the temporary copy and does not update the original storage struct.

Location:
    Contract: MemoryStructExample
    Function: copyStorageStcToMemory()

Vulnerability Description:

        The function copyStorageStcToMemory() copies the storage struct
        storedUser into a temporary memory struct:
        User memory tempStorage = storedUser;

        The memory struct is then modified:

        tempStorage.name = "jagruti";
        tempStorage.age = 21;
        tempStorage.active = false;

        However, these modifications affect only the temporary memory copy.

        The original storedUser struct in blockchain storage remains unchanged.

        Developers commonly misunderstand this behavior and may incorrectly assume that modifying the memory struct updates persistent contract state.

        This can cause silent logic failures in real-world smart contracts.

Impact:
- Expected storage updates may fail silently
- Protocol state may remain unchanged
- Incorrect application behavior
- Potential accounting or access-control logic failures

Proof of Concept:
        1. Deploy contract

        2. Call:
        storeUser()

        Stored user becomes:
        ("Charlie", 40, true)

        3. Call:
        copyStorageStcToMemory()

        Returned output:
        ("jagruti", 21, false)

        4. Call:
        storedUser()

Actual storage value:
("Charlie", 40, true)

Observation:
Storage struct remains unchanged.

Root Cause:
- Storage struct copied into memory
- Memory creates independent temporary copy
- Memory modifications do not persist

Recommendation:
    Use storage reference when permanent modification is intended.

Example:

User storage tempStorage = storedUser;

This directly references storage and permanently updates state.
*/
//patched code 
/*
contract MemoryStructExample {

    /*
        STRUCT DEFINITION

        Groups related data together.
    
    struct User {
        string name;
        uint256 age;
        bool active;
    }

    /*
        STORAGE STRUCT

        Stored permanently on blockchain.
    
    User public storedUser;

    function createMemoryStruct()public pure returns (string memory,uint256,bool){
        /*
            MEMORY STRUCT CREATION

            Temporary struct allocated in memory.
        
        User memory tempUser = User({
            name: "Alice",
            age: 25,
            active: true
        });

        /*
            tempUser exists only during execution.
        
        return (
            tempUser.name,
            tempUser.age,
            tempUser.active
        );
    }

    function createAndModifyMemoryStruct()public pure returns (string memory,uint256,bool){
        /*
            Temporary memory struct
        
        User memory tempUser = User({
            name: "Bob",
            age: 30,
            active: true
        });

        /*
            MODIFY MEMORY STRUCT

            Changes affect only temporary copy.
        
        tempUser.age = 99;
        tempUser.active = false;
        return (
            tempUser.name,
            tempUser.age,
            tempUser.active
        );
    }

    function storeUser() public {
        /*
            STORAGE MUTATION

            This persists permanently.
        
        storedUser = User({
            name: "Charlie",
            age: 40,
            active: true
        });
    }

    function copyStorageStcToMemory()public view  returns (string memory,uint256,bool) {
 // Copy STORAGE struct into MEMORY
        User memory tempStorage=storedUser;
  // Modifyies MEMORY copy only
            tempStorage.name="jagruti";
            tempStorage.age=21;
            tempStorage.active= false;

            return(tempStorage.name,tempStorage.age,tempStorage.active);
    }
}
*/
contract MemoryStructExampleVul {
    struct User {
        string name;
        uint256 age;
        bool active;
    }
    //Storgae struct
    User public storedUser;
    //Store initial user in storage
    function storeUser() public {
        storedUser = User({
            name: "Charlie",
            age: 40,
            active: true
        });
    }
    //Storage -> memory copy
    function copyStorageToMemory()
    public 
    view 
    returns (string memory, uint256, bool)
    {
        //create a memory copy of storage struct
        User memory tempUser = storedUser;
        //Modify MEMORY copy
        tempUser.age = 99;
        tempUser.active = false;
        //Storage remians unchanged
        return (
            tempUser.name,
            tempUser.age,
            tempUser.active
        );
       
        
    }
     //check original storage struct
     function getStoredUser()
     public 
     view 
     returns (string memory, uint256, bool)
     {
        return (
            storedUser.name,
            storedUser.age,
            storedUser.active
        );
     }
}