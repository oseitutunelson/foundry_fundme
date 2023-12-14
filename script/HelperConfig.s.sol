//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from 'forge-std/Script.sol';
import {MockV3Aggregator} from '../test/mocks/MockV3Aggregator.sol';

contract HelperConfig is Script{
    NetworkConfig public activeConfig;

    struct NetworkConfig{
        address priceFeed;
    }

    //set anvil magic numbers
    uint8 public constant DECIMAL = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    //set active config to active chain
    constructor() {
        if(block.chainid == 11155111){
            activeConfig = getSepoliaPrice();
        }else if(block.chainid == 1){
            activeConfig = getEthMainnet();
        }else{
            activeConfig = getAnvilPrice();
        }
    }

    //function for sepolia priceFeed
    function getSepoliaPrice() public pure returns (NetworkConfig memory){
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed : 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }
    
    //function to get ethereum mainnet priceFeed
    function getEthMainnet() public pure returns (NetworkConfig memory){
       NetworkConfig memory ethConfig = NetworkConfig({
        priceFeed : 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
       });
       return ethConfig;
    }
    //function to get polygon mainnet
    function getMaticPrice() public pure returns (NetworkConfig memory){
        NetworkConfig memory maticConfig = NetworkConfig({
            priceFeed : 0x7bAC85A8a13A4BcD8abb3eB7d6b4d632c5a57676
        });
        return maticConfig;
    }
    //function to get local priceFeed
    function getAnvilPrice() public  returns (NetworkConfig memory){
        //if priceFeed is aleady set 
        if(activeConfig.priceFeed != address(0)){
            return activeConfig;
        }
       vm.startBroadcast();
        MockV3Aggregator mockAggregator = new MockV3Aggregator(DECIMAL,INITIAL_PRICE);
       vm.stopBroadcast();

       NetworkConfig memory anvilConfig = NetworkConfig({
        priceFeed : address(mockAggregator)
       });

       return anvilConfig;
    }
}