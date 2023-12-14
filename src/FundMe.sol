//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
 
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConvertor} from "./PriceConverter.sol";

//custom error
error  NotOwner();

contract FundMe{
    
    using PriceConvertor for uint256; 

    //minimum amount to send
    uint256 public constant MINIMUM_USD = 5e18;

    //users who have sent an amount
    address [] public s_funders;

    //keep track of amount each user sent
    mapping(address => uint256) public s_amountToFunders;

    //owner of funds
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }
      
    //function to fund from users
    function fund() payable public{
        //set minimum amount users can fund
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,"Transaction failed");
        s_funders.push(msg.sender);
        s_amountToFunders[msg.sender] += msg.value;
    }

    //function to withdraw
    function withdraw() public onlyOwner{
         
        //reset mapping
        for(uint256 funderIndex = 0;funderIndex < s_funders.length;funderIndex++) {
            address funder = s_funders[funderIndex];
            s_amountToFunders[funder] = 0;
        }

        //reset funders array
        s_funders = new address[](0);

        //withdraw funds
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess,"Call failed");
    }

    //cheaper withdraw
    function cheaperWithdraw() public onlyOwner{
        uint256 funderLength = s_funders.length;
        for(uint256 funderIndex = 0;funderIndex < funderLength;funderIndex++){
            address funder = s_funders[funderIndex];
            s_amountToFunders[funder] = 0;
        }
        s_funders = new address[](0);

        //withdraw funds
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess,"Call failed");
    }
    //onlyOwner privileges
    modifier onlyOwner(){
        // require(msg.sender == i_owner);
        if(msg.sender != i_owner){revert NotOwner();}
        _;
    }

    //recieve and fallback function for when someone sends eth without calling the fund function 
    receive() external payable { fund();}
    fallback() external payable {fund();}

//       function getPriceFeedVersion() public view returns (uint256) {
//       return PriceConvertor.getVersion();
//   }

    //getter functions
    //function get version
    function getVersion() public view returns (uint256){
        return s_priceFeed.version();
    }
     function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
        return s_amountToFunders[fundingAddress];
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}