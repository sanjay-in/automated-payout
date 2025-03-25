// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {Employee} from "../src/Employee.sol";

contract DeployEmployee is Script {
    function run() external returns (Employee) {
        vm.startBroadcast();
        Employee employee = new Employee();
        vm.stopBroadcast();

        return employee;
    }
}
