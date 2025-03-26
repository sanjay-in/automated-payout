// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Employee} from "../../src/Employee.sol";
import {DeployEmployee} from "../../script/DeployEmployee.s.sol";

contract TestEmployee is Test {
    Employee public employee;
    address public msgSender = msg.sender;
    bytes32 public constant MANAGER = keccak256("MANAGER");
    // employee.EmployeeDetails public testEmployee = employee.EmployeeDetails({

    // });

    // Employee Details
    // Employee 1
    string createdName1 = "John";
    uint256 createdAnnualSalary1 = 100000;
    // Average working days in a year is 260. 100000/260
    uint256 createdDailySalary1 = 385; // approx.
    uint256 createdTotalAnnualLeave1 = 40;
    address createdWalletAddress1 = makeAddr("John");

    // Employee 2
    string createdName2 = "David";
    uint256 createdAnnualSalary2 = 100000;
    uint256 createdDailySalary2 = 385;
    uint256 createdTotalAnnualLeave2 = 40;
    address createdWalletAddress2 = makeAddr("David");

    function setUp() public {
        DeployEmployee deployer = new DeployEmployee();
        employee = deployer.run();
    }

    function testManagerRoleAssignedToAdmin() public view {
        bool isAdminAssignedManagerRole = employee.hasRole(MANAGER, msgSender);
        assertEq(isAdminAssignedManagerRole, true);
    }

    function testNoEmployees() public view {
        Employee.EmployeeDetails[] memory employeeList = employee.getActiveEmployees();
        assertEq(employeeList.length, 0);
    }

    function testAddEmployees() public {
        vm.prank(msgSender);
        employee.addEmployee(
            createdName1, createdAnnualSalary1, createdDailySalary1, createdTotalAnnualLeave1, createdWalletAddress1
        );

        Employee.EmployeeDetails[] memory employeeList = employee.getActiveEmployees();
        assertEq(employeeList.length, 1);

        for (uint256 i = 0; i < employeeList.length; i++) {
            assertEq(createdName1, employeeList[i].name);
            assertEq(createdAnnualSalary1, employeeList[i].annualSalary);
            assertEq(createdDailySalary1, employeeList[i].dailySalary);
            assertEq(createdTotalAnnualLeave1, employeeList[i].totalAnnualLeave);
            assertEq(createdWalletAddress1, employeeList[i].walletAddress);
            assertEq(employeeList[i].leaveTaken, 0);
            assertEq(employeeList[i].unpaidLeaves, 0);
            assertEq(employeeList[i].active, true);
        }
    }

    function testEventForAddingEmployee() public {
        vm.expectEmit(true, false, false, true);
        emit Employee.EmployeeAdded(
            1,
            Employee.EmployeeDetails(
                1,
                createdName1,
                createdAnnualSalary1,
                createdDailySalary1,
                createdTotalAnnualLeave1,
                0,
                0,
                createdWalletAddress1,
                true
            )
        );

        vm.startPrank(msgSender);
        employee.addEmployee(
            createdName1, createdAnnualSalary1, createdDailySalary1, createdTotalAnnualLeave1, createdWalletAddress1
        );
        vm.stopPrank();
    }

    function testRevertAddingZeroWallet() public {
        vm.expectRevert(Employee.Employee__InvalidWalletAddress.selector);
        vm.startPrank(msgSender);
        employee.addEmployee(
            createdName1, createdAnnualSalary1, createdDailySalary1, createdTotalAnnualLeave1, address(0)
        );
        vm.stopPrank();
    }

    function testRemoveEmployee() public {
        vm.startPrank(msgSender);
        addEmployeesHelperFunction();

        //Remove employee ID 1 (John)
        employee.removeEmployee(1);
        vm.stopPrank();

        Employee.EmployeeDetails[] memory employeeList = employee.getActiveEmployees();
        assertEq(employeeList.length, 1);

        for (uint256 i = 0; i < employeeList.length; i++) {
            assertEq(createdName2, employeeList[i].name);
            assertEq(createdAnnualSalary2, employeeList[i].annualSalary);
            assertEq(createdDailySalary2, employeeList[i].dailySalary);
            assertEq(createdTotalAnnualLeave2, employeeList[i].totalAnnualLeave);
            assertEq(createdWalletAddress2, employeeList[i].walletAddress);
        }

        Employee.EmployeeDetails memory employee1 = employee.getEmployeeDetails(1);
        assertEq(employee1.active, false);
    }

    function testEventForRemoval() public {
        vm.startPrank(msgSender);
        addEmployeesHelperFunction();
        vm.expectEmit(true, false, false, false);
        emit Employee.EmployeeRemoved(1);
        employee.removeEmployee(1);
        vm.stopPrank();
    }

    function testRevertInvalidID() public {
        vm.expectRevert(Employee.Employee__InvalidEmployeeID.selector);
        vm.startPrank(msgSender);
        employee.removeEmployee(42);
        vm.stopPrank();
    }

    function testEmployeeUpdate() public {
        uint256 idToUpdate = 1;
        uint256 updatedAnnualSalary = 110000;
        uint256 updatedLeaveTaken = 43;
        uint256 updatedUnpaidLeaves = 3;

        vm.startPrank(msgSender);
        employee.addEmployee(
            createdName1, createdAnnualSalary1, createdDailySalary1, createdTotalAnnualLeave1, createdWalletAddress1
        );
        updationHelperFunction(idToUpdate, updatedAnnualSalary, updatedLeaveTaken, updatedUnpaidLeaves);
        vm.stopPrank();

        Employee.EmployeeDetails[] memory employeeList = employee.getActiveEmployees();

        for (uint256 i = 0; i < employeeList.length; i++) {
            if (employeeList[i].id == idToUpdate) {
                assertEq(employeeList[i].id, idToUpdate);
                assertEq(employeeList[i].name, createdName1);
                assertEq(employeeList[i].annualSalary, updatedAnnualSalary);
                assertEq(employeeList[i].dailySalary, createdDailySalary1);
                assertEq(employeeList[i].totalAnnualLeave, createdTotalAnnualLeave1);
                assertEq(employeeList[i].leaveTaken, updatedLeaveTaken);
                assertEq(employeeList[i].unpaidLeaves, updatedUnpaidLeaves);
                assertEq(employeeList[i].walletAddress, createdWalletAddress1);
                assertEq(employeeList[i].active, true);
            }
        }
    }

    function testEventForEmployeeUpdation() public {
        uint256 idToUpdate = 1;
        uint256 updatedAnnualSalary = 110000;
        uint256 updatedLeaveTaken = 43;
        uint256 updatedUnpaidLeaves = 3;

        vm.startPrank(msgSender);
        employee.addEmployee(
            createdName1, createdAnnualSalary1, createdDailySalary1, createdTotalAnnualLeave1, createdWalletAddress1
        );
        vm.expectEmit(true, false, false, true);
        emit Employee.EmployeeUpdated(
            idToUpdate,
            Employee.EmployeeDetails(
                1,
                createdName1,
                updatedAnnualSalary,
                createdDailySalary1,
                createdTotalAnnualLeave1,
                updatedLeaveTaken,
                updatedUnpaidLeaves,
                createdWalletAddress1,
                true
            )
        );
        updationHelperFunction(idToUpdate, updatedAnnualSalary, updatedLeaveTaken, updatedUnpaidLeaves);
        vm.stopPrank();
    }

    // Helper functions
    function addEmployeesHelperFunction() public {
        // Employee 1
        employee.addEmployee(
            createdName1, createdAnnualSalary1, createdDailySalary1, createdTotalAnnualLeave1, createdWalletAddress1
        );

        // Employee 2
        employee.addEmployee(
            createdName2, createdAnnualSalary2, createdDailySalary2, createdTotalAnnualLeave2, createdWalletAddress2
        );
    }

    function updationHelperFunction(
        uint256 _idToUpdate,
        uint256 _updatedAnnualSalary,
        uint256 _updatedLeaveTaken,
        uint256 _updatedUnpaidLeaves
    ) public {
        employee.updateEmployee(
            _idToUpdate,
            Employee.EmployeeDetails(
                10,
                createdName1,
                _updatedAnnualSalary,
                createdDailySalary1,
                createdTotalAnnualLeave1,
                _updatedLeaveTaken,
                _updatedUnpaidLeaves,
                createdWalletAddress1,
                false
            )
        );
    }
}
