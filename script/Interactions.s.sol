//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script,console} from 'forge-std/Script.sol';
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from '../src/FundMe.sol';

contract Interaction is Script{
    function fundFundMe(address mostRecentDeployed) public{
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).fund{value : 0.01 ether}();
        vm.stopBroadcast();
        console.log("Funded with %s", 0.01 ether);
    }

    function run() external{
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundMe",block.chainid);
        fundFundMe(mostRecentDeployed);
    }
}