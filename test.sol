// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract Test {



    function test() external view  returns (uint16){
               return uint16(uint160(tx.origin));
               
    }
      function test2() external view   returns (uint32){
                return uint32(uint64(this.test()));
    }
     
       // require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
       // require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
       // require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
    
    }