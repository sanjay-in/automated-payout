// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {DeployUSDC} from "../../script/DeployUSDC.s.sol";
import {USDC} from "../../src/USDC.sol";

contract TestUSDC is Test {
    USDC public usdc;
    uint256 public constant INITIAL_SUPPLY = 10000;

    function setUp() public {
        DeployUSDC deployUSDC = new DeployUSDC();
        usdc = deployUSDC.run();
    }

    // Constructor tests
    function testInitialAmount() public view {
        uint256 totalSupply = usdc.getTotalSupply();
        assertEq(INITIAL_SUPPLY, totalSupply);
    }

    function testName() public view {
        string memory expetedName = "USDCoin";
        string memory tokenName = usdc.name();

        assertEq(expetedName, tokenName);
    }

    function testSymbol() public view {
        string memory expetedSymbol = "USDC";
        string memory tokenSymbol = usdc.symbol();

        assertEq(expetedSymbol, tokenSymbol);
    }

    function testOwner() public view {
        address deployerAddress = msg.sender;
        address ownerAddress = usdc.i_owner();
        assertEq(deployerAddress, ownerAddress);
    }

    // Functions test
    function testMintFunction() public {
        address USER = makeAddr("USER");
        uint256 amountToMint = 200;

        vm.prank(msg.sender);
        usdc.mint(USER, amountToMint);

        uint256 userBalance = usdc.balanceOf(USER);
        assertEq(amountToMint, userBalance);

        uint256 expectedTotalSupply = INITIAL_SUPPLY + amountToMint;
        uint256 totalSupply = usdc.getTotalSupply();
        assertEq(expectedTotalSupply, totalSupply);
    }

    function testZeroMint() public {
        address USER = makeAddr("USER");
        uint256 amountToMint = 0;

        vm.prank(msg.sender);
        vm.expectRevert(USDC.USDC__InvalidAmount.selector);
        usdc.mint(USER, amountToMint);
    }

    function testBurnFunction() public {
        address USER = makeAddr("USER");
        uint256 amountToMint = 200;
        uint256 amountToBurn = 100;

        vm.startPrank(msg.sender);
        usdc.mint(USER, amountToMint);
        usdc.burn(USER, amountToBurn);
        vm.stopPrank();

        uint256 expectedUserBalance = amountToMint - amountToBurn;
        uint256 userBalance = usdc.balanceOf(USER);
        assertEq(expectedUserBalance, userBalance);

        uint256 expectedTotalSupply = INITIAL_SUPPLY + expectedUserBalance;
        uint256 totalSupply = usdc.getTotalSupply();
        assertEq(expectedTotalSupply, totalSupply);
    }

    function testZeroBurn() public {
        address USER = makeAddr("USER");
        uint256 amountToBurn = 0;

        vm.prank(msg.sender);
        vm.expectRevert(USDC.USDC__InvalidAmount.selector);
        usdc.mint(USER, amountToBurn);
    }
}
