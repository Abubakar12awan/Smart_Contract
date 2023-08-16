pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    constructor() ERC20("MyToken", "MTK") {
        mint(msg.sender,757657653543432432323234342324);
    }

    function mint(address to, uint256 amount) public  {
        _mint(to, amount);
    }
}