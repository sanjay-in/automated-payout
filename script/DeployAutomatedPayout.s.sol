// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {AutomatedPayout} from "../src/AutomatedPayout.sol";
import {Employee} from "../src/Employee.sol";
import {USDC} from "../src/USDC.sol";
import {DeployEmployee} from "./DeployEmployee.s.sol";
import {DeployUSDC} from "./DeployUSDC.s.sol";
import {Script} from "forge-std/Script.sol";

contract DeployAutomatedPayout is Script {
    function run() external returns (AutomatedPayout){
        vm.startBroadcast();
        Employee employee = new Employee();
        USDC usdc = new USDC(1000000);
        address permit2Contract = address(0);
        AutomatedPayout automatedPayout = new AutomatedPayout(address(usdc), address(employee), permit2Contract);
        vm.stopBroadcast();

        return automatedPayout;
    }
}