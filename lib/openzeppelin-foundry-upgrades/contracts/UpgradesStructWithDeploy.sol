// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/proxy/Proxy.sol";

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

import "forge-std/Vm.sol";
import {console} from "forge-std/Console.sol";

library Upgrades {
  address constant CHEATCODE_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;

  struct Options {
    string apiKey;
    string apiSecret;
    bool usePlatformDeploy;
  }

  // Use Options
  // function deployUUPSProxy(address impl, bytes memory data, Options opts) internal returns (ERC1967Proxy) {
  //   if (opts.usePlatformDeploy()) {
  //     console.log("Using platform for deployUUPSProxy");

  //     // TODO call a platform command to deploy
  //     string[] memory inputs = new string[](3);
  //     inputs[0] = "echo";
  //     inputs[1] = "-n";
  //     inputs[2] = "0x123";

  //     bytes memory res = Vm(CHEATCODE_ADDRESS).ffi(inputs);
  //     console.log("res: %s", string(res));
  //   }
  //   // TODO else
  //   return new ERC1967Proxy(impl, data);
  // }


  function validateImplementation(string memory contractName) internal {
    // TODO
    // Enhance upgrades core to support passing in a specific contract name to validate, and filter results for that contract only
      string[] memory inputs = new string[](3);
      inputs[0] = "npx";
      inputs[1] = "@openzeppelin/upgrades-core@latest";
      inputs[2] = "validate";
      // TODO pass in validation options from environment variables
      // TODO customize build info dir based on foundry.toml (if not default)

      bytes memory res = Vm(CHEATCODE_ADDRESS).ffi(inputs);
      console.log("res: %s", string(res));

  }

  function deployImplementation(string memory contractName) internal returns (address) {
    validateImplementation(contractName);

    bytes memory code = Vm(CHEATCODE_ADDRESS).getCode(contractName);
    return deployFromBytecode(code);
  }

  function deployFromBytecode(bytes memory bytecode) private returns (address) {
        address addr;
        assembly {
            addr := create(0, add(bytecode, 32), mload(bytecode))
        }
        return addr;
   }

  // NOTE: The challenge with deploying with an implementation contract name is determining whether it was already deployed before.
  // Even if we use the network manifest, the manifest must only be recorded if the user is actually broadcasting to the network,
  // but these broadcasts happen at the end of a simulation (which may fail) or can be done manually.

  // Consider: support passing in a contract name or impl address. If contract name, document clearly that it will always be redeployed
  // If impl address, it will always be used as is (and the user should have deployed it using `deployImplementation` or verified it for upgrade safety beforehand)

  function equals(string memory a, string memory b) internal pure returns (bool) {
    return keccak256(bytes(a)) == keccak256(bytes(b));
  }

  // Use env variable for options
  function deployUUPSProxy(string memory contractName, bytes memory data, Options memory opts) internal returns (ERC1967Proxy) {
    address impl = deployImplementation(contractName);

    Vm vm = Vm(CHEATCODE_ADDRESS);

    if (opts.usePlatformDeploy) {
      console.log("STRUCTs: Using platform for deployUUPSProxy");

      // TODO call a platform command to deploy
      string[] memory inputs = new string[](3);
      inputs[0] = "echo";
      inputs[1] = "-n";
      inputs[2] = "0x123";

      bytes memory res = vm.ffi(inputs);
      console.log("res: %s", string(res));
    }
    // TODO else
    return new ERC1967Proxy(impl, data);
  }

  function deployTransparentProxy(address impl, address initialOwner, bytes memory data) internal returns (TransparentUpgradeableProxy) {
    return new TransparentUpgradeableProxy(impl, initialOwner, data);
  }

  function deployBeacon(address impl, address initialOwner) internal returns (IBeacon) {
    return new UpgradeableBeacon(impl, initialOwner);
  }

  function deployBeaconProxy(address beacon, bytes memory data) internal returns (BeaconProxy) {
    return new BeaconProxy(beacon, data);
  }

  function upgradeProxy(address proxy, address newImpl, address owner, bytes memory data) internal broadcast(owner) {
    Vm vm = Vm(CHEATCODE_ADDRESS);

    bytes32 adminSlot = vm.load(proxy, ERC1967Utils.ADMIN_SLOT);
    if (adminSlot == bytes32(0)) {
      // No admin contract: upgrade directly using interface
      ITransparentUpgradeableProxy(proxy).upgradeToAndCall(newImpl, data);
    } else {
      ProxyAdmin admin = ProxyAdmin(address(uint160(uint256(adminSlot))));
      admin.upgradeAndCall(ITransparentUpgradeableProxy(proxy), newImpl, data);
    }
  }

  function upgradeBeacon(address beacon, address newImpl, address owner) internal broadcast(owner) {
    UpgradeableBeacon(beacon).upgradeTo(newImpl);
  }

  // prepareUpgrade is not needed if user deploys implementations directly,
  // but consider it if we want to automatically perform safety checks

  function getImplementationAddress(address proxy) internal view returns (address) {
    Vm vm = Vm(CHEATCODE_ADDRESS);

    bytes32 implSlot = vm.load(proxy, ERC1967Utils.IMPLEMENTATION_SLOT);
    return address(uint160(uint256(implSlot)));
  }

  modifier broadcast(address deployer) {
    Vm vm = Vm(CHEATCODE_ADDRESS);

    bool wasBroadcasting = false;
    try vm.stopBroadcast() {
      wasBroadcasting = true;
    } catch {
      // ignore
    }

    vm.startBroadcast(deployer);
    _;
    vm.stopBroadcast();
    
    if (wasBroadcasting) {
      vm.startBroadcast(msg.sender);
    }
  }
}