// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
//0xef05960ABf357C2469c9464089A88D64A30b78E8
//0x5922B8f171343dFFd65F646301e8568a78b05239
//0x8144cCcaa5A5b8527b76B85F5Fe197CE7388D59A
//0xD3eD2FA9C02c3b875642B3475b7E1Ac6EAFca8AB  最后一次完全体合约地址
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract MyToken is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Burnable,
    Ownable,
    VRFConsumerBaseV2
{
   
    uint256 public MAX_AMOUNT = 5; //5个NFT
    mapping(address => bool) public whiteList; //白名单账户
    bool public preMintWindow = false; //铸造窗口控制该变量确认普通账户和白名单铸造时间段
    bool public mintWindow = false;
    uint256 private _nextTokenId;

        //matadata
    string constant matadata_1 = "https://ipfs.filebase.io/ipfs/Qma5hHvoW5BstU5fFWA7YiRqm73tiLJZjSAiZC9kBJ5KTK";
    string constant matadata_5 = "https://ipfs.filebase.io/ipfs/QmeEp9K6k9a2doZM4ow9nK5KYhyug8U1zPAqBFRFx93HBP";
    string constant matadata_10 = "https://ipfs.filebase.io/ipfs/QmYGVhCsiothuNWH7zF48Zvk3nGk1PLjBLui5EpsrKT1vm";
    string constant matadata_20 = "https://ipfs.filebase.io/ipfs/QmTkNNk6Jo5d847Pm1QjRMG1L3MLPNF1rpzyQ4AVDDxQTs";
    string constant matadata_50 = "https://ipfs.filebase.io/ipfs/QmZHWBPhADvb1YaC2Az2WfgAv925BUSozghKxtyGN1HFXs";

    //for chainlink VRF
    VRFCoordinatorV2Interface COORDINATOR;

    uint64 s_subscriptionId;//订阅id
    uint256[] public requestIds;
    bytes32 keyHash =
        0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c; //公钥  sepolia测试网
    uint32 callbackGasLimit = 100000; //gas费
    uint16 requestConfirmations = 3; //3个区块确认
    uint32 numWords = 1;//1个随机数
    mapping(uint256 => uint256) reqIdToTokenId;


    constructor(address initialOwner,uint64 subId)
        ERC721("MyToken", "MTK")
        Ownable(initialOwner)
        VRFConsumerBaseV2(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625) //sepolia测试网
    {
        s_subscriptionId = subId;
        COORDINATOR = VRFCoordinatorV2Interface(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625);
    }

    //白名单账户进行铸造NFT
    function preMint() public payable {
        require(preMintWindow, "PreMint is not open yet!");
        require(msg.value == 0.001 ether, "The price of nft is 0.001 ether");
        require(whiteList[msg.sender], "you are not whiteList");
        require(balanceOf(msg.sender) < 1, "the address only mint 1!"); //该白名单最多只能铸造一个NFT(优惠)
        require(totalSupply() < MAX_AMOUNT, "This nft is sold out!");
         uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
        request(tokenId);
    }

    //普通账户进行铸造NFT
    function mint() public payable {
        require(mintWindow, "mint is not open yet!");
        require(msg.value == 0.005 ether, "The price of nft is 0.005 ether");
        require(totalSupply() < MAX_AMOUNT, "This nft is sold out!");
         uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
        request(tokenId);
    }

    //发送获取随机数请求
     function request(uint256 _tokenId)
        public   
        returns (uint256 requestId){
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        reqIdToTokenId[requestId] = _tokenId;
        return requestId;
    }

     function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        uint256 randomNumber = _randomWords[0] % 5;
        if (randomNumber == 0){
            _setTokenURI(reqIdToTokenId[_requestId],matadata_1);
        }else if(randomNumber == 1){
            _setTokenURI(reqIdToTokenId[_requestId],matadata_5);
        }else if(randomNumber == 2){
            _setTokenURI(reqIdToTokenId[_requestId],matadata_10);
        }else if(randomNumber == 3){
             _setTokenURI(reqIdToTokenId[_requestId],matadata_20);
        }else {
             _setTokenURI(reqIdToTokenId[_requestId],matadata_50);
        }
    }

    //设置白名单账户
    function addToWhiteList(address[] calldata addrs) public onlyOwner {
        for (uint256 i = 0; i < addrs.length; i++) {
            whiteList[addrs[i]] = true;
        }
    }

    //设置铸造窗口
    function setWindow(bool preMintOpen, bool mintOpen) public onlyOwner {
        preMintWindow = preMintOpen;
        mintWindow = mintOpen;
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
