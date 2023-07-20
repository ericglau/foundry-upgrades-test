// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Script.sol";
import "../src/MyToken.sol";
import "../src/MyTokenV2.sol";
import {Upgrades} from "@openzeppelin/foundry-upgrades/Upgrades.sol";
import "@openzeppelin/foundry-upgrades/Options.sol";

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract MyTokenScript is Script {
  function setUp() public {}

  function run() public {

    bytes memory code = vm.getCode('MyToken.sol');
    address v1 = deployFromBytecode(code);

    // The above is equivalent to:
    // address v1 = deployFromBytecode(type(MyToken).creationCode);

    ERC1967Proxy proxy = Upgrades.deployUUPSProxy(address(v1), abi.encodeCall(MyToken.initialize, ("hello", msg.sender)));


    MyToken instance = MyToken(address(proxy));

    console.log("Proxy: %s", address(proxy));

    console.log("name: %s", instance.name());
    console.log("greeting: %s", instance.greeting());
    console.log("owner: %s", instance.owner());

  }

  function deployFromBytecode(bytes memory bytecode) public returns (address) {
        address child;
        assembly {
            child := create(0, add(bytecode, 32), mload(bytecode))
        }
        return child;
   }
}
