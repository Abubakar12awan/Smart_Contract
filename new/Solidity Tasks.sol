// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyToken is ERC721, ERC721URIStorage,ERC721Enumerable, Ownable {

  struct Minters { 
      address  minter_address;
   }
    uint256 private immutable  _cap;
    uint public minterIndex;
    using Counters for Counters.Counter;
     Minters[] public minters;
  uint256[]  tokens_by_owners;
    //flags
    bool private presale1=false;
    bool private presale2=false;
     bool private presale3=false;

    Counters.Counter private _tokenIdCounter;

    constructor(uint256 cap) ERC721("MyToken", "MTK") {
        require(cap > 0, "ERC721Capped: cap is 0");
        _cap = cap;
    }

    function safeMint(address to, string memory uri) public onlyOwner {
      
       
        uint256 tokenId = _tokenIdCounter.current();
        if(!minterExists(to)){
    minters.push(Minters({
        minter_address:to
    }));
        }
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        
    }
    function batchMint(address to, string memory uri,uint256 amount)public onlyOwner{
          require(ERC721Enumerable.totalSupply()+amount<getCap(),"ERC721: cap exceeded");
        require(ERC721.balanceOf(to)+amount<3,"ERC721: Wallet Address Maximum Tokens Reached");
        if(!presale1&& (ERC721Enumerable.totalSupply()+amount>1000)){
revert("Pre Sale 1 Completed. Wait for Owner to continue sales");
        }
        if(!presale2&& (ERC721Enumerable.totalSupply()+amount>2000)){
revert("Pre Sale 2 Completed. Wait for Owner to continue sales");
        }
        if(!presale3&& (ERC721Enumerable.totalSupply()+amount>3000)){
revert("Pre Sale 3 Completed. Wait for Owner to continue sales");
        }
 for(uint256 i=0;i<amount;i++){
     safeMint(to,uri);
 }
    }
    function minterExists(address  m_address)public  returns(bool){
        for(uint i=0;i<minters.length;i++){
            if(minters[i].minter_address==m_address){
                minterIndex=i;
                return true;
            }
        }
        return false;
    }
    function getAllMinters() public view returns(Minters[] memory){
             Minters[]    memory id = new Minters[](minters.length);
      for (uint i = 0; i < minters.length; i++) {
          Minters storage member = minters[i];
          id[i] = member;
      }
      return id;
    }
    function getAllTokensWithOwners(address  owner) public  returns(uint256[] memory){
            for(uint256 j=0;j<balanceOf(owner);j++){      
tokens_by_owners.push(
   tokenOfOwnerByIndex(owner,j)
  );
            }
        return tokens_by_owners;
    }
    function presale1Complete() public onlyOwner{
        presale1=true;
    }
     function presale2Complete() public onlyOwner{
        presale2=true;
    }
     function presale3Complete() public onlyOwner{
        presale3=true;
    }
function getCap() public view virtual returns(uint256){
    return _cap;
}
    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
      // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}