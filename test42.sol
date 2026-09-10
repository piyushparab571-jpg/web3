// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Call internal function
CONCEPT: Internal flow
=========================================================

OBJECTIVE

- Learn how internal functions work
- Understand internal execution flow
- Learn function visibility behavior
- Understand how contracts organize logic internally

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Internal functions:

- can only be called inside contract
- cannot be called externally
- help modularize logic
- reduce code duplication

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Internal calls do NOT create:
external transactions.

Execution stays inside same contract context.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Most production contracts heavily use:

- internal helper functions
- internal validation
- internal accounting logic
- reusable internal modules

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Internal functions used in:

- ERC20 transfer logic
- staking calculations
- DeFi accounting
- reward systems
- governance modules
- validation helpers

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- internal call flow
- hidden state mutations
- access assumptions
- recursive risks
- inherited internal logic

=========================================================
*/
/*
contract InternalFunctionFlowVul {
    /*
        STORAGE VARIABLES
    
    mapping(address => uint256) public balances;

    uint256 public totalDeposits;
    /*
    =====================================================
    EXTERNAL ENTRY FUNCTION
    =====================================================
    
    function deposit(uint256 _amount)external{
        /*
            STEP 1:
            Validate input using internal function.
        
        _validateAmount(_amount);

        /*
            STEP 2:
            Update balance using internal function.
        
        _updateBalance(msg.sender,_amount);

        /*
            STEP 3:
            Update global state.
        
        totalDeposits += _amount;
    }

    /*
    =====================================================
    INTERNAL VALIDATION FUNCTION
    =====================================================
    

    function _validateAmount(uint256 _amount)internal pure {
        /*
            Internal require check.
        
        require(_amount > 0,"Amount must be > 0");
        require(_amount <= 100,"Amount too large");
    }

    /*
    =====================================================
    INTERNAL STATE UPDATE FUNCTION
    =====================================================
    

    function _updateBalance(address _user,uint256 _amount)internal{
        /*
          Internal storage update.
        
        balances[_user] += _amount;
    }

    /*
    =====================================================
    INTERNAL CALCULATION FUNCTION
    =====================================================
    

    function _calculateBonus(uint256 _amount)internal pure returns (uint256){
        /*
            Bonus = 10%
        
        return (_amount * 10) / 100;
    }

    /*
    =====================================================
    EXTERNAL FUNCTION USING INTERNAL HELPER
    =====================================================
    

    function depositWithBonus(uint256 _amount)external{
        /*
            Internal validation call.
        
        _validateAmount(_amount);
        /*
            Internal calculation.
        
        uint256 bonus =_calculateBonus(_amount);

        /*
            Internal balance update.
        
        _updateBalance( msg.sender, _amount + bonus);

        totalDeposits +=(_amount + bonus);
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

CALL:
deposit(50)

=========================================================

STEP 1:
External function executes.

---------------------------------------------------------

deposit(50)

---------------------------------------------------------

STEP 2:
Internal function called:

_validateAmount(50)

---------------------------------------------------------

REQUIRE CHECKS:

50 > 0 -> true

50 <= 100 -> true

---------------------------------------------------------

STEP 3:
Internal function returns.

Execution resumes in deposit().

---------------------------------------------------------

STEP 4:
Internal function called:

_updateBalance(Alice, 50)

---------------------------------------------------------

STORAGE UPDATE:

balances[Alice] += 50

---------------------------------------------------------

STEP 5:
totalDeposits += 50

---------------------------------------------------------

FINAL STATE:

balances[Alice] = 50

totalDeposits = 50

=========================================================
IMPORTANT INTERNAL FLOW
=========================================================

Execution NEVER leaves contract.

---------------------------------------------------------

NO external call occurs.

---------------------------------------------------------

NO new transaction created.

=========================================================
TRACE:
depositWithBonus(100)
=========================================================

---------------------------------------------------------
STEP 1
---------------------------------------------------------

_validateAmount(100)

Validation passes.

---------------------------------------------------------
STEP 2
---------------------------------------------------------

_calculateBonus(100)

RESULT:
10

---------------------------------------------------------
STEP 3
---------------------------------------------------------

_updateBalance(Alice, 110)

---------------------------------------------------------
FINAL STATE
---------------------------------------------------------

balances[Alice] += 110

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Call:
deposit(50)

---------------------------------------------------------

STEP 3:
Call:
balances(your_address)

EXPECTED:
50

---------------------------------------------------------

STEP 4:
Call:
totalDeposits()

EXPECTED:
50

---------------------------------------------------------

STEP 5:
Call:
depositWithBonus(100)

---------------------------------------------------------

STEP 6:
Call:
balances(your_address)

EXPECTED:
160

---------------------------------------------------------

OBSERVE:
100 + 10 bonus added

=========================================================
IMPORTANT INTERNAL FUNCTION UNDERSTANDING
=========================================================

internal functions:

- callable only inside contract
- callable by inherited contracts
- invisible externally

=========================================================
INTERNAL VS EXTERNAL
=========================================================

---------------------------------------------------------
INTERNAL
---------------------------------------------------------

- same contract context
- cheaper
- no ABI encoding
- no external call

---------------------------------------------------------
EXTERNAL
---------------------------------------------------------

- callable outside contract
- ABI encoding required
- external transaction possible

=========================================================
WHY INTERNAL FUNCTIONS ARE IMPORTANT
=========================================================

Benefits:

- reusable logic
- cleaner code
- easier auditing
- modular architecture
- reduced duplication

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. HIDDEN STATE CHANGES
---------------------------------------------------------

Internal functions may:
silently modify storage.

---------------------------------------------------------
2. INHERITANCE RISKS
---------------------------------------------------------

Child contracts can access:
internal functions.

---------------------------------------------------------
3. COMPLEX INTERNAL FLOW
---------------------------------------------------------

Deep internal call chains
make auditing harder.

---------------------------------------------------------
4. RECURSION RISK
---------------------------------------------------------

Internal recursive calls
may exhaust gas.

=========================================================
GAS OBSERVATION
=========================================================

Internal calls are:
cheaper than external calls.

---------------------------------------------------------

Reason:
No message call overhead.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- Which internal functions modify storage?
- Can inherited contracts abuse them?
- Is execution flow clear?
- Are validations centralized?
- Are internal assumptions safe?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Internal validation omitted
in one execution path.

Result:
logic bypass.

---------------------------------------------------------

ANOTHER RISK

Inherited contract overrides logic
unexpectedly.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. Internal call chains
2. Storage mutations
3. Validation flow
4. Reusable helper logic
5. Inheritance behavior

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Add internal withdraw helper
2. Add internal fee calculation
3. Add admin-only internal modifier logic

BONUS:
Create inherited child contract
using internal functions.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Internal functions stay inside contract
- Internal calls are cheaper than external calls
- Internal functions organize reusable logic
- Internal execution keeps same context
- Internal functions can modify storage
- Inherited contracts can access internal functions
- Auditors trace internal call chains carefully
- Modular architecture improves maintainability
- Hidden internal logic may create vulnerabilities
- Internal flow understanding is critical for auditing

=========================================================
*/

/*
=========================================================
AUDIT REPORT
=========================================================

Title: Missing Internal Withdraw Logic and Admin Control

Severity: Medium

Reason:
The vulnerable contract lacks internal withdrawal
handling, fee accounting, and admin-only internal
control mechanisms.

---------------------------------------------------------
Location
---------------------------------------------------------

Contract: InternalFunctionFlowVul

Affected Areas:

- No internal withdraw helper
- No internal fee calculation
- No admin-only internal logic
- No inherited internal usage model

---------------------------------------------------------
Vulnerability Description
---------------------------------------------------------

The vulnerable contract only supports deposits
and bonus deposits.

The contract does NOT implement:

1. Internal withdraw accounting
2. Fee deduction logic
3. Admin-only internal protection
4. Internal inheritance-based control flow

As a result:

- users cannot safely withdraw balances
- no protocol fee accounting exists
- sensitive administrative logic cannot
  be protected internally
- contract architecture lacks modular
  reusable internal security controls

---------------------------------------------------------
Impact
---------------------------------------------------------

The protocol architecture becomes incomplete
and insecure for production-like usage.

Potential risks include:

- inability to safely reduce balances
- inconsistent accounting logic
- lack of reusable internal access control
- future inheritance misuse
- duplicated unsafe logic in upgrades

If extended into real systems such as:

- staking systems
- DeFi vaults
- lending protocols
- reward systems

missing internal accounting helpers may
cause unsafe state mutations.

---------------------------------------------------------
Proof of Concept
---------------------------------------------------------

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
User deposits:

deposit(100)

STATE:

balances[user] = 100
totalDeposits = 100

---------------------------------------------------------

STEP 3:
Attempt withdrawal

Observation:

No withdraw functionality exists.

User funds cannot be reduced safely.

---------------------------------------------------------

STEP 4:
Attempt protocol fee accounting

Observation:

No fee calculation exists.

No protocol fee tracking exists.

---------------------------------------------------------

STEP 5:
Attempt admin-restricted logic

Observation:

No owner variable exists.

No internal admin validation exists.

Sensitive logic cannot be protected.

---------------------------------------------------------
Root Cause
---------------------------------------------------------

The vulnerable contract lacks:

- internal withdraw helper
- internal fee helper
- internal owner validation helper
- reusable inherited internal architecture

Internal modular security design
was not implemented.

---------------------------------------------------------
Recommendation
---------------------------------------------------------

Implement:

1. Internal withdraw helper
2. Internal fee calculation helper
3. Internal owner validation helper
4. Child contract inheritance using
   internal functions
*/

//patched code 
/*
contract InternalFunctionFlow {
    /*
        STORAGE VARIABLES
    
    mapping(address => uint256) public balances;
    address public owner;
    uint256 public totalDeposits;
    uint256 public protocolFees;

    constructor(){
        owner=msg.sender;
    }
    /*
    =====================================================
    EXTERNAL ENTRY FUNCTION
    =====================================================
    

    function deposit(uint256 _amount) external{
        /*
            STEP 1:
            Validate input using internal function.
        
        _validateAmount(_amount);

        /*
            STEP 2:
            Update balance using internal function.
    
        _updateBalance(msg.sender,_amount);

        /*
            STEP 3:
            Update global state.
        
        totalDeposits += _amount;
    }

    function withdraw(uint256 _amount) public{
        _withdrawInternal(msg.sender, _amount);
    }
    /*
    =====================================================
    INTERNAL VALIDATION FUNCTION
    =====================================================
    

    function _validateAmount(uint256 _amount)internal pure {
        /*
            Internal require check.
        
        require(_amount > 0,"Amount must be > 0");

        require(_amount <= 100,"Amount too large");
    }

    /*
    =====================================================
    INTERNAL STATE UPDATE FUNCTION
    =====================================================
    

    function _updateBalance(address _user,uint256 _amount)internal{
        /*
            Internal storage update.

        balances[_user] += _amount;
    }

    /*
    =====================================================
    INTERNAL CALCULATION FUNCTION
    =====================================================
    

    function _calculateBonus(uint256 _amount)internal pure returns (uint256){
        /*
            Bonus = 10%
        
        return (_amount * 10) / 100;
    }

    /*
    =====================================================
    EXTERNAL FUNCTION USING INTERNAL HELPER
    =====================================================
    

    function depositWithBonus(uint256 _amount)external{
        /*
            Internal validation call.
        
        _validateAmount(_amount);
        /*
            Internal calculation.
        
        uint256 bonus =_calculateBonus(_amount);

        /*
            Internal balance update.
        
        _updateBalance( msg.sender, _amount + bonus);

        totalDeposits +=(_amount + bonus);
    }
// Internal withdraw helper
    function _withdrawInternal(address _user,uint256 _amt)internal returns (uint256){
        require(balances[_user]>=_amt,"Insufficient balance");
        uint256 fee=_calcFee(_amt);
        uint256 finalAmt=_amt-fee;
         protocolFees += fee;
        balances[_user] -= _amt;
        totalDeposits -= _amt;
        return finalAmt;
    } 

    function _calcFee(uint256 _fee)internal pure returns (uint256){
        return (_fee*5)/100;
    }

    function _onlyOwner()internal view {
        require(msg.sender==owner,"Not owner");
    }

    function emergencyReset(address _user)external  {
        _onlyOwner();
        uint256 userBalance = balances[_user];
        totalDeposits -= userBalance;
        balances[_user]=0;
    }
}

contract childContract is InternalFunctionFlow {

    function claimReward(address _user)external {
        _onlyOwner();
        _updateBalance(_user, 25);
        totalDeposits +=25;
    }
}
*/
/*
contract InternalFunctionFlowVul {

    mapping(address => uint256) public balances;
    uint256 public totalDeposits;

    address public admin;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    function deposit(uint256 _amount) external {
        _validateAmount(_amount);
        _updateBalance(msg.sender, _amount);
        totalDeposits += _amount;
    }

    function _validateAmount(uint256 _amount)
        internal
        pure
    {
        require(_amount > 0, "Invalid amount");
        require(_amount <= 100, "Amount too large");
    }

    function _updateBalance(
        address _user,
        uint256 _amount
    )
        internal
    {
        balances[_user] += _amount;
    }

    // Internal withdraw helper
    function _withdraw(
        address _user,
        uint256 _amount
    )
        internal
    {
        require(balances[_user] >= _amount, "Insufficient balance");
        balances[_user] -= _amount;
        totalDeposits -= _amount;
    }

    // Internal fee calculation
    function _calculateFee(uint256 _amount)
        internal
        pure
        returns (uint256)
    {
        return (_amount * 2) / 100;
    }

    // Admin-only function using modifier
    function adminWithdraw(
        address _user,
        uint256 _amount
    )
        external
        onlyAdmin
    {
        _withdraw(_user, _amount);
    }
}


/*
=====================================================
INHERITED CHILD CONTRACT
=====================================================


contract ChildFlow is InternalFunctionFlowVul {

    function childDeposit(uint256 _amount)
        external
    {
        _validateAmount(_amount);

        uint256 fee = _calculateFee(_amount);

        _updateBalance(
            msg.sender,
            _amount - fee
        );

        totalDeposits += _amount - fee;
    }
}
```
*/