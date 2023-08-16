// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Iconnected.sol";

contract BookStore is ERC721Enumerable,Ownable {

    using Counters for Counters.Counter;
    Counters.Counter public tokenId;
    Counters.Counter public buytokenid;
    address public    ERCc721;
    address public   ERCc20;

uint256 public  priceee;


    event BookPurchased(
        address indexed buyer,
        uint256 price,
        string title
    );

    struct Book {
        string title;
        string author;
        string isbn;
        uint256 price;
        bool approve;
        bool rentapprove;
        uint256 starttime;
        uint256 endtime;
    }
    




    mapping(uint256 => bool) public bookPurchased;
    mapping(uint256 => address) public tokenowner;
    mapping(uint256 => address) public rentednftowner;

    mapping(uint256 => uint256) public noofquantity;
    mapping(uint256 => uint256) public pricee;
    mapping(uint256 => Book) public books;
    mapping(uint256 => Book) public Id_to_book;
    mapping(uint256 => uint256) public price;
    mapping(uint256 => address) public ownerbyaddress;

    constructor(address ERCcc20,address ERCcc721) ERC721("BookStore", "BOOK") {
        ERCc20=ERCcc20;
        ERCc721=ERCcc721;
    }


    uint256 passquantity = 0;

    function addBook(
        string memory title,
        string memory author,
        string memory isbn,
        uint256 price,
        uint256 quantity
    ) public onlyOwner {

        uint256 currentTokenId = tokenId.current();
        bool approve = false;
        bool rentapprove=false;
        uint256 starttime=0;
        uint256 endtime=0;
//    address rentednftowner = address(0); // Initialize rentednftowner with the zero address     
        for (uint256 i = 0; i < quantity; i++) {
            currentTokenId = tokenId.current();
            books[currentTokenId] = Book(
                title,
                author,
                isbn,
                price,
                approve,
                rentapprove,
              starttime,
               endtime
 
            );

            IConnected(ERCc721).safeMint(msg.sender,currentTokenId );


            Id_to_book[currentTokenId] = Book(
                title,
                author,
                isbn,
                price,
                approve,
                rentapprove,
                starttime,
               endtime
            );

            tokenId.increment();
        }
    }



    function buyBook(string memory nftname, uint256 purchasinquantity) public {
        uint256 il = 0;
        // require(owner);
        for (uint256 i = 0; i < tokenId.current(); i++) {

            if (keccak256(bytes(books[i].title)) == keccak256(bytes(nftname))  && ((books[i].approve)==true)  ) {
              require(IERC721(ERCc721).ownerOf(i)!=msg.sender,"already owner cannot buy");
             require((IERC20(ERCc20).balanceOf(msg.sender)) >= books[i].price, "not enough funds");
                IERC721(ERCc721).transferFrom(ownerOf(i), msg.sender, i);
                // Id_to_book[il] = books[i];
                il++;
                books[i].approve = false;
                // priceee=books[i].price;
                IERC20(ERCc20).transferr(msg.sender,ownerOf(i),books[i].price);
                if (il == purchasinquantity) {
                    break;
                }

            }
        }

        if (il < purchasinquantity) {
            revert("not enough quantity available");
        }

    }




    function getAllBooks() public view returns (Book[] memory) {
        Book[] memory allBooks = new Book[](tokenId.current());

        for (uint256 i = 0; i < tokenId.current(); i++) {
            allBooks[i] = books[i];
        }

        return allBooks;
    }



    function Your_Bougth_books(address mine) public view returns (Book[] memory) {
        uint256 bookCount = 0;

        for (uint256 i = 0; i < tokenId.current(); i++) {
            if (IERC721(ERCc721).ownerOf(i) == mine) {
                bookCount += 1;
            }
        }

        Book[] memory allyourBooks = new Book[](bookCount);
        uint256 currentIndex = 0;

        for (uint256 j = 0; j < tokenId.current(); j++) {
            if (IERC721(ERCc721).ownerOf(j) == mine) {
                allyourBooks[currentIndex] = Id_to_book[j];
                currentIndex++;
            }
        }

        return allyourBooks;
    }


    function approve_for_sell(uint256 tokenId,uint256 price) public returns (bool) {
        require(
            IERC721(ERCc721).ownerOf(tokenId) == msg.sender,
            "You can't sell this, only owner allowed"
        );
    require((books[tokenId].approve==false),"Cannot be placed on sell because it is on selling");
    require((books[tokenId].rentapprove==false)," on rent,so cannot be placed on sell");

        books[tokenId].approve = true;
        books[tokenId].price = price ;

    }

  

    function listedNfts() public view returns (Book[] memory) {
     

        Book[] memory allbooks = new Book[]((tokenId.current()));
        uint256 seccounter = 0;

        for (uint256 i = 0; i < tokenId.current(); i++) {
            if ((books[i].approve == true) && (books[i].rentapprove==false)) {
                allbooks[seccounter] = books[i];
                seccounter+=1;
            }
        }

        return allbooks;
    }




function yourBalance(address he) public view returns (uint256) {
    return IERC20(ERCc20).balanceOf(he);
}




function approveforrent(uint256 tokenId) public {
    require((IERC721(ERCc721).ownerOf(tokenId)==msg.sender),"you are not owner");

    require((books[tokenId].approve==false),"Cannot be placed on rent because it is on selling");
    require((books[tokenId].rentapprove==false),"already on rent");

    books[tokenId].rentapprove=true;
}

function getOwner(uint256 tokenId) public view returns (address) {
    address owner = IERC721(ERCc721).ownerOf(tokenId);
    return owner;
}

function buybookonrent(uint i) public {

require(books[i].rentapprove==true,"book not available for rent");
require(books[i].approve==false,"books on selling so not on rent ");


books[i].starttime=block.timestamp;
books[i].endtime=books[i].starttime+ 30 seconds;

books[i].rentapprove=false;
rentednftowner[i]=msg.sender;

}


function getRentListedBooks() public view returns (Book[] memory) {
 Book[] memory rentedBooks = new Book[](tokenId.current());
    uint256 count = 0;
    // uint256 icount = 0;

    for (uint256 i = 0; i < tokenId.current(); i++) {
        if ((books[i].approve == false) && (books[i].rentapprove == true) &&(!(rentednftowner[i]==msg.sender))) {
            rentedBooks[count] = books[i];
            count++;
        }
    }

    return rentedBooks;
}


function getYourRentedBooks(address userAddress) public view returns (Book[] memory) {
    uint256 count = 0;
    bool ali=false;
    // uint256 ch=0;

    for (uint256 i = 0; i < tokenId.current(); i++) {
        //  require(ali,"errror");

        if (rentednftowner[i] == userAddress && books[i].starttime < block.timestamp && books[i].endtime > block.timestamp) {
        //  require(ali,"errro1");

            count++;
        }
    }

    Book[] memory allBooks = new Book[](count);
    uint256 index = 0;

    for (uint256 i = 0; i < tokenId.current(); i++) {
        if (rentednftowner[i] == userAddress && books[i].starttime < block.timestamp && books[i].endtime > block.timestamp) {
            allBooks[index] = books[i];
            // require(ali,"yasss");

            index++;
        }
    }

    return allBooks;
}


}
