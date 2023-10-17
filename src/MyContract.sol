// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract MyContract is Initializable, ERC20Upgradeable, OwnableUpgradeable, UUPSUpgradeable {
    string public greeting;
    uint256 public immutable immutableVar;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(uint256 _immutableVar) {
        immutableVar = _immutableVar;
        // _disableInitializers();
    }

    function initialize(string memory _greeting, address initialOwner) initializer public {
        __ERC20_init("MyToken", "MTK");
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        greeting = _greeting;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function resetGreeting() public {
        greeting = "resetted";
    }
}
