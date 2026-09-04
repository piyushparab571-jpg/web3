// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Pass memory string to function
CONCEPT: Dynamic memory
=========================================================

OBJECTIVE

- Learn how dynamic strings work in memory
- Understand passing memory strings to functions
- Learn memory lifecycle for dynamic data
- Understand why strings require explicit data locations

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Strings are dynamic data types.

Because size can change,
Solidity requires explicit data location:

- memory
- storage
- calldata

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

memory string:
- temporary
- mutable
- exists during execution only

---------------------------------------------------------
WHY STRINGS USE MEMORY
---------------------------------------------------------

Strings are variable-sized data.

Unlike uint256:
their size is not fixed.

Therefore:
Solidity must know where data lives.

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Memory strings used in:

- usernames
- metadata
- NFT names
- messages
- temporary processing
- API-style responses

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Is data location correct?
- Are strings copied unnecessarily?
- Can large inputs cause DOS?
- Is calldata preferable?
- Are dynamic allocations safe?

=========================================================
*/
/*
contract MemoryStringExampleVul {

    /*
        STORAGE STRING

        Stored permanently on blockchain.
    
    string public storedName;

    function saveName(string memory _name) public {

        /*
            _name exists temporarily in memory.

            During execution:
            _name can be modified.

            After execution:
            memory cleared.
        

        /*
            STORAGE WRITE

            Copies memory string into storage.
        
        storedName = _name;
    }

    function getWelcomeMessage(
        string memory _name
    )
        public
        pure
        returns (string memory)
    {

        /*
            MEMORY STRING VARIABLE

            Temporary dynamic string.
        
        string memory message = _name;

        /*
            Returning temporary memory string.
        
        return message;
    }

    function compareStrings(
        string memory _first,
        string memory _second
    )
        public
        pure
        returns (
            string memory,
            string memory
        )
    {

        /*
            Both strings exist only temporarily
            during execution.
        

        return (_first, _second);
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
saveName("Alice")

EVM ACTIONS:

1. "Alice" arrives in calldata
2. Copied into memory as _name
3. _name exists temporarily
4. storedName updated in storage
5. Memory cleared after execution

---------------------------------------------------------

FINAL STORAGE:

storedName = "Alice"

=========================================================

CALL:
getWelcomeMessage("Bob")

EVM ACTIONS:

1. "Bob" copied into memory
2. message variable created
3. message returned
4. Memory destroyed after execution

---------------------------------------------------------

IMPORTANT

No permanent storage modification occurs.

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
saveName("Alice")

---------------------------------------------------------

STEP 3:
Call:
storedName()

EXPECTED:
"Alice"

---------------------------------------------------------

STEP 4:
Call:
getWelcomeMessage("Bob")

EXPECTED:
"Bob"

---------------------------------------------------------

STEP 5:
Call:
compareStrings("Hello","World")

EXPECTED:
"Hello", "World"

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Pass empty string

saveName("")

EXPECTED:
Empty string stored successfully

---------------------------------------------------------

TEST:
Pass very large string

OBSERVE:
Higher gas consumption

---------------------------------------------------------

TEST:
Unicode input

Example:
"ब्लॉकचेन"

EXPECTED:
Stored correctly

=========================================================
IMPORTANT MEMORY UNDERSTANDING
=========================================================

THIS FUNCTION PARAMETER:

string memory _name

---------------------------------------------------------

MEANS:

- temporary string
- allocated in memory
- exists only during execution

---------------------------------------------------------

AFTER FUNCTION ENDS:
Memory cleared automatically.

=========================================================
WHY MEMORY KEYWORD REQUIRED
=========================================================

Dynamic types require explicit location.

Examples:
- string
- bytes
- arrays
- structs

---------------------------------------------------------

Solidity must know:
where data should live.

=========================================================
MEMORY VS STORAGE STRING
=========================================================

---------------------------------------------------------
MEMORY STRING
---------------------------------------------------------

Temporary

Mutable

Destroyed after execution

---------------------------------------------------------
STORAGE STRING
---------------------------------------------------------

Permanent

Stored on blockchain

Persists forever

=========================================================
GAS OBSERVATION
=========================================================

MEMORY STRINGS:
Cheaper than storage

---------------------------------------------------------

STORAGE WRITES:
Expensive

---------------------------------------------------------

LARGE STRINGS:
Increase memory allocation cost

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. LARGE INPUT DOS
---------------------------------------------------------

Huge strings may:
- consume excessive gas
- increase memory usage
- create DOS conditions

---------------------------------------------------------
2. UNNECESSARY COPYING
---------------------------------------------------------

Using memory instead of calldata
may waste gas.

---------------------------------------------------------
3. STORAGE COSTS
---------------------------------------------------------

Storing large strings permanently
is expensive.

---------------------------------------------------------
4. ENCODING RISKS
---------------------------------------------------------

Auditors inspect:
- string encoding assumptions
- hashing logic
- comparison logic

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker submits massive string input.

Result:
- excessive memory allocation
- gas exhaustion
- transaction failure

---------------------------------------------------------

ANOTHER RISK

Protocol stores unbounded strings permanently.

Result:
storage bloat and expensive execution.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Accept two memory strings
2. Concatenate them
3. Return combined string

BONUS:
Compare:
memory vs calldata string gas usage

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Strings are dynamic types
- Dynamic types require data location
- memory strings are temporary
- Storage strings persist permanently
- Memory cleared after execution
- Large strings increase gas usage
- Dynamic data commonly uses memory
- Storage writes are expensive
- calldata may be cheaper for inputs
- Auditors inspect dynamic memory carefully

=========================================================
*/
/*
/*
AUDIT REPORT

Title: Unbounded Dynamic Memory String Input May Lead to Gas Exhaustion

Severity: Low

Reason:
The original contract accepts user-controlled dynamic strings
without validating input length.

Very large strings may consume excessive memory and gas,
potentially causing transaction failure or denial-of-service
conditions.

---------------------------------------------------------
Location
---------------------------------------------------------

Contract: MemoryStringExampleVul

Functions:
- saveName()
- getWelcomeMessage()
- compareStrings()

---------------------------------------------------------
Vulnerability Description
---------------------------------------------------------

The contract processes dynamic memory strings such as:

    string memory _name

Strings are variable-sized data types.

Because no input length validation exists,
attackers may provide extremely large strings.

Large memory allocation may increase:
- gas usage
- execution cost
- memory expansion cost

This can reduce scalability and create
potential denial-of-service conditions.

---------------------------------------------------------
Impact
---------------------------------------------------------

- Excessive gas consumption
- Transaction failure
- Increased memory allocation cost
- Reduced scalability
- Potential DOS conditions

---------------------------------------------------------
Proof of Concept
---------------------------------------------------------

1. Deploy contract

2. Call:
    saveName("Alice")

Expected:
    storedName = "Alice"

3. Call:
    getWelcomeMessage("Bob")

Expected:
    "Bob"

4. Call:
    compareStrings("Hello","World")

Expected:
    "Hello", "World"

5. Submit extremely large string input

Observation:
- Gas usage increases heavily
- Memory expansion cost increases
- Transaction may fail due to gas exhaustion

---------------------------------------------------------
Root Cause
---------------------------------------------------------

- Dynamic strings stored in memory
- No maximum length validation
- User-controlled unbounded input
- Expensive memory allocation possible

---------------------------------------------------------
Recommendation
---------------------------------------------------------

Restrict maximum string length before processing.

Example:

    require(bytes(_name).length <= 100, "String too large");

Additionally, calldata may be preferred
for read-only external inputs to reduce gas usage.

Example:

    function getWelcomeMessage(
        string calldata _name
    )
        external
        pure
        returns (string memory)
*/
// patched code 
/*
contract MemoryStringExample {

    function accepttwoMemStrings(string memory _string1,string memory _string2)public pure returns (string memory){
        require(bytes(_string1).length <= 100);
        require(bytes(_string2).length <= 100);
        string memory res=string.concat(_string1," ",_string2);
        return (res);
    }
}
*/
contract MemoryStringExampleVul {
    string public storedName;
    function saveName(string memory _name) public {
        storedName = _name;
    }
    // Accept two memory strings and concatenate them
    function combineStrings(
        string memory _first,
        string memory _second
    )
    public 
    pure 
    returns (string memory)
    {
        return string(
            abi.encodePacked(_first, _second)
        );
    }

}