// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {AutomatedPayout} from "../../src/AutomatedPayout.sol";
import {DeployAutomatedPayout} from "../../script/DeployAutomatedPayout.s.sol";
import {Test, console} from "forge-std/Test.sol";

contract TestAutomatedPayout is Test {
    AutomatedPayout public automatedPayout;

    function setup() external {
        DeployAutomatedPayout deployAutomatedPayout = new DeployAutomatedPayout();
        automatedPayout = deployAutomatedPayout.run();
    }

    
}