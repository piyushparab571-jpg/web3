// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Delete array item
CONCEPT: Sparse array behavior
=========================================================

OBJECTIVE

- Learn how delete works on arrays
- Understand sparse array creation
- Learn why delete does not shrink arrays
- Understand risks caused by empty slots

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Using:

delete array[index];

DOES NOT:
- remove index
- shift elements
- reduce array length

It ONLY resets value to default.

---------------------------------------------------------
EXAMPLE
---------------------------------------------------------

Before delete:

[5, 10, 15]

After:
delete numbers[1];

Result:

[5, 0, 15]

Length still = 3

---------------------------------------------------------
DEFAULT VALUES
---------------------------------------------------------

uint256 => 0
bool => false
address => address(0)

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Can sparse arrays break logic?
- Are deleted entries handled safely?
- Does protocol incorrectly count empty slots?
- Can attackers abuse gaps?
- Is array cleanup implemented correctly?

=========================================================
*/
/*
contract SparseArrayBehaviorVul {

    uint256[] public numbers;

    function addNumber(uint256 _number) public {
        numbers.push(_number);
    }

    function deleteItem(uint256 _index) public {
        delete numbers[_index];
    }

    function getArray()public view returns (uint256[] memory){
        return numbers;
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

---------------------------------------------------------

CALL:
addNumber(5)
addNumber(10)
addNumber(15)

ARRAY:

[5,10,15]

length = 3

---------------------------------------------------------

CALL:
deleteItem(1)

EVM ACTIONS:

1. EVM locates numbers[1]
2. Storage slot reset to default value
3. numbers[1] becomes 0

---------------------------------------------------------

FINAL ARRAY

[5,0,15]

IMPORTANT:
Length remains 3

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
addNumber(5)

---------------------------------------------------------

STEP 3:
Call:
addNumber(10)

---------------------------------------------------------

STEP 4:
Call:
addNumber(15)

---------------------------------------------------------

STEP 5:
Call:
getArray()

EXPECTED:
[5,10,15]

---------------------------------------------------------

STEP 6:
Call:
deleteItem(1)

---------------------------------------------------------

STEP 7:
Call:
getArray()

EXPECTED:
[5,0,15]

---------------------------------------------------------

STEP 8:
Call:
getLength()

EXPECTED:
3

OBSERVE:
Array size did not shrink.

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Delete first element

deleteItem(0)

EXPECTED:
First value becomes 0

---------------------------------------------------------

TEST:
Delete last element

deleteItem(2)

EXPECTED:
Last value becomes 0

---------------------------------------------------------

TEST:
Delete invalid index

deleteItem(999)

EXPECTED:
Transaction reverts

Reason:
Index out of bounds

---------------------------------------------------------

TEST:
Delete same index twice

EXPECTED:
No error

=========================================================
IMPORTANT STORAGE UNDERSTANDING
=========================================================

ARRAY STORAGE

Arrays store values sequentially.

Example:

slot0 => array length
slot1 => numbers[0]
slot2 => numbers[1]
slot3 => numbers[2]

---------------------------------------------------------

DELETE OPERATION

delete numbers[1];

ONLY resets value.

Storage layout remains same.

---------------------------------------------------------

IMPORTANT

delete does NOT:
- remove slot
- shift values
- reduce length

=========================================================
DELETE VS POP
=========================================================

---------------------------------------------------------
DELETE
---------------------------------------------------------

delete numbers[1];

Result:
[5,0,15]

length = 3

---------------------------------------------------------
POP
---------------------------------------------------------

numbers.pop();

Result:
[5,10]

length = 2

---------------------------------------------------------

pop() only removes LAST element.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. SPARSE ARRAY BUGS
---------------------------------------------------------

Sparse arrays may break:
- reward systems
- counting logic
- voting mechanisms
- iteration assumptions

---------------------------------------------------------
2. LOOP RISKS
---------------------------------------------------------

Loops may incorrectly process:
0 values as valid entries.

---------------------------------------------------------
3. STORAGE FRAGMENTATION
---------------------------------------------------------

Repeated delete operations create:
- fragmented storage
- inefficient arrays
- wasted gas

---------------------------------------------------------
4. BUSINESS LOGIC FAILURES
---------------------------------------------------------

If 0 is meaningful,
deleted entries may bypass validations.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Suppose array stores active stakers.

Attacker deletes entries repeatedly.

Result:
- empty gaps created
- reward logic breaks
- participant counting fails

---------------------------------------------------------

REAL-WORLD ISSUE

Sparse arrays have caused:
- governance bugs
- staking calculation errors
- incorrect payout distribution

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Item is removed completely
2. Elements shift left
3. Array length decreases

Example:

Before:
[5,10,15]

Remove index 1

After:
[5,15]

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- delete resets value to default
- delete does NOT remove array index
- delete does NOT reduce length
- Sparse arrays contain gaps
- Arrays remain sequential in storage
- pop() differs from delete
- Sparse arrays may break protocol logic
- Invalid indexes revert
- Auditors inspect cleanup logic carefully
- Storage fragmentation affects efficiency

=========================================================
*/

/*
/*
Audit Report

Title: Sparse Array Creation Due to delete on Array Index

Severity: Medium
Because deleting array indexes without shrinking
the array creates empty slots that may break
protocol logic and iteration behavior.

Location:
Contract: SparseArrayBehaviorVul
Function: deleteItem()

Vulnerability Description:
The deleteItem() function uses:

delete numbers[_index];

This resets only the selected value
to its default value (0) but does NOT:
- remove the index
- shift elements
- reduce array length

Example:

Before deletion:
[5,10,15]

After:
deleteItem(1)

Result:
[5,0,15]

Array length still remains 3.

This creates sparse arrays containing gaps,
which may cause:
- incorrect counting
- broken iteration logic
- invalid reward calculations
- unexpected zero values

Impact:
Attackers or users may create empty slots
inside the array structure.

If the array represented:
- staking participants
- reward recipients
- governance voters
- active users
- payout records

then sparse entries may:
- corrupt accounting
- break business logic
- bypass validations
- cause incorrect processing

Proof of Concept:

1. Deploy contract

2. Call:
   addNumber(5)

3. Call:
   addNumber(10)

4. Call:
   addNumber(15)

5. Call:
   getArray()

Result:
[5,10,15]

6. Call:
   deleteItem(1)

7. Call:
   getArray()

Result:
[5,0,15]

8. Call:
   getLength()

Result:
3

------------------------------------------------

Another example:

1. Repeated deletions performed

2. Final array becomes:

[0,15,0,40,0]

3. Loops may incorrectly process
   zero values as valid entries

Root Cause:
The delete keyword only resets
the value at the specified index.

Vulnerable logic:

delete numbers[_index];

The array length remains unchanged,
creating sparse array gaps.

Recommendation:
Shift elements left after deletion
and reduce array length using pop().

Example:

for (
    uint256 i = _index;
    i < numbers.length - 1;
    i++
) {
    numbers[i] = numbers[i + 1];
}

numbers.pop();
*/
/*
// patched code 
contract SparseArrayBehavior {

    uint256[] public numbers;

    function addNumber(uint256 _number) public {
        numbers.push(_number);
    }

    function deleteItem(uint256 _index) public {
        require(_index<numbers.length,"Invalid Index");
        for (uint256 i=_index;i<numbers.length-1;i++){ // Loop starts FROM deleted index and shifts all next values LEFT
            numbers[i]=numbers[i+1];   //replace value at current index with value from next index 
        }
        numbers.pop();
    }

    function getArray()public view returns (uint256[] memory){
        return numbers;
    }

    function getLength() public view returns (uint256) {
        return numbers.length;
    }
}
*/
contract SparseArrayBehavior {
    uint256[] public numbers;
    function addNumber(uint256 _number) public {
        numbers.push(_number);
    }
    function deleteItem(uint _index) public {
        require(_index < numbers.length, "Invalid Index");
        //Shift all elements after the index to the left
        for (uint i = _index; i < numbers.length - 1; i++) {
            numbers[i] = numbers[i + 1];
        }
        // Remove the last duplicate element
        numbers.pop();
    }
    function getArray()
    public
    view 
    returns (uint256[] memory)
    {
        return numbers;
    }
    function getLength()
    public 
    view 
    returns (uint256)
    {
        return numbers.length;
    }
}