// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title USDC Contract
 * @author Sanjay 24 Mar 2025
 * @notice This is a stablecoin pegged to the price of dollar
 */
contract USDC is ERC20, Ownable {
    // Errors
    error USDC__InvalidAmount();
    error USDC__BurnAmountExceedsTotalSupply();

    // State variables
    address public immutable i_owner;
    uint256 internal s_totalSupply;

    // Functions
    constructor(uint256 _initialMintAmount) ERC20("USDCoin", "USDC") Ownable(msg.sender) {
        i_owner = msg.sender;
        _mint(i_owner, _initialMintAmount);
        s_totalSupply = _initialMintAmount;
    }

    /**
     * @notice Mints USDC to the specified address
     * @param _to address to mint
     * @param _amount of USD to mint
     */
    function mint(address _to, uint256 _amount) external onlyOwner {
        if (_amount <= 0) {
            revert USDC__InvalidAmount();
        }
        s_totalSupply += _amount;
        _mint(_to, _amount);
    }

    /**
     * @notice Removes specified amount of USDC from circulation
     * @param _amount of USDC to burn
     */
    function burn(address _to, uint256 _amount) external onlyOwner {
        if (_amount <= 0) {
            revert USDC__InvalidAmount();
        }
        if (_amount > s_totalSupply) {
            revert USDC__BurnAmountExceedsTotalSupply();
        }
        s_totalSupply -= _amount;
        _burn(_to, _amount);
    }

    // Getter functions
    function getTotalSupply() external view returns (uint256) {
        return s_totalSupply;
    }
}
