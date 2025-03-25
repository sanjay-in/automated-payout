// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {USDC} from "../src/USDC.sol";

contract DeployUSDC is Script {
    function run() external returns(USDC) {
        vm.startBroadcast();
        USDC usdc = new USDC(10000); // Mints $10k worth of tokens
        vm.stopBroadcast();

        return usdc;
    }

}