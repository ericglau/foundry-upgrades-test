// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Options {
  enum Kind {
    UUPS,
    Transparent,
    Beacon
  }

  Kind public kind;
}