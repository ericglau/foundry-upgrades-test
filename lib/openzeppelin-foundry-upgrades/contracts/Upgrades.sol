// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/proxy/Proxy.sol";

import "./Options.sol";

library Upgrades {
  function deployProxy(address impl, bytes memory data, Options opts) public returns (Proxy) {
    if (opts.kind() == Options.Kind.UUPS) {
      return new ERC1967Proxy(impl, data);
    } else if (opts.kind() == Options.Kind.Transparent) {
      return new TransparentUpgradeableProxy(impl, data);
    } else {
      revert("Unknown proxy kind");
    }
  }
}