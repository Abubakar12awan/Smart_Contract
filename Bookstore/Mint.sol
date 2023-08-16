// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Mint is ERC721Enumerable, Ownable {
    constructor() ERC721("BookStore", "BOOK") {
    
    }

    function safeMint(address recipient, uint256 currentTokenId) public {
        _safeMint(recipient, currentTokenId);
    }

    
    // You can add more functions and logic here as per your requirements.
    // For example, you can add functions to mint new NFTs, manage ownership, and more.
}
