// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Script.sol";
import "../src/MyToken.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract MyTokenScript is Script {
  function setUp() public {}

  function run() public {
    vm.startBroadcast();
    MyToken instance = new MyToken();
    console.log("Contract deployed to %s", address(instance));

    // ERC1967Proxy proxy = new ERC1967Proxy(address(instance), abi.encodeWithSelector(MyToken.initialize.selector, "hello"));
    ERC1967Proxy proxy = new ERC1967Proxy(address(instance), abi.encodeCall(MyToken.initialize, "hello"));

    MyToken p2 = MyToken(address(proxy));

    console.log("Contract name: %s", p2.name());
    console.log("greeting: %s", p2.greeting());
    
    vm.setEnv("myenv", "abc");
    console.log("Getting env %s", vm.envString("myenv"));

    vm.stopBroadcast();
  }
}
