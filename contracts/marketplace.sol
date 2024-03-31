// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard {
    address payable public immutable feeAccount;
    uint public immutable feePercent;
    uint public itemCount;

    struct Item {
        uint itemId;
        IERC721 nft;
        uint tokenId;
        uint price;
        address payable seller;
        bool sold;
    }

    mapping (uint => Item) public items;

    event Offered(
        uint itemId,
        address indexed nft,
        uint tokenId,
        uint price,
        address indexed seller
    );

    event Bought(
        uint itemId,
        address indexed nft,
        uint tokenId,
        uint price,
        address indexed seller,
        address buyer
    );

    constructor(uint _feePercent) {
        feeAccount = payable(msg.sender);
        feePercent = _feePercent;
    }

    function makeItem(IERC721 _nft, uint _tokenId, uint _price) external nonReentrant {
        require(_price > 0);
        itemCount++;
        _nft.safeTransferFrom(msg.sender, address(this), _tokenId);
        items[itemCount] = Item(
            itemCount, 
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );  
        emit Offered(
            itemCount, 
            address(_nft),
            _tokenId,
            _price,
            msg.sender
        );
    }

    function purchaseItem(uint _itemId) external payable nonReentrant {
        uint totalPrice = getTotalPrice(_itemId);
        Item storage item = items[_itemId];
        require(_itemId > 0 && _itemId <= itemCount);
        require(msg.value >= totalPrice);
        require(!item.sold);
        item.seller.transfer(item.price);
        feeAccount.transfer((totalPrice - item.price));
        item.sold = true;
        item.nft.safeTransferFrom(address(this), msg.sender, item.tokenId);
        emit Bought(
            _itemId, 
            address(item.nft),
            item.tokenId, 
            item.price,
            item.seller,
            msg.sender
        );
    }

    function getTotalPrice(uint _itemId) view public returns(uint){
        return ((items[_itemId].price * (100 + feePercent)) / 100);
    }
}
