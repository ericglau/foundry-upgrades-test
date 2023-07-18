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

    vm.startBroadcast();
    MyToken v1 = new MyToken();
    console.log("Impl: %s", address(v1));
    
    // Direct
    // ERC1967Proxy proxy = new ERC1967Proxy(address(instance), abi.encodeWithSelector(MyToken.initialize.selector, "hello"));
    
    // UUPS
    Proxy proxy = Upgrades.deployUUPSProxy(address(v1), abi.encodeCall(MyToken.initialize, ("hello", msg.sender)));

    // Transparent
    // Proxy proxy = Upgrades.deployTransparentProxy(address(instance), msg.sender, abi.encodeCall(MyToken.initialize, ("hello", msg.sender)));
    
    // Beacon
    // IBeacon beacon = Upgrades.deployBeacon(address(instance), msg.sender);
    // Proxy proxy = Upgrades.deployBeaconProxy(address(beacon), abi.encodeCall(MyToken.initialize, ("hello", msg.sender)));

    MyToken instance = MyToken(address(proxy));

    console.log("Proxy: %s", address(proxy));
    console.log("Contract name: %s", instance.name());
    console.log("greeting: %s", instance.greeting());
    console.log("owner: %s", instance.owner());
    
    MyTokenV2 v2 = new MyTokenV2();
    console.log("Impl V2: %s", address(v2));

    console.log("Proxy impl address before upgrade %s", Upgrades.getImplementationAddress(address(proxy)));

    // ITransparentUpgradeableProxy(address(proxy)).upgradeToAndCall(address(v2), abi.encodeCall(MyTokenV2.resetGreeting, ()));
    Upgrades.upgradeProxy(address(proxy), address(v2), msg.sender, abi.encodeCall(MyTokenV2.resetGreeting, ()));

    console.log("upgraded greeting: %s", instance.greeting());

    console.log("Proxy impl address after upgrade %s", Upgrades.getImplementationAddress(address(proxy)));

    vm.stopBroadcast();
  }
}
