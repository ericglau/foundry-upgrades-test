// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Options {
  bool public usePlatformDeploy;

  function setUsePlatformDeploy(bool _usePlatformDeploy) external {
    usePlatformDeploy = _usePlatformDeploy;
  }
}