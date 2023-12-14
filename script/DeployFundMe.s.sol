//SPDX-License-Identifier: MIY

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from './HelperConfig.s.sol';

contract DeployFundMe is Script{
  //Before start broadcast
    HelperConfig helperConfig = new HelperConfig();
    address ethUsdPrice = helperConfig.activeConfig();

    function run() external returns (FundMe){
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPrice);
        vm.stopBroadcast();
        return fundMe;
    }
}
