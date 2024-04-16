// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Crowdfunding.sol";

contract DeployFundraiserFactory is Script {
    function run() public {
        vm.startBroadcast();

        // Deploy the FundraiserFactory contract
        FundraiserFactory factory = new FundraiserFactory();
        console.log("FundraiserFactory deployed at:", address(factory));

        vm.stopBroadcast();
    }
}
