// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Store array values
CONCEPT: Sequential storage
=========================================================

OBJECTIVE

- Learn how arrays store sequential data
- Understand dynamic array behavior
- Learn how array values persist in storage
- Understand array-related gas and security concerns

---------------------------------------------------------
WHAT IS AN ARRAY?
---------------------------------------------------------

An array stores multiple values
of the same type sequentially.

Example:

[10, 20, 30]

Each value has an index.

---------------------------------------------------------
ARRAY INDEXING
---------------------------------------------------------

Index starts from 0.

Example:

numbers[0] => 10
numbers[1] => 20
numbers[2] => 30

---------------------------------------------------------
REAL-WORLD USES
---------------------------------------------------------

Arrays are used in:

- user lists
- NFT collections
- voting records
- transaction history
- whitelist systems
- staking participant lists

---------------------------------------------------------
IMPORTANT CONCEPT
---------------------------------------------------------

Dynamic arrays grow automatically.

New values are added sequentially
in blockchain storage.

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors check:

- Can arrays grow infinitely?
- Is iteration gas-safe?
- Can attacker spam storage?
- Are index checks missing?
- Can array operations DOS the contract?

=========================================================
*/
/*
contract ArrayStorageVul {

    uint256[] public numbers;

    function addNumber(uint256 _number) public {
        numbers.push(_number);
    }

    function getNumber(uint256 _index)
        public
        view
        returns (uint256)
    {
        return numbers[_index];
    }

    function getLength() public view returns (uint256) {
        return numbers.length;
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

INITIAL STATE

numbers = []

Empty dynamic array.

Length = 0

---------------------------------------------------------

CALL:
addNumber(10)

EVM ACTIONS:

1. Transaction reaches contract
2. _number arrives through calldata
3. Array length checked
4. New storage slot allocated
5. Value stored sequentially
6. Array length increases

RESULT:

numbers[0] = 10

length = 1

---------------------------------------------------------

CALL:
addNumber(50)

RESULT:

numbers[1] = 50

length = 2

---------------------------------------------------------

CALL:
addNumber(999)

RESULT:

numbers[2] = 999

length = 3

---------------------------------------------------------

CALL:
getNumber(1)

EVM:
1. Reads array index 1
2. Returns value 50

=========================================================
REMIX TESTING
=========================================================

NORMAL FLOW

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
getLength()

EXPECTED:
0

---------------------------------------------------------

STEP 3:
Call:
addNumber(10)

---------------------------------------------------------

STEP 4:
Call:
addNumber(20)

---------------------------------------------------------

STEP 5:
Call:
addNumber(30)

---------------------------------------------------------

STEP 6:
Call:
getLength()

EXPECTED:
3

---------------------------------------------------------

STEP 7:
Call:
getNumber(0)

EXPECTED:
10

---------------------------------------------------------

STEP 8:
Call:
getNumber(2)

EXPECTED:
30

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Store zero

addNumber(0)

EXPECTED:
Stored successfully

---------------------------------------------------------

TEST:
Store very large uint256

EXPECTED:
Works correctly

---------------------------------------------------------

TEST:
Access invalid index

Call:
getNumber(999)

EXPECTED:
Transaction reverts

Reason:
Index out of bounds

=========================================================
IMPORTANT STORAGE UNDERSTANDING
=========================================================

ARRAY STORAGE BEHAVIOR

Dynamic arrays store values sequentially.

Example:

numbers[0] => slotA
numbers[1] => slotA + 1
numbers[2] => slotA + 2

---------------------------------------------------------

ARRAY LENGTH

Stored separately in storage.

Each push():
- stores value
- updates length

---------------------------------------------------------

GAS OBSERVATION

Larger arrays increase:
- storage cost
- iteration cost
- execution complexity

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. UNBOUNDED ARRAY GROWTH
---------------------------------------------------------

Current array can grow forever.

Risk:
Storage bloat

Attackers may spam values.

---------------------------------------------------------
2. LOOP DOS RISK
---------------------------------------------------------

Dangerous pattern:

for (...) {
    process entire array
}

Large arrays may:
- exceed gas limit
- make functions unusable

This is common DOS vulnerability.

---------------------------------------------------------
3. INDEX VALIDATION
---------------------------------------------------------

Accessing invalid indexes reverts.

Auditors check:
- proper bounds validation
- safe index usage

---------------------------------------------------------
4. STORAGE COSTS
---------------------------------------------------------

Arrays consume increasing storage.

Auditors inspect:
- unnecessary storage usage
- scalable design issues

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Attacker repeatedly calls:

addNumber(...)

Result:
- massive array growth
- increased storage costs
- potential DOS in loops

---------------------------------------------------------

REAL-WORLD ISSUE

Many protocols fail because:
- arrays become too large
- loops become impossible to execute

This creates permanent denial of service.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add removeLastNumber() function
2. Remove last element using pop()

BONUS:
Prevent removing from empty array.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Arrays store sequential values
- Dynamic arrays grow automatically
- Arrays persist in blockchain storage
- push() adds new values
- length tracks array size
- Invalid indexes cause reverts
- Large arrays increase gas costs
- Unbounded loops are dangerous
- Arrays can create DOS risks
- Auditors inspect scalability carefully

=========================================================
*/

/*
Audit Report

Title: Missing Empty Array Validation in removeLastNumber()

Severity: Medium
Because calling pop() on an empty array
causes transaction reversion.

Location:
Contract: ArrayStorage
Function: removeLastNumber()

Vulnerability Description:
The removeLastNumber() function directly calls:

numbers.pop();

without checking whether the array contains elements.

If the array is empty, Solidity automatically reverts
with an array underflow error.

This may cause unexpected transaction failures
and unstable contract behavior.

Impact:
Users can trigger unnecessary transaction reverts
by calling removeLastNumber() on an empty array.

If integrated into larger protocol logic,
this may:
- break execution flow
- waste gas
- interrupt dependent functions
- create denial-of-service conditions

Proof of Concept:
        1. Deploy contract

        2. Initial array state:
        numbers = []

        3. Call:
        removeLastNumber()

        4. Transaction reverts successfully

------------------------------------------------

Another example:

        1. Add one value:
        addNumber(10)

        2. Remove value:
        removeLastNumber()

        3. Array becomes empty again

        4. Call:
        removeLastNumber()

        5. Transaction reverts

Root Cause:
The function does not validate array length
before removing the last element.

Vulnerable logic:

numbers.pop();

No require() statement checks:

numbers.length > 0

Recommendation:
Validate array length before calling pop().

Example:

require(
    numbers.length > 0,
    "Array is empty"
);

numbers.pop();

*/
// patched code 
/*
contract ArrayStorage {

    uint256[] public numbers;

    function addNumber(uint256 _number) public {
        numbers.push(_number);
    }

    function removeLastNumber()public {
        require(numbers.length>0,"Array is Empty");
        numbers.pop();
    }

    function getNumber(uint256 _index)public view returns (uint256){
        return numbers[_index];
    }

    function getLength() public view returns (uint256) {
        return numbers.length;
    }
}
*/
contract ArrayStorage {
    uint256[] public numbers;
    function addNumber(uint256 _number) public {
        numbers.push(_number);
    }
    function removeLastNumber() public {
        require(numbers.length > 0, "Array is empty");
        numbers.pop();
    }
    function getNumber(uint256 _index) public view returns (uint256) {
        return numbers[_index];
    }
    function getLength() public view returns (uint256) {
        return numbers.length;
    }
}