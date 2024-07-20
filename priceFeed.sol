// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
//0x73ff24Fc7820BB65c9ac77701194e2025Bd6ac0B
contract ChainlinkVRFDemo is VRFConsumerBaseV2 {
    bytes32 keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    uint64 s_subId; 
    uint16 requestConfirmations = 3;
    uint32 callbackGasLimit = 2_500_000;
    uint32 numWords = 3;
    uint256[] public s_randomWords;

    uint256 public requestId;
    address public owner;
    VRFCoordinatorV2Interface COORDINATOR;
    address vrtCoordinatorAddr = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;

    constructor(uint64 subId) VRFConsumerBaseV2(vrtCoordinatorAddr){
        COORDINATOR = VRFCoordinatorV2Interface(vrtCoordinatorAddr);
        s_subId = subId;
        owner = msg.sender;
    }

    function requestRandomWords() external {
        require(msg.sender == owner, "Only the contract owner can request random words");
        requestId =  COORDINATOR.requestRandomWords(
            keyHash,
            s_subId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        s_randomWords = randomWords;
        // You can add additional logic here based on your requirements
    }
}