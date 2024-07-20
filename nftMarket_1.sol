// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
//0xfADC49FD75f690e6F43757E6419972aFaBdF7D48
import"@openzeppelin/contracts/token/ERC721/IERC721.sol";
import"@openzeppelin/contracts/security/ReentrancyGuard.sol";

error NftMarketplace__PriceMustBeAboveZero();
error NftMarketplace__NotApprovedForMarketolace();
error NftMarketplace__AlreadyListed(address nftAddress, uint256 tokenId);
error NftMarketplace__NotOwner();
error NftMarketplace__NoListed(address nftAddress, uint256 tokenId);
error NftMarketplace__PriceNotMet(address nftAddress, uint256 tokenId,uint256 price);
error NftMarketplace__NoProceeds();
error NftMarketplace__TransferFailed();

contract NftMarketplace is ReentrancyGuard {
    struct Listing{
        uint256 price; //NFT价格
        address seller; //卖家
    }
//监听NFT
    event ItemListed(
        address indexed seller,
        address indexed  nftAddress,
        uint256 indexed  tokenId,
        uint256 price
    );

    event ItemBought(
        address indexed buyer,
        address indexed  nftAddress,
        uint256 indexed  tokenId,
        uint256 price
  );

     event ItemCanceled(
        address indexed seller,
        address indexed nftAddress, 
        uint256 indexed tokenId
         ); 
    //NFT contract address => NFT tokenId => Listing
    mapping(address => mapping(uint256 => Listing)) private s_listings;
    //Seller Address => Amount earned 卖家收益
    mapping(address => uint256) private s_proceeds;

    //验证NFT是否已经上架
    modifier notListed(address nftAddress, uint256 tokenId, address owner){
        Listing memory listing = s_listings[nftAddress][tokenId];
        if(listing.price > 0){
            revert NftMarketplace__AlreadyListed(nftAddress, tokenId);
        }
        _;
    }

    //确保NFT所有者才能上架
    modifier isOwner(address nftAddress, uint256 tokenId, address spender){
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if(spender != owner){
            revert NftMarketplace__NotOwner();
        }
        _;
    }

    //确认NFT已经上架
    modifier isListed(address nftAddress, uint256 tokenId){
        Listing memory listing = s_listings[nftAddress][tokenId];
        if(listing.price <= 0 ){
            revert NftMarketplace__NoListed(nftAddress, tokenId);
        }
        _;
    }

  //1.在市场列出NFTS售卖
  function listItem(address nftAddress, uint256 tokenId, uint256 price)
   external
   notListed( nftAddress,  tokenId, msg.sender)
   isOwner(nftAddress, tokenId, msg.sender)
    {

    if(price <= 0){
        revert NftMarketplace__PriceMustBeAboveZero();
    }
    //将NFT发送到该合约，让合约持有该NFT
    //NFT所有者仍然持有该NFT只是在该市场出售
    IERC721 nft = IERC721(nftAddress);
    if(nft.getApproved(tokenId) != address(this)){
        revert NftMarketplace__NotApprovedForMarketolace();
    }
    s_listings[nftAddress][tokenId] = Listing(price,msg.sender);//卖家将NFT上架市场列表
    emit ItemListed(msg.sender, nftAddress, tokenId, price);


  }
  //2.购买NFTS
  function buyItem(address nftAddress, uint256 tokenId) external payable
  isListed(nftAddress, tokenId)
   {
    Listing memory listedItem = s_listings[nftAddress][tokenId];
    //确认支付价格是否正确
    if(msg.value < listedItem.price){
        revert NftMarketplace__PriceNotMet(nftAddress, tokenId, listedItem.price);

    }
    //更新卖家收益
    s_proceeds[listedItem.seller] =  s_proceeds[listedItem.seller] + msg.value;
    //交易成功将NFT下架
    delete (s_listings[nftAddress][tokenId]);
    //NFT转移(安全转移)
    IERC721(nftAddress).safeTransferFrom(listedItem.seller, msg.sender, tokenId);
    //检查NFT是否已经转移
    emit ItemBought(msg.sender, nftAddress, tokenId, listedItem.price);


    
  }
  //3.下架NFTS
  function cancelListing(address nftAddress,uint256 tokenId) external
   isOwner(nftAddress, tokenId, msg.sender)
   isListed(nftAddress, tokenId)
   {
   delete (s_listings[nftAddress][tokenId]);
   emit ItemCanceled(msg.sender, nftAddress, tokenId); 

   }

  //4.更新价格
  function updateListing(address nftAddress, uint256 tokenId, uint256 newPrice) external 
   isOwner(nftAddress, tokenId, msg.sender)
   isListed(nftAddress, tokenId)
   {
    s_listings[nftAddress][tokenId].price = newPrice;
    emit ItemListed(msg.sender, nftAddress, tokenId, newPrice);

   }
  //5.提取账户出售NFTS获得的资金
  function withdrawProceeds() external {
    uint256 proceeds = s_proceeds[msg.sender];
    if(proceeds <= 0){
        revert NftMarketplace__NoProceeds();
    }
    s_proceeds[msg.sender] = 0;
    (bool success, ) = payable(msg.sender).call{value: proceeds}("");
    if(!success){
        revert NftMarketplace__TransferFailed();
    }

  }

  //获取上架的NFT信息
  function getListing(address nftAddress, uint256 tokenId)
  external 
  view
  returns (Listing memory)
  {
    return s_listings[nftAddress][tokenId];
  }
    //获得卖家收益信息
    function getProceeds(address seller) external view returns(uint256){
        return s_proceeds[seller];
    }

  
}