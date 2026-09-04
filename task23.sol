// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Compare storage vs memory updates
CONCEPT: Reference behavior
=========================================================

OBJECTIVE

- Learn difference between storage and memory updates
- Understand reference vs copy behavior
- Learn why storage changes persist
- Understand why memory changes disappear

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

STORAGE:
Creates direct reference to blockchain state.

MEMORY:
Creates temporary independent copy.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

STORAGE UPDATE:
Changes original blockchain data.

MEMORY UPDATE:
Changes temporary copy only.

---------------------------------------------------------
VERY IMPORTANT
---------------------------------------------------------

This is one of the MOST IMPORTANT
concepts in Solidity security.

Many real-world bugs happen because:
developers confuse memory and storage.

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Understanding reference behavior is critical for:

- DeFi protocols
- token accounting
- staking systems
- governance logic
- NFT marketplaces
- upgradeable contracts

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Is storage reference intentional?
- Is memory copy expected?
- Are mutations happening correctly?
- Can accidental state mutation occur?
- Is protocol logic silently failing?

=========================================================
*/
/*
contract StorageVsMemoryVul {

    /*
        STRUCT STORED ON BLOCKCHAIN
    
    struct User {
        uint256 score;
        bool active;
    }

    /*
        STORAGE MAPPING

        Persistent blockchain storage
    
    mapping(address => User) public users;

    function createUser() public {

        users[msg.sender] = User({
            score: 100,
            active: true
        });
    }

    function updateUsingStorage() public {
        /*
            STORAGE REFERENCE

            user directly points to:
            users[msg.sender]
        
        User storage user = users[msg.sender];
        /*
            MODIFY STORAGE DIRECTLY

            Changes persist permanently.
        
        user.score = 999;
    }

    function updateUsingMemory() public view returns (uint256,bool) {

        /*
            MEMORY COPY

            Creates independent temporary copy.
        
        User memory user = users[msg.sender];

        /*
            MODIFY MEMORY COPY ONLY

            Original storage remains unchanged.
        
        user.score = 555;
        user.active = false;

        /*
            Returning modified MEMORY values
        
        return (
            user.score,
            user.active
        );
    }

    function getUser()public view returns (uint256,bool){
        User storage user = users[msg.sender];
        return (
            user.score,
            user.active
        );
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
createUser()

STORAGE STATE:

{
    score: 100,
    active: true
}

---------------------------------------------------------

CALL:
updateUsingStorage()

EVM ACTIONS:

1. Storage reference created
2. user points directly to storage
3. user.score updated
4. Blockchain state modified permanently

---------------------------------------------------------

FINAL STORAGE STATE:

{
    score: 999,
    active: true
}

=========================================================

CALL:
updateUsingMemory()

EVM ACTIONS:

1. Storage struct copied into memory
2. user becomes temporary copy
3. Memory values modified
4. Storage remains untouched
5. Memory destroyed after execution

---------------------------------------------------------

MEMORY COPY:

{
    score: 555,
    active: false
}

---------------------------------------------------------

ACTUAL STORAGE STILL:

{
    score: 999,
    active: true
}

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
createUser()

---------------------------------------------------------

STEP 3:
Call:
getUser()

EXPECTED:
100, true

---------------------------------------------------------

STEP 4:
Call:
updateUsingStorage()

---------------------------------------------------------

STEP 5:
Call:
getUser()

EXPECTED:
999, true

OBSERVE:
Storage permanently updated.

---------------------------------------------------------

STEP 6:
Call:
updateUsingMemory()

EXPECTED RETURN:
555, false

---------------------------------------------------------

STEP 7:
Call:
getUser()

EXPECTED:
999, true

OBSERVE:
Storage remained unchanged.

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Call updateUsingMemory() repeatedly

EXPECTED:
Storage never changes

---------------------------------------------------------

TEST:
Call updateUsingStorage() multiple times

EXPECTED:
Storage updates persist

---------------------------------------------------------

TEST:
Use different Remix accounts

EXPECTED:
Each address has isolated storage

=========================================================
IMPORTANT REFERENCE UNDERSTANDING
=========================================================

---------------------------------------------------------
STORAGE REFERENCE
---------------------------------------------------------

User storage user = users[msg.sender];

Creates POINTER.

Changes affect original storage.

---------------------------------------------------------
MEMORY COPY
---------------------------------------------------------

User memory user = users[msg.sender];

Creates INDEPENDENT COPY.

Changes affect only memory.

=========================================================
VERY IMPORTANT SECURITY CONCEPT
=========================================================

MANY BUGS HAPPEN BECAUSE:

Developer expects:
storage update

But accidentally modifies:
memory copy

---------------------------------------------------------

RESULT:
Protocol logic silently fails.

=========================================================
GAS OBSERVATION
=========================================================

STORAGE WRITES:
Expensive

---------------------------------------------------------

MEMORY OPERATIONS:
Cheaper

---------------------------------------------------------

COPYING STORAGE TO MEMORY:
Still consumes gas

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. MEMORY/STORAGE CONFUSION
---------------------------------------------------------

One of most common Solidity bug classes.

Auditors inspect:
- copy semantics
- reference behavior
- mutation expectations

---------------------------------------------------------
2. ACCIDENTAL STORAGE MUTATION
---------------------------------------------------------

Storage references may:
unexpectedly modify state.

---------------------------------------------------------
3. SILENT FAILURES
---------------------------------------------------------

Memory modifications may:
appear successful
but never persist.

---------------------------------------------------------
4. GAS RISKS
---------------------------------------------------------

Large copies from storage to memory
can become expensive.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Critical validation modifies memory copy
instead of storage.

Security state never updates.

Possible impact:
- bypassed restrictions
- broken accounting
- failed access control

---------------------------------------------------------

ANOTHER RISK

Unexpected storage references may:
modify balances unintentionally.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add memory array example
2. Add storage array example
3. Compare mutation behavior

BONUS:
Observe gas differences in Remix.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Storage creates direct reference
- Memory creates independent copy
- Storage updates persist permanently
- Memory updates disappear after execution
- Memory/storage confusion causes bugs
- Storage writes consume more gas
- Copying storage to memory costs gas
- Reference behavior critical in Solidity
- Many vulnerabilities come from wrong assumptions
- Auditors inspect mutation semantics carefully

=========================================================
*/

/*
AUDIT REPORT

Title: Memory vs Storage Confusion May Cause Silent State Update Failure

Severity: Medium

Reason:
The original contract demonstrates how modifying a memory copy
does not persist changes to blockchain storage.

Developers may incorrectly assume memory updates permanently
modify protocol state, leading to silent logic failures.

---------------------------------------------------------
Location
---------------------------------------------------------

Contract: StorageVsMemoryVul
Function: updateUsingMemory()

---------------------------------------------------------
Vulnerability Description
---------------------------------------------------------

The function updateUsingMemory() copies the user struct
from storage into memory:

    User memory user = users[msg.sender];

The function then modifies the memory copy:

    user.score = 555;
    user.active = false;

However, these changes affect only the temporary memory copy
and do NOT update the original storage mapping.

This creates a common Solidity vulnerability pattern where
developers mistakenly believe protocol state has been updated
permanently, while actual blockchain storage remains unchanged.

---------------------------------------------------------
Impact
---------------------------------------------------------

- Silent protocol logic failure
- Incorrect state assumptions
- Failed accounting updates
- Broken validation logic
- Potential access control issues
- Confusing application behavior

---------------------------------------------------------
Proof of Concept
---------------------------------------------------------

1. Deploy contract

2. Call:
    createUser()

3. Call:
    getUser()

Expected:
    100, true

4. Call:
    updateUsingMemory()

Returned values:
    555, false

5. Call:
    getUser()

Actual storage values remain:
    100, true

---------------------------------------------------------
Observation
---------------------------------------------------------

The function appears to update values successfully,
but blockchain storage remains unchanged because only
the memory copy was modified.

---------------------------------------------------------
Root Cause
---------------------------------------------------------

- Incorrect assumption about memory persistence
- Storage struct copied into temporary memory
- Memory mutations disappear after execution
- No direct storage update performed

---------------------------------------------------------
Recommendation
---------------------------------------------------------

Use storage references when permanent state modification
is intended.

Example:

    User storage user = users[msg.sender];

    user.score = 555;
    user.active = false;
*/
//patched code
/*
contract StorageVsMemory {
    uint256[] public numbers;

    function addValues()public {
        numbers.push(1);
        numbers.push(2);
        numbers.push(3);
    }

    function modifyMemoryArr()public view returns (uint256[] memory,uint256[] memory){
        uint256[] memory temp=numbers;
        require(numbers.length>0,"Array is empty");
        temp[0]=11;
        return (temp,numbers);
    }

    function modifyStorageArr()public {
        uint256[] storage persist=numbers;
        require(numbers.length>0,"Array is empty");
        persist[0]=111;
    }

    function getArray()public view returns (uint256[] memory){
        return numbers;
    }
}
*/
contract StorageVsMemoryVul {
    struct User {
        uint256 score;
        bool active;
    }
    mapping(address => User) public users;
    uint256[] public storageArray;
    function createUser() public {
        users[msg.sender] = User(100, true);
    }
    //storage mutation -> changes permanently
    function updateStorage() public {
        User storage user = users[msg.sender];
        user.score = 999;
    }
    //Memory mutation -> does NOT change storage
    function updateMemory() public view returns (uint256, bool) {
        User memory user = users[msg.sender];
        user.score = 555;
        user.active = false;
        return (user.score, user.active);
    }
    //storage arrat
    function addStorageArray() public {
        storageArray.push(10);
        storageArray.push(20);
        storageArray.push(30);
    }
    //storage array mutation
    function modifyStorageArray() public {
        storageArray[0] = 999;
    }
    // Memory array
    function memoryArray() public pure returns (uint256[] memory) {
        uint256[] memory arr = new uint256[](3);
        arr[0] = 10;
        arr[1] = 20;
        arr[2] = 30;
        arr[0] = 999;
        return arr;
    }
    //storage -> memory copy
    function memoryCopy() public view returns (uint256[] memory) {
        uint256[] memory arr = storageArray;
        if (arr.length > 0) arr[0] = 555;
        return arr;
    }
}