//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0 <0.9.0;

// This project is a simple auction, where different addresses can bid 
// in the "bid" function, and the highest bids and the bidder's address
// is stored on the blockchain. When the bidding is over, 
// individuals who were outbid can get their payment back,
// and the beneficiary can claim the money the highest bidder bid.


contract SimpleAuction{
    //Parameters
    address payable public beneficiary;
    uint public auctionEndTime;

    // Current State of Auction
    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) public pendingReturns;

    bool ended = false;

    event HighestBidIncrease(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(uint _biddingTime, address payable _beneficiary){
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function bid() public payable{
        if (block.timestamp > auctionEndTime){
            revert("The auction has already ended");
        }

        if (msg.value <= highestBid){
            revert("There is already an equal or higher bid");
        }

        if (highestBid != 0){
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncrease(msg.sender, msg.value);
    }

    function withdraw() public returns(bool) {
        uint amount = pendingReturns[msg.sender];
        if(amount > 0){
            pendingReturns[msg.sender] = 0;

            if(!payable(msg.sender).send(amount)){
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() public {
        if (block.timestamp < auctionEndTime){
            revert ("The auction has not ended yet");
        }
        if (ended){
            revert("The function auctionEnded has laready been called");
        }
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        beneficiary.transfer(highestBid);
    }

}
