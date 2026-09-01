// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract CounterV1 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    uint256 public count;

    function initialize(uint256 _count) public initializer {
        __Ownable_init(msg.sender);

        count = _count;
    }

    function increment() public {
        count++;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}