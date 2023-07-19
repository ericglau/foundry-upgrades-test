// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library Options {
  // Option-style flags
  // bool public usePlatformDeploy;

  // function setUsePlatformDeploy(bool _usePlatformDeploy) external {
  //   usePlatformDeploy = _usePlatformDeploy;
  // }

  // OR

  // Constants for env vars

  // TODO capitalization convention? namespaces as openzeppelin and/or platform?
  string internal constant apiKey = "openzeppelin.apiKey";
  string internal constant apiSecret = "openzeppelin.apiSecret";
  string internal constant usePlatformDeploy = "openzeppelin.usePlatformDeploy";
}
