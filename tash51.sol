// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Call another contract
CONCEPT: Inter-contract communication
=========================================================

OBJECTIVE

- Learn how contracts call other contracts
- Understand inter-contract execution flow
- Learn external call behavior
- Understand cross-contract risks

---------------------------------------------------------
CORE IDEA
---------------------------------------------------------

Smart contracts can:
call functions in other contracts.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

Cross-contract calls create:
NEW execution context.

---------------------------------------------------------
WHY THIS MATTERS
---------------------------------------------------------

Most real protocols interact with:

- tokens
- vaults
- oracles
- DEXes
- lending protocols
- bridges

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Inter-contract communication used in:

- ERC20 transfers
- AMM swaps
- lending protocols
- NFT marketplaces
- staking systems
- governance execution

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- external call safety
- trust assumptions
- reentrancy risk
- return-value handling
- cross-contract state assumptions

=========================================================
CONTRACT 1:
TARGET CONTRACT
=========================================================
*/

contract BankVul {
    /*
        USER BALANCES
    */
    mapping(address => uint256) public balances;
    /*
    =====================================================
    DEPOSIT FUNCTION
    =====================================================
    */
    function deposit(uint256 _amount)external{
        /*
            Update storage.
        */
        balances[msg.sender] += _amount;
    }

    /*
    =====================================================
    READ BALANCE
    =====================================================
    */
    function getBalance( address _user)external view returns (uint256){
        return balances[_user];
    }
}

/*
=========================================================
CONTRACT 2:
CALLER CONTRACT
=========================================================
*/
contract InterContractCallerVul {
    /*
        STORE TARGET CONTRACT ADDRESS
    */
    address public bankAddress;
    /*
        LAST READ VALUE
    */
    uint256 public lastBalance;

    /*
        CONSTRUCTOR
        Save target contract address.
    */
    constructor(
        address _bankAddress
    )
    {
        bankAddress = _bankAddress;
    }
    /*
    =====================================================
    CALL DEPOSIT FUNCTION
    =====================================================
    */

    function callDeposit(uint256 _amount)external{
        /*
            Create contract reference.

            Tells Solidity:
            "bankAddress is a Bank contract"
        */
        BankVul bank = BankVul(bankAddress);
        /*
            EXTERNAL CONTRACT CALL

            Execution jumps into:
            Bank.deposit()
        */
        bank.deposit(_amount);
    }

    /*
    =====================================================
    READ ANOTHER CONTRACT STATE
    =====================================================
    */

    function readBalance( address _user)external{
        /*
            Create contract reference.
        */
        BankVul bank = BankVul(bankAddress);

        /*
            External view call.

            Reads state from another contract.
        */
        uint256 balance = bank.getBalance(_user);

        /*
            Save locally.
        */
        lastBalance = balance;
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy Bank contract.

---------------------------------------------------------

Bank deployed at:

0xABC...

=========================================================
STEP 2:
Deploy InterContractCaller

constructor input:
0xABC...

---------------------------------------------------------

Caller now knows:
Bank contract address.

=========================================================
TRACE:
callDeposit(100)
=========================================================

STEP 1:
User calls:

InterContractCaller.callDeposit(100)

---------------------------------------------------------

STEP 2:
Contract reference created:

Bank bank = Bank(bankAddress)

---------------------------------------------------------

STEP 3:
External contract call occurs:

bank.deposit(100)

---------------------------------------------------------

EXECUTION CONTEXT SWITCHES

---------------------------------------------------------

Execution enters:
Bank.deposit()

=========================================================
INSIDE BANK CONTRACT
=========================================================

balances[msg.sender] += 100

---------------------------------------------------------

IMPORTANT:

msg.sender is:
InterContractCaller contract

NOT original user.

=========================================================
VERY IMPORTANT msg.sender UNDERSTANDING
=========================================================

Cross-contract call changes:

msg.sender

---------------------------------------------------------

FLOW:

User
  ->
Caller Contract
  ->
Bank Contract

---------------------------------------------------------

Inside Bank:

msg.sender =
Caller contract address

=========================================================
READ FLOW TRACE
=========================================================

CALL:
readBalance(user)

=========================================================

STEP 1:
Caller contract executes.

---------------------------------------------------------

STEP 2:
External view call:

bank.getBalance(user)

---------------------------------------------------------

STEP 3:
Execution enters Bank contract.

---------------------------------------------------------

STEP 4:
Balance returned.

---------------------------------------------------------

STEP 5:
Caller stores result:

lastBalance = returned balance

=========================================================
REMIX TESTING
=========================================================

STEP 1:
Deploy Bank contract

---------------------------------------------------------

STEP 2:
Copy Bank address

---------------------------------------------------------

STEP 3:
Deploy InterContractCaller

Constructor input:
Bank address

---------------------------------------------------------

STEP 4:
Call:
callDeposit(100)

---------------------------------------------------------

STEP 5:
Open Bank contract

---------------------------------------------------------

STEP 6:
Call:
balances(caller_contract_address)

EXPECTED:
100

---------------------------------------------------------

IMPORTANT:
Balance stored for CALLER contract.

=========================================================
IMPORTANT CROSS-CONTRACT UNDERSTANDING
=========================================================

External calls create:

- new execution context
- new msg.sender
- possible reentrancy window
- trust assumptions

=========================================================
INTERFACE-LIKE BEHAVIOR
=========================================================

This line:

Bank(bankAddress)

means:

"Treat this address as Bank contract"

=========================================================
COMMON AUDIT RISKS
=========================================================

---------------------------------------------------------
1. REENTRANCY
---------------------------------------------------------

External contract may call back unexpectedly.

---------------------------------------------------------
2. TRUST ASSUMPTIONS
---------------------------------------------------------

Target contract may behave maliciously.

---------------------------------------------------------
3. RETURN VALUE IGNORED
---------------------------------------------------------

Dangerous if call fails silently.

---------------------------------------------------------
4. msg.sender CONFUSION
---------------------------------------------------------

Critical authentication mistakes possible.

=========================================================
VERY IMPORTANT SECURITY CONCEPT
=========================================================

External contract calls are:

UNTRUSTED INTERACTIONS

---------------------------------------------------------

Never assume:
target contract behaves safely.

=========================================================
GAS OBSERVATION
=========================================================

Cross-contract calls:
cost more gas.

---------------------------------------------------------

Reason:
context switching + external execution.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

Auditors ask:

- Which contracts are trusted?
- Can target contract reenter?
- Is msg.sender handled correctly?
- Are return values checked?
- Are external calls ordered safely?

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Malicious contract called externally.

---------------------------------------------------------

During execution:
it reenters vulnerable function.

---------------------------------------------------------

Result:
fund theft.

=========================================================
REAL AUDITOR PROCESS
=========================================================

Auditors trace:

1. Cross-contract execution flow
2. msg.sender changes
3. External interaction timing
4. State-update ordering
5. Reentrancy windows

=========================================================
MINI CHALLENGE
=========================================================

Modify system so that:

1. Add withdraw() function
2. Add external ETH transfer
3. Observe msg.sender changes
4. Add interface contract

BONUS:
Build simple token interaction.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- Contracts can call other contracts
- External calls create new execution context
- msg.sender changes during contract calls
- Cross-contract interactions are risky
- External calls may enable reentrancy
- Contract references treat addresses as contracts
- Return values must be checked carefully
- Auditors trace inter-contract execution carefully
- Trust assumptions are security critical
- Inter-contract communication powers DeFi systems

=========================================================
*/
/*
Audit Report

Title: msg.sender Confusion and Missing ETH Handling in Inter-Contract Communication

Severity: Medium

Reason:
Cross-contract calls change msg.sender execution context, causing deposits to be credited to the caller contract instead of the actual user.

Location:

Contract: BankVul
Function: deposit(uint256 _amount)

Contract: InterContractCallerVul
Function: callDeposit(uint256 _amount)

Vulnerability Description:

The InterContractCallerVul contract calls:
bank.deposit(_amount); inside callDeposit().
During this external contract call:
msg.sender inside BankVul becomes:
InterContractCallerVul
NOT the original user.

As a result:
balances[msg.sender] += _amount;
stores balances for the caller contract address instead of the real user address.

Additionally:
The deposit() function does not use payable or msg.value.
This creates fake accounting because balances increase without actual ETH being transferred.

Impact:

- User balances are incorrectly assigned
- Funds/accounting become inconsistent
- Contract tracks balances without receiving ETH
- Authentication assumptions using msg.sender may fail
- Inter-contract accounting becomes misleading

Proof of Concept:

        1. Deploy BankVul contract.
        2. Deploy InterContractCallerVul using BankVul address.
        3. User A calls:
            callDeposit(100)
        4. Open BankVul contract.
        5. Check balance of User A:
            balances(UserA)
        Result:
            0
        6. Check balance of InterContractCallerVul contract:
            balances(InterContractCallerAddress)
        Result:
            100
        7. No ETH was actually transferred to BankVul contract.

Root Cause:
The contract incorrectly assumes msg.sender remains the original external user during cross-contract calls.

In Solidity:

User
-> Caller Contract
-> Target Contract

Inside Target Contract:

msg.sender =Caller Contract Address

Additionally:
deposit() updates accounting without handling real ETH transfers.

Recommendation:

    1. Use payable functions with msg.value for real ETH deposits.
    2. Properly understand msg.sender changes during inter-contract calls.
    3. Use interfaces for safer external communication.
    4. Track original sender explicitly if required.

Example:

function deposit() external payable {
    balances[msg.sender] += msg.value;
}

*/

// patched code
/*
interface IBank {
    function deposit() external payable;
    function withdraw(uint256 _amount)external;

    function getBalance(address _user)external view returns(uint256);
}
contract Bank {
    /*
        USER BALANCES
    
    mapping(address => uint256) public balances;
    /*
    =====================================================
    DEPOSIT FUNCTION
    =====================================================
    
    function deposit()external payable {
        /*
            Update storage.
        
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount)external {
        require(balances[msg.sender]>=_amount,"Insufficient balance");
        balances[msg.sender] -= _amount;
        (bool success,)=payable(msg.sender).call{value:_amount}("");
        require(success,"ETH transfer failed");
    }

    /*
    =====================================================
    READ BALANCE
    =====================================================
    
    function getBalance( address _user)external view returns (uint256){
        return balances[_user];
    }
     /*
        Allow contract to receive ETH
    
    receive() external payable {}
}
*/
/*
=========================================================
CONTRACT 2:
CALLER CONTRACT
=========================================================
*/
/*
contract InterContractCaller {
    /*
        STORE TARGET CONTRACT ADDRESS
    
    address public bankAddress;
    /*
        LAST READ VALUE
    
    uint256 public lastBalance;

     address public lastSender;

    /*
        CONSTRUCTOR
        Save target contract address.
    
    constructor(
        address _bankAddress
    )
    {
        bankAddress = _bankAddress;
    }
    /*
    =====================================================
    CALL DEPOSIT FUNCTION
    =====================================================
    

    function callDeposit()external payable {
         lastSender = msg.sender;

        /*
            Create contract reference.

            Tells Solidity:
            "bankAddress is a Bank contract"
        
        IBank bank = IBank(bankAddress);
        /*
            EXTERNAL CONTRACT CALL

            Execution jumps into:
            Bank.deposit()
        
        bank.deposit{value:msg.value}();
    }

    function callWithdraw(uint256 _amount)external {
        IBank bank=IBank(bankAddress);
        bank.withdraw(_amount);
    }

    /*
    =====================================================
    READ ANOTHER CONTRACT STATE
    =====================================================
    

    function readBalance( address _user)external{
        /*
            Create contract reference.
        
        IBank bank = IBank(bankAddress);

        /*
            External view call.

            Reads state from another contract.
        
        uint256 balance = bank.getBalance(_user);

        /*
            Save locally.
    
        lastBalance = balance;
    }
    /*
        Receive ETH from Bank
    
    receive() external payable {}
}
*/