// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "../src/MyToken.sol";
import "../src/MyTokenV2.sol";
import {Upgrades} from "@openzeppelin/foundry-upgrades/Upgrades.sol";
import {Options} from "@openzeppelin/foundry-upgrades/Options.sol";
import {Proxy} from "@openzeppelin/contracts/proxy/Proxy.sol";
import {IBeacon} from "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";

contract MyTokenTest is Test {
  MyToken public v1;

  function setUp() public {
    v1 = new MyToken();
  }

  function testUUPS() public {
    Proxy proxy = Upgrades.deployUUPSProxy(address(v1), abi.encodeCall(MyToken.initialize, ("hello", msg.sender)));
    MyToken instance = MyToken(address(proxy));

    assertEq(instance.name(), "MyToken");
    assertEq(instance.greeting(), "hello");
    assertEq(instance.owner(), msg.sender);

    MyTokenV2 v2 = new MyTokenV2();

    assertEq(Upgrades.getImplementationAddress(address(proxy)), address(v1));

    Upgrades.upgradeProxy(address(proxy), address(v2), msg.sender, abi.encodeCall(MyTokenV2.resetGreeting, ()));

    assertEq(instance.greeting(), "resetted");
    assertEq(Upgrades.getImplementationAddress(address(proxy)), address(v2));

  }

  function testTransparent() public {
    Proxy proxy = Upgrades.deployTransparentProxy(address(v1), msg.sender, abi.encodeCall(MyToken.initialize, ("hello", msg.sender)));
    MyToken instance = MyToken(address(proxy));

    assertEq(instance.name(), "MyToken");
    assertEq(instance.greeting(), "hello");
    assertEq(instance.owner(), msg.sender);

    MyTokenV2 v2 = new MyTokenV2();

    assertEq(Upgrades.getImplementationAddress(address(proxy)), address(v1));

    Upgrades.upgradeProxy(address(proxy), address(v2), msg.sender, abi.encodeCall(MyTokenV2.resetGreeting, ()));

    assertEq(instance.greeting(), "resetted");
    assertEq(Upgrades.getImplementationAddress(address(proxy)), address(v2));
  }

  function testBeacon() public {
    IBeacon beacon = Upgrades.deployBeacon(address(v1), msg.sender);
    Proxy proxy = Upgrades.deployBeaconProxy(address(beacon), abi.encodeCall(MyToken.initialize, ("hello", msg.sender)));
    MyToken instance = MyToken(address(proxy));

    assertEq(instance.name(), "MyToken");
    assertEq(instance.greeting(), "hello");
    assertEq(instance.owner(), msg.sender);

    MyTokenV2 v2 = new MyTokenV2();

    assertEq(beacon.implementation(), address(v1));

    Upgrades.upgradeBeacon(address(beacon), address(v2), msg.sender);

    MyTokenV2(address(instance)).resetGreeting();

    assertEq(instance.greeting(), "resetted");
    assertEq(beacon.implementation(), address(v2));
  }
}
