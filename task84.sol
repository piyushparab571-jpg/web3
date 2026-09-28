// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: selfdestruct forces ETH into contract
CONCEPT: Forced balance behavior
=========================================================

OBJECTIVE

- Understand how selfdestruct can send ETH to any address
- Learn that ETH can be forced into contracts without payable functions
- Observe balance change without fallback/receive
- Learn historical + modern Ethereum behavior

=========================================================
CORE IDEA
=========================================================

selfdestruct(target) → sends ALL contract ETH to target

IMPORTANT:
No fallback() or receive() is required.

=========================================================
FORCED ETH CONTRACT (TARGET)
=========================================================
*/
/*
contract VictimContract {

    /*
        This contract CANNOT reject ETH sent via selfdestruct
    

    uint256 public balanceTracker;

    function update() external payable {
        balanceTracker += msg.value;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

/*
=========================================================
ATTACK CONTRACT USING selfdestruct
=========================================================


contract ForceEtherSender {

    /*
    =====================================================
    FORCE ETH INTO TARGET
    =====================================================
    

    function forceSend(address payable target) external payable {

        /*
            Step 1:
            Contract receives ETH
        

        /*
            Step 2:
            selfdestruct sends ETH to target
        

        selfdestruct(target);
    }
}
*/
/*
=========================================================
EXECUTION FLOW
=========================================================

STEP 1:
Deploy VictimContract

STEP 2:
Deploy ForceEtherSender

STEP 3:
Call:

forceSend(VictimContract, 5 ether)

=========================================================

STEP-BY-STEP RESULT
=========================================================

1. ForceEtherSender holds 5 ETH
2. selfdestruct executed
3. ALL ETH transferred to VictimContract
4. ForceEtherSender is destroyed

=========================================================
IMPORTANT OBSERVATION
=========================================================

VictimContract receives ETH:

- WITHOUT calling receive()
- WITHOUT calling fallback()
- WITHOUT user interaction

=========================================================
STATE IMPACT

address(victim).balance increases

BUT:

balanceTracker DOES NOT update automatically

=========================================================
WHY THIS IS IMPORTANT

Contracts cannot block selfdestruct ETH transfers.

=========================================================
REAL SECURITY IMPLICATIONS

This behavior affects:

- DAO accounting systems
- invariant checks
- balance-based logic
- reward calculations

=========================================================
AUDITOR INSIGHT

Auditors check:

✔ Can contract receive ETH unexpectedly?
✔ Does logic rely on msg.value only?
✔ Are balance assumptions trusted?
✔ Are invariants based on address(this).balance?

=========================================================
MODERN NOTE (IMPORTANT)

In newer Ethereum upgrades:
- selfdestruct behavior is being restricted
- but legacy behavior still matters for audits

=========================================================
COMMON BUGS CAUSED

- stuck accounting mismatches
- reward inflation/deflation bugs
- incorrect total supply assumptions
- invariant breakage in DeFi protocols

=========================================================
KEY TAKEAWAYS

- selfdestruct bypasses receive/fallback
- ETH can be forced into any contract
- balance != accounting state
- protocols must not fully trust address.balance
- forced ETH breaks assumptions in DeFi systems

=========================================================
*/
/*
    PRACTICAL: Forced ETH using selfdestruct
    CONCEPT: ETH can reach a contract without
             calling receive() or fallback()
*/

// =====================================================
// VICTIM CONTRACT
// =====================================================

contract VictimContract {

    uint256 public balanceTracker;

    // Normal way of sending ETH to this contract
    function update() external payable {
        balanceTracker += msg.value;
    }

    // Actual ETH balance of this contract
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}


// =====================================================
// FORCE ETH SENDER
// =====================================================

contract ForceEtherSender {

    // Receive ETH normally
    receive() external payable {}

    /*
        Send all ETH held by this contract
        to the target address.
    */
    function forceSend(address payable target) external {
        selfdestruct(target);
    }
}
