// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    WARNING:
    This proxy is intentionally vulnerable.
    It is ONLY for demonstrating a storage collision.
*/

// Vulnerable proxy
contract BadProxy {
    // STORAGE SLOT 0
    address public implementation;

    constructor(address _implementation) {
        implementation = _implementation;
    }

    function upgrade(address newImplementation) external {
        implementation = newImplementation;
    }

    fallback() external payable {
        address impl = implementation;

        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(
                gas(),
                impl,
                0,
                calldatasize(),
                0,
                0
            )

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}


// Implementation contract
contract LogicV1 {

    // ALSO STORAGE SLOT 0
    address public owner;

    function setOwner(address _owner) external {
        owner = _owner;
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}