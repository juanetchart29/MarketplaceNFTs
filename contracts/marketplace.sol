// SPDX-License-Indentidier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Marketpace is ReentracyGuard {

    address payable public inmutable feeAccount;
    uint public inmutable feePercent;
    uint public itemCount;

    struct item{
        uint itemId;
        IERC721 nft;
        uint tokenID;
        uint price;
        address payable seller;
        bool sold;
    }


    mapping (uint => Item)public items;

    event offered(
        uint itemID,
        address indexed nft,
        uint tokenID,
        uint price,
        address indexed seller
        );

    event bought(
        uint itemID,
        address indexed nft,
        uint tokenID,
        uint price,
        address indexed seller,
        address buyer
    );

    constructor(uint _feePercent){
        feeAccount = payable(msg.sender);
        feePercent = _feePercent;
    }

    function makeItem(IERC721 _nft, uint _tokenId, uint _price) external nonReentrancy {
        require(_price > 0);
        itemCount++;
        _nft.transferFrom(msg.sender, address(this), _tokenId);
        items[itemCount] = Item(
            itemCount, 
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );  
        emit offered(
            uint itemCount, 
            address(_nft),
            _tokenId,
            _price,
            msg.sender
        );

    }

    function pucharseItem(uint _itemId) external payable nonReentrancy {
        uint _totalPrice = getTotalPrice(_itemId);
        Item storage item = items[_itemId];
        require(_itemId > 0 && _itemId <= itemCount);
        require(msg.value >= _totalPrice);
        require(!item.sold);
        item.seller.transfer(_itemPrice);
        feeAccount.transfer(_totalPrice - item.price);
        item.sold = true;
        item.nft.transferFrom(address(this), msg.sender, item.tokenId);
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
            return((item[_itemId].price*(100 + feePercent))/100);
            
        }
    }
        


