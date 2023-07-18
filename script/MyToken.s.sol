// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Script.sol";
import "../src/MyToken.sol";
import "../src/MyTokenV2.sol";
import "@openzeppelin/foundry-upgrades/Upgrades.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract MyTokenScript is Script {
  function setUp() public {}

  function run() public {

    console.log('MSG sender is %s', msg.sender);

    vm.broadcast();
    MyToken instance = new MyToken();
    console.log("Contract deployed to %s", address(instance));


    
    // Direct
    // ERC1967Proxy proxy = new ERC1967Proxy(address(instance), abi.encodeWithSelector(MyToken.initialize.selector, "hello"));
    
    // UUPS
    vm.broadcast();
    Proxy proxy = Upgrades.deployUUPSProxy(address(instance), abi.encodeCall(MyToken.initialize, ("hello", msg.sender)));

    // Transparent
    // Proxy proxy = Upgrades.deployTransparentProxy(address(instance), msg.sender, abi.encodeCall(MyToken.initialize, ("hello", msg.sender)));
    
    // Beacon
    // IBeacon beacon = Upgrades.deployBeacon(address(instance), msg.sender);
    // Proxy proxy = Upgrades.deployBeaconProxy(address(beacon), abi.encodeCall(MyToken.initialize, ("hello", msg.sender)));

    MyToken p2 = MyToken(address(proxy));

    console.log("Contract name: %s", p2.name());
    console.log("greeting: %s", p2.greeting());
    console.log("owner: %s", p2.owner());
    
    vm.setEnv("myenv", "abc");
    console.log("Getting env %s", vm.envString("myenv"));


    MyTokenV2 v2 = new MyTokenV2();

    // ITransparentUpgradeableProxy(address(proxy)).upgradeToAndCall(address(v2), abi.encodeCall(MyTokenV2.resetGreeting, ()));

    Upgrades.upgradeProxy(address(proxy), address(v2), msg.sender, abi.encodeCall(MyTokenV2.resetGreeting, ()));
    console.log("upgraded greeting: %s", p2.greeting());

  }
}
