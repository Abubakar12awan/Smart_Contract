pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Iconnected.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Marketplace is Ownable   {
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;

    address public erc20;
    address public erc721;
    Counters.Counter public  tokenId;
    Counters.Counter public  biddingId;
    Counters.Counter public  rentId;



    struct Plot {
        string plotName;
        uint256 priceForSelling;
        uint256 priceForRent;
        uint256 rentPeriod;
        bool approve;
        bool rentApprove;
    }

    struct Bidding {
        address bidder;
        uint256 bidingprice;
        uint256 tokenId;
    }

    struct OnRent{
        address renterperson;
        uint256 tokenId;
        uint256 starttime;
        uint256 endtime;
        uint256 price;
    }


    mapping(uint256 => Plot) public plots;
    mapping(uint256 => Bidding) public biddings;
    mapping(uint256 => OnRent) public rentedplots;
    mapping (string =>uint256) public tokens;


    constructor(address erc20Token, address erc721Token) {
        erc20 = erc20Token;
        erc721 = erc721Token;
    }

    function BuyPlot(
        uint256 price,
        // uint256 priceForRent,
        string memory coordiantes,
        uint256  tokenId

    ) public  {

        

        IConnected(erc721).safeMint(msg.sender, tokenId);
        plots[tokenId] = Plot(
            coordiantes,
            0,
            price,
            0,
            false,
            false
        );

        // tokenId.increment();
    }


    function PlotsonRent() public view returns (Plot[] memory) {

        uint256 count = 0;
        for (uint256 i = 0; i < tokenId.current(); i++) {
            if (plots[i].rentApprove && !plots[i].approve) {
                count++;
            }
        }

        Plot[] memory allPlots = new Plot[](count);
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < tokenId.current(); i++) {
            if (plots[i].rentApprove && !plots[i].approve  && IERC721(erc721).ownerOf(i)!=msg.sender ) {
                allPlots[currentIndex] = plots[i];
                currentIndex++;
            }
        }

        return allPlots;
    }



    function Bid_to_rent_plot(uint256 tokenId, uint256 bidingprice) public{
        require(IERC721(erc721).ownerOf(tokenId)!=msg.sender,"wner canot take on rent ");

        require(plots[tokenId].rentApprove,"plot is not on rent");
        require(!plots[tokenId].approve,"plot is already on selling,not on rent");

        require((IERC20(erc20).balanceOf(msg.sender) >= plots[tokenId].priceForRent), "Your balance should be greater than rent price, not enough tokens");
        require((IERC20(erc20).balanceOf(msg.sender) >= bidingprice), "Bidding error, your balance should be greater than bidding price");
        require(bidingprice>=plots[tokenId].priceForRent,"biding price should be more than price");

        IERC20(erc20).transferr(msg.sender,address(this), bidingprice);
        biddings[biddingId.current()] = Bidding(msg.sender, bidingprice,tokenId);
        biddingId.increment();
    }


    function show_bidings(uint256 token) public view  returns (Bidding[] memory) {
        
        Bidding[] memory allBiddings = new Bidding[](biddingId.current());
        uint256 count = 0;

        for (uint256 i = 0; i < biddingId.current(); i++) {
            
                if (biddings[i].tokenId==token  )  {
                    allBiddings[count] = biddings[i];
                    count++;
            }
        }



        return allBiddings;
    }


function select_person_to_rent(uint256 token , address renter ) public  {
    require(IERC721(erc721).ownerOf(token)==msg.sender,"only owner can select ");

           for (uint256 i = 0; i < biddingId.current(); i++) {
                if (biddings[i].bidder==renter && biddings[i].tokenId==token ) {
                    uint256 starttimee;
                    starttimee=block.timestamp;

                    uint256 endtimee ;
                    endtimee = starttimee + plots[token].rentPeriod * 1 seconds;


                   rentedplots[rentId.current()]=OnRent(renter,token,starttimee,endtimee,biddings[i].bidingprice);

                    rentId.increment();
                    plots[token].rentApprove=false;

                    claerbddings(token);

            }
        }



    
     }

     function claerbddings(uint256 token) internal  {
         
        for (uint256 i = 0; i < biddingId.current(); i++) {
            
                if (biddings[i].tokenId==token  )  {
                    biddings[i].bidder=address(0);
                  
            }
        }

     }


      function get_your_rented_plots() public view returns ( Plot[] memory)  {

        Plot[] memory allPlots = new Plot[](rentId.current());
           uint256 count=0;
          for (uint256 i=0; i < rentId.current(); i++) 
          {
            if(rentedplots[i].renterperson==msg.sender && block.timestamp<rentedplots[i].endtime){

             allPlots[count]=plots[rentedplots[i].tokenId];
              count++;

            }

              
          }
     
 return allPlots;
 }



function Plotsonselling() public view returns ( Plot[] memory) {
      uint256 count = 0;
        for (uint256 i = 0; i < tokenId.current(); i++) {
            if (!plots[i].rentApprove && plots[i].approve && IERC721(erc721).ownerOf(i)!=msg.sender ) {
                count++;
            }
        }

        Plot[] memory allPlots = new Plot[](count);
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < tokenId.current(); i++) {
            if (!plots[i].rentApprove && plots[i].approve && IERC721(erc721).ownerOf(i)!=msg.sender) {
                allPlots[currentIndex] = plots[i];
                currentIndex++;
            }
        }

        return allPlots;

}


function approve_for_sell(uint256 tokenId)public {
require(msg.sender==IERC721(erc721).ownerOf(tokenId),"only owner can approve");

require(!plots[tokenId].approve,"already on sell");
require(!plots[tokenId].rentApprove,"already on rent");

plots[tokenId].approve=true;
    
}


function approve_for_rent(uint256 tokenId)public  {
require(msg.sender==IERC721(erc721).ownerOf(tokenId),"only owner can approve");

require(!plots[tokenId].approve,"already on sell");
require(!plots[tokenId].rentApprove,"already on rent");
plots[tokenId].rentApprove=true;

    
}



 function BuyPLot(uint256 token) public {
             require(plots[token].approve,"This plot is not for selling");
            require(!plots[token].rentApprove,"This plot is already on rent");

            require(IERC721(erc721).ownerOf(token)!=msg.sender,"Owner cannot buy");
             address tokenOwner = IERC721(erc721).ownerOf(token);
             require((IERC20(erc20).balanceOf(msg.sender)) >= plots[token].priceForSelling, "not enough funds");
             IERC20(erc20).transferr(msg.sender,tokenOwner,plots[token].priceForSelling);
             IERC721(erc721).transferFrom(tokenOwner, msg.sender, token);
                
            plots[token].approve = false;
            
    }

function Your_Bought_Plots() public view  returns(Plot [] memory) {
        Plot[] memory allPlots = new Plot[](tokenId.current());
      uint256 count=0;
       for (uint256 i=0; i<tokenId.current(); i++){
              if(IERC721(erc721).ownerOf(i)==msg.sender){
              allPlots[count]=plots[i];
                count++;
               }

        } 

return allPlots;

}

function Allplots() public view  returns(Plot [] memory)  {

        Plot[] memory allPlots = new Plot[](tokenId.current());
         uint256 count=0;
          for (uint256 i=0; i<tokenId.current(); i++){
                allPlots[count]=plots[i];
                count++;
        } 

return allPlots;

} 







}










