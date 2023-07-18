// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/proxy/Proxy.sol";

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

import "./Options.sol";

import "forge-std/Vm.sol";

import {console as c2} from "forge-std/Console.sol";

library Upgrades {
  function deployUUPSProxy(address impl, bytes memory data) public returns (Proxy) {
    return new ERC1967Proxy(impl, data);
  }

  function deployTransparentProxy(address impl, address initialOwner, bytes memory data) public returns (Proxy) {
    return new TransparentUpgradeableProxy(impl, initialOwner, data);
  }

  function deployBeacon(address impl, address initialOwner) public returns (IBeacon) {
    return new UpgradeableBeacon(impl, initialOwner);
  }

  function deployBeaconProxy(address beacon, bytes memory data) public returns (Proxy) {
    return new BeaconProxy(beacon, data);
  }

  function upgradeProxy(address proxy, address newImpl, address owner, bytes memory data) public {
    // Cheatcode address
    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    bytes32 adminSlot = vm.load(proxy, ERC1967Utils.ADMIN_SLOT);
    if (adminSlot == bytes32(0)) {
      // No admin contract: use ITransparentUpgradeableProxy to get proxiable interface, and upgrade directly
      vm.broadcast(owner);
      ITransparentUpgradeableProxy(proxy).upgradeToAndCall(newImpl, data);
    } else {
      ProxyAdmin admin = ProxyAdmin(address(uint160(uint256(adminSlot))));
      vm.broadcast(owner);
      admin.upgradeAndCall(ITransparentUpgradeableProxy(proxy), newImpl, data);
    }
  }
}