// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract Employee is Ownable, AccessControl {
    // Errors
    error Employee__InvalidWalletAddress();
    error Employee__InvalidEmployeeID();

    // Type declaration
    struct EmployeeDetails {
        uint256 id;
        string name;
        uint256 annualSalary;
        uint256 dailySalary;
        uint256 totalAnnualLeave;
        uint256 leaveTaken;
        uint256 unpaidLeaves;
        address walletAddress;
        bool active;
    }

    // State vairables
    uint256 internal s_idNonce = 0;
    bytes32 internal constant MANAGER = keccak256("MANAGER");

    mapping(uint256 id => EmployeeDetails employee) public s_employees;
    mapping(uint256 id => EmployeeDetails employee) public s_employeeRecord;

    // Events
    event EmployeeAdded(uint256 indexed id, EmployeeDetails employeeDetails);
    event EmployeeRemoved(uint256 indexed id);
    event EmployeeUpdated(uint256 indexed id, EmployeeDetails employeeDetails);

    // Functions
    constructor() Ownable(msg.sender) {
        _grantRole(MANAGER, msg.sender);
    }

    /**
     * @notice Add new employee
     * @param _name of the employee
     * @param _annualSalary in USD
     * @param _dailySalary in USD
     * @param _totalAnnualLeave eligible for the employee
     * @param _walletAddress address to which monthly salary to be credited
     */
    function addEmployee(
        string memory _name,
        uint256 _annualSalary,
        uint256 _dailySalary,
        uint256 _totalAnnualLeave,
        address _walletAddress
    ) external onlyRole(MANAGER) {
        if (_walletAddress == address(0)) {
            revert Employee__InvalidWalletAddress();
        }

        s_idNonce++;

        EmployeeDetails memory currentEmployee = EmployeeDetails(
            s_idNonce, _name, _annualSalary, _dailySalary, _totalAnnualLeave, 0, 0, _walletAddress, true
        );

        s_employees[s_idNonce] = currentEmployee;
        s_employeeRecord[s_idNonce] = currentEmployee;

        emit EmployeeAdded(s_idNonce, currentEmployee);
    }

    /**
     * @notice Remove the past employee
     * @param _id of the employee to remove
     */
    function removeEmployee(uint256 _id) external onlyRole(MANAGER) {
        if (!s_employees[_id].active) {
            revert Employee__InvalidEmployeeID();
        }
        s_employeeRecord[_id].active = false;
        delete s_employees[_id];

        emit EmployeeRemoved(_id);
    }

    /**
     * @notice Update the false entry or change in details
     * @param _id of the employee to update
     * @param _employeeDetails fields to update
     */
    function updateEmployee(uint256 _id, EmployeeDetails memory _employeeDetails) external onlyRole(MANAGER) {
        EmployeeDetails memory updatedFields = EmployeeDetails({
            id: _id,
            name: _employeeDetails.name,
            annualSalary: _employeeDetails.annualSalary,
            dailySalary: _employeeDetails.dailySalary,
            totalAnnualLeave: _employeeDetails.totalAnnualLeave,
            leaveTaken: _employeeDetails.leaveTaken,
            unpaidLeaves: _employeeDetails.unpaidLeaves,
            walletAddress: _employeeDetails.walletAddress,
            active: s_employees[_id].active
        });
        s_employees[_id] = updatedFields;

        emit EmployeeUpdated(_id, updatedFields);
    }

    /**
     * @notice Get employee detail (past/active)
     * @param _id of the employee to list details
     */
    function getEmployeeDetails(uint256 _id) external view returns (EmployeeDetails memory) {
        return s_employeeRecord[_id];
    }

    /**
     * @notice Fetch all active employees
     */
    function getActiveEmployees() external view returns (EmployeeDetails[] memory) {
        uint256 activeEmployeeCount;
        for (uint256 i = 1; i <= s_idNonce; i++) {
            if (s_employees[i].active) {
                activeEmployeeCount++;
            }
        }

        EmployeeDetails[] memory activeEmployees = new EmployeeDetails[](activeEmployeeCount);

        uint256 arrayCount = 0;
        for (uint256 i = 1; i <= s_idNonce; i++) {
            if (s_employees[i].active) {
                activeEmployees[arrayCount] = s_employees[i];
                arrayCount++;
            }
        }
        return activeEmployees;
    }
}
