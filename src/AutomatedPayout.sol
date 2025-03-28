// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IPermit2, IAllowanceTransfer} from "permit2/contracts/interfaces/IPermit2.sol";
import {USDC} from "./USDC.sol";
import {Employee} from "./Employee.sol";

contract AutomatedPayout is Ownable, AccessControl {
    error AutomatedPayout__UnauthorizedSpender();

    USDC public immutable i_usdc;
    Employee public immutable i_employee;
    IPermit2 public immutable i_permit2;

    uint256 public s_percentageFee = 1;

    bytes32 internal constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    constructor(address _usdc, address _employeeContract, address _permit2, address _manager) Ownable(msg.sender) {
        i_usdc = USDC(_usdc);
        i_employee = Employee(_employeeContract);
        i_permit2 = IPermit2(_permit2);
        grantRole(MANAGER_ROLE, _manager);
    }

    function approveToken() external {
        i_usdc.approve(address(this), type(uint256).max);
    }

    function payout(IAllowanceTransfer.PermitSingle calldata _permitSingle, bytes calldata signature) external onlyRole(MANAGER_ROLE) {
        _allowanceTransferWithPermit(_permitSingle, signature);
    }

    /**
     * @notice Updates the percentage of the fee per transaction
     * @param _percent you want to update
     */
    function updatePercentageFee(uint256 _percent) external onlyOwner {
        s_percentageFee = _percent;
    }

    function addManager(address _address) external onlyRole(MANAGER_ROLE) {
        grantRole(MANAGER_ROLE, _address);
    }

    function _allowanceTransferWithPermit(IAllowanceTransfer.PermitSingle calldata _permitSingle, bytes calldata signature) internal {
        if (_permitSingle.spender != address(this)) {
            revert AutomatedPayout__UnauthorizedSpender();
        }
        i_permit2.permit(msg.sender, _permitSingle, signature);
        _transferPayments();
    }

    function _transferPayments() internal {
        uint256 totalPaymentMade;
        Employee.EmployeeDetails[] memory employees = i_employee.getActiveEmployees();

        for (uint i = 0; i < employees.length; i++) {
            uint256 monthlySalary = _calculatePaidLeave(employees[i]);
            totalPaymentMade = monthlySalary;
            i_permit2.transferFrom(msg.sender, employees[i].walletAddress,  uint160(monthlySalary), address(i_usdc));
        }

        uint160 protocolFee = uint160(_calculatePercentage(totalPaymentMade));
        i_permit2.transferFrom(msg.sender, address(this), protocolFee, address(i_usdc));
    }

    // CHECK FOR DECIMALS
    function _calculatePercentage(uint256 _amount) internal view returns(uint256) {
        return (_amount * s_percentageFee) / 100;
    }

    // CHECK FOR DECIMALS
    function _calculatePaidLeave(Employee.EmployeeDetails memory _employeeDetails) internal pure returns(uint256 totalMonthlySalary) {
        uint256 totalUnpaidLeavesTaken = _employeeDetails.unpaidLeaves;
        uint256 dailySalary = _employeeDetails.dailySalary;
        uint256 monthlySalary = _employeeDetails.annualSalary / 12;
        totalMonthlySalary = monthlySalary - (dailySalary * totalUnpaidLeavesTaken);
    }
}
