//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from 'forge-std/Test.sol';
import {FundMe} from '../src/FundMe.sol';
import {DeployFundMe} from '../script/DeployFundMe.s.sol';

contract FundMeTest is Test{
    FundMe fundMe;
     
    address USER = makeAddr('user');
    uint256 constant SendValue = 0.1 ether;  

    function setUp() external{
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run(); 
        vm.deal(USER,10 ether);
    }

    function testMinimunUsdIsFive() public {
        assertEq(fundMe.MINIMUM_USD(),5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(),msg.sender);
    }

    function testGetVersionIsAccurate() public{
        uint256 version = fundMe.getVersion();
        assertEq(version,4);
    }
    function testFundMeAmountFails() public{
        vm.expectRevert();
        fundMe.fund();
    }
    function testFunding() public{
        vm.prank(USER);
        fundMe.fund{value : SendValue}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded,SendValue);
    }
    function testAddUserToFunders() public funded{
        address funder = fundMe.getFunder(0);
        assertEq(funder,USER);
    }
    function testOnlyOwnerCanWithdraw() public funded{
        vm.expectRevert();
        vm.prank(USER); 
        fundMe.withdraw();
    }

    modifier funded(){
        vm.prank(USER);
        fundMe.fund{value : SendValue}();
        _;
    }

    function testWithdrawWithSingleFunder() public funded{
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        
        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance,0);
        assertEq(startingOwnerBalance + startingFundMeBalance,endingOwnerBalance);

    }

    function testWithMultipleFunders() public funded{
       uint160 numberOfFunders = 10;
       uint160 startingIndex = 1;
       for(uint160 i= startingIndex;i<numberOfFunders;i++){
         hoax(address(i),SendValue);
         fundMe.fund{value : SendValue}();
       }

       uint256 startingOwnerBalance = fundMe.getOwner().balance;
       uint256 startingFundMeBalance = address(fundMe).balance;

       vm.prank(fundMe.getOwner());
       fundMe.withdraw();

       assert(address(fundMe).balance == 0);
       assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

    function testWithCheaperWithdraw() public funded{
        
    }
}