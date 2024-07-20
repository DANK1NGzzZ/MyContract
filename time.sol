// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Time{
    uint256 public Now;

    function nowTime() public {
        Now = block.timestamp;
    }
}