// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";


contract Marketplace {

    uint256 public itemCount = 0; 

    struct Item {
        uint itemId;
        IERC721 nft;
        uint tokenId;
        uint price;
        address seller;
        bool sold;
        bool status;
    }

    // itemId -> Item
    mapping(uint256 => Item) public items;

    IERC721 private nft;
    IERC20 private token;

    
    constructor(IERC721 _nft, IERC20 _token) public {
        nft = _nft;
        token = _token;
    }

    // Make item to offer on the marketplace
    function makeItem(uint256 _tokenId, uint256 _price) public {
        require(_price > 0, "Price must be greater than zero");
        // increment itemCount
        itemCount ++;
        // transfer nft
        nft.transferFrom(msg.sender, address(this), _tokenId);
        // add new item to items mapping
        items[itemCount] = Item (
            itemCount,
            nft,
            _tokenId,
            _price,
            msg.sender,
            false,
            false
        );
    }

    function removeItem(uint256 _itemId) public {
        Item storage item = items[_itemId];
        require(msg.sender == item.seller, "Khong phai seller");
        require(item.itemId != 0, "chua ton tai item");
        require(item.sold == false, "item da duoc ban");
        require(item.status == false, "item da dc thu hoi");

        item.status = true;
        nft.transferFrom(address(this), item.seller, item.tokenId);

    }

    function buyItem(uint256 _itemId, address buyer) public {
        
        Item storage item = items[_itemId];
        require(item.itemId != 0, "chua ton tai item");
        require(item.sold == false, "item da duoc ban");
        require(item.status == false, "item da dc thu hoi");

        require(token.allowance(buyer, address(this)) >= item.price, "khong du token uy quyen");
        token.transferFrom(buyer, item.seller, item.price);
        nft.transferFrom(address(this), buyer, item.tokenId);
        item.sold = true;
    }

}