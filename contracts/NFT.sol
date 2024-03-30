// SPDX-License-Indentidier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFT is ERC721URIStorage {
    uint public tokenCount;

    constructor() ERC721("ClimbeNFT", "CLB") {}
    function mint(string memory _tokenURI) external returns (uint) {
        tokenCount++;
        _safeMint(msg.sender, tokenCount);
        _safeTokenURI(tokenCount, _tokenURI);
        return tokenCount;
    }
}