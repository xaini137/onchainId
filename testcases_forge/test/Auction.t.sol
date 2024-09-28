// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Import necessary contracts and libraries
import {Test, console} from "forge-std/Test.sol";
import {Proton} from "../src/ERC1404/updated1404_flattened.sol";
import {TransferRestrictions} from "../src/ERC1404/Restriction/restriction_flatten.sol";
import {ProtonAuction, IERC20} from "../src/Auction/auction1404.sol";
import {MyToken} from "../src/ERC20/ERC20_flatten.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract ProtonTest is Test {
    // Declare public variables for contracts
    Proton public proton;
    TransferRestrictions public transferRestrictions;
    ProtonAuction public protonAuction;
    MyToken public USDT;
    //  IERC20 public USDT_address;
    // Declare public variables for test addresses
    address admin = address(1);
    address pauser = address(2);
    address minter = address(3);
    address registrar = address(4);
    address whitelister = address(5);
    address user1 = address(0x6);
    address user2 = address(0x7);
    address user3 = address(0x8);
    address user4 = address(0x9);
    address fundsWallet = address(0x10);
    address owner = address(this);

    // Setup function to initialize contracts and test environment
    function setUp() public {
        USDT = new MyToken();
        // Proton proton;
        // TransferRestrictions transferRestrictions;

        // Fund test addresses with 100 ether each
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
        vm.deal(user3, 100 ether);
        vm.deal(user4, 100 ether);
        proton = new Proton(admin, pauser, minter, registrar, whitelister);
        transferRestrictions = new TransferRestrictions(address(proton));
        // Update transfer restrictions
        vm.prank(admin);
        proton.updateTransferRestrictions(address(transferRestrictions));
        // Initialize ProtonAuction contract
        protonAuction = new ProtonAuction(address(proton), fundsWallet);
        //   protonAuction.startAuction();
    }

    //     //function for start the auction
    function test_start_auction() public {
        assertEq(protonAuction.isPaused(), true);
        assertEq(protonAuction.owner(), owner);
        protonAuction.startAuction();
        assertEq(protonAuction.isPaused(), false);
        assertEq(protonAuction.getCurrentDay(), 1);
    }

    function test_set_price() public {
        protonAuction.setPrice(10 ether);
        assertEq(protonAuction.tokenPrice(), 10 ether);
    }

    function test_set_funds_wallet() public {
        protonAuction.setFundsWallet(fundsWallet);
        assertEq(protonAuction.fundsWallet(), fundsWallet);
    }

    function test_get_daily_details() public {
        protonAuction.setDailyDetails(1, 100, 3);
        (
            uint256 tokensDaily,
            uint256 tokensSold,
            uint256 bonusMultiplier,

        ) = protonAuction.dailyAuctions(1);
        assertEq(tokensDaily, 100, "tokendaily");
        assertEq(tokensSold, 0, "tokens sold");
        assertEq(bonusMultiplier, 0, "bonus multiplier");
    }

    function test_get_auction_time() public {
        protonAuction.startAuction();
        (uint256 currentRound, uint256 start, uint256 end) = protonAuction
            .AuctionTime();

        assertEq(start, block.timestamp, "start time");
        //console.log("auction time", end, start, block.timestamp , currentRound);
        assertEq(end, start + 7 days, "end time");
    }

    function test_get_current_day_after_end() public {
        protonAuction.startAuction();
        //  vm.warp(protonAuction.currentRoundEnd() + 1 days);
        assertEq(protonAuction.currentRound(), 1);
    }

    function test_cant_transfer_without_admin_set_token() public {
        vm.startPrank(minter);
        proton.mint(address(protonAuction), 100 ether);
        proton.mint(user2, 100 ether);
        assertEq(proton.balanceOf(address(protonAuction)), 100 ether);
        assertEq(proton.balanceOf(user2), 100 ether);
        vm.startPrank(owner);
        protonAuction.startAuction();
        USDT.mint(user2, 100 ether);
        assertEq(USDT.balanceOf(user2), 100 ether);
        vm.startPrank(user2);
        USDT.approve(address(protonAuction), 100 ether);
        assertEq(USDT.allowance(user2, address(protonAuction)), 100 ether);
        vm.expectRevert("Invalid token address");
        protonAuction.buyTokens(IERC20(address(USDT)), 1 ether);
    }

    function test_buy_tokens_without_registration() public {
        vm.startPrank(minter);
        proton.mint(address(protonAuction), 100 ether);
        proton.mint(user2, 100 ether);
        assertEq(proton.balanceOf(address(protonAuction)), 100 ether);
        assertEq(proton.balanceOf(user2), 100 ether);

        vm.startPrank(registrar);
        proton.register(address(protonAuction), "Contract");
        vm.startPrank(whitelister);
        proton.setWhitelist(address(protonAuction), true, "NonUS");
        vm.startPrank(owner);
        protonAuction.startAuction();

        protonAuction.setToken(IERC20(address(USDT)));
        USDT.mint(user2, 100 ether);
        assertEq(USDT.balanceOf(user2), 100 ether);
        vm.startPrank(user2);
        USDT.approve(address(protonAuction), 100 ether);
        assertEq(USDT.allowance(user2, address(protonAuction)), 100 ether);
        // for (uint8 i = 1; i <= 100; i++) {
        protonAuction.buyTokens(IERC20(address(USDT)), 1 ether);
        assertEq(proton.balanceOf(user2), 101 ether);

        //     currentTime = block.timestamp + 150;
        //    console.log("current time", block.timestamp, currentTime);
        //  console.log("get total lock amount", proton.getLockedAmount(user2));
        //     vm.warp(currentTime);
        // }
        // //console.log( "current unlocked amount",proton.balanceOf(user2), proton.balanceOf(user2) - proton.getLockedAmount(user2) );
        // assertEq(
        //     proton.getLockedAmount(user2),
        //     23 ether,
        //     "checking locked amount"
        // );
        // assertEq(proton.balanceOf(user2), 100 ether, "user balance check 142");
        // uint avail = proton.balanceOf(user2) - proton.getLockedAmount(user2);
        // proton.transfer(owner, avail);
        // assertEq(USDT.balanceOf(user2), 0 ether, " checking usdt balance ");

        // vm.warp(currentTime + 500);
        // assertEq(proton.balanceOf(user2), 23 ether, "user balance check");
        // vm.stopPrank();
    }

    function test_cant_transfer_after_buy_without_registration() public {
        vm.startPrank(minter);
        proton.mint(address(protonAuction), 100 ether);
        proton.mint(user2, 100 ether);
        assertEq(proton.balanceOf(address(protonAuction)), 100 ether);
        assertEq(proton.balanceOf(user2), 100 ether);

        vm.startPrank(registrar);
        proton.register(address(protonAuction), "Contract");
        vm.startPrank(whitelister);
        proton.setWhitelist(address(protonAuction), true, "NonUS");
        vm.startPrank(owner);
        protonAuction.startAuction();

        protonAuction.setToken(IERC20(address(USDT)));
        USDT.mint(user2, 100 ether);
        assertEq(USDT.balanceOf(user2), 100 ether);
        vm.startPrank(user2);
        USDT.approve(address(protonAuction), 100 ether);
        assertEq(USDT.allowance(user2, address(protonAuction)), 100 ether);
        // for (uint8 i = 1; i <= 100; i++) {
        protonAuction.buyTokens(IERC20(address(USDT)), 1 ether);
        assertEq(proton.balanceOf(user2), 101 ether);
        // Now try to transfer
        vm.expectRevert(
            "The transfer was restricted due to no user type assigned"
        );
        proton.transfer(user3, 1 ether);
    }

    function test_cant_transfer_after_registration_before_time_lock_over()
        public
    {
        vm.startPrank(minter);
        proton.mint(address(protonAuction), 100 ether);
        assertEq(proton.balanceOf(address(protonAuction)), 100 ether);
        vm.startPrank(registrar);
        proton.register(address(protonAuction), "Contract");
        vm.startPrank(whitelister);
        proton.setWhitelist(address(protonAuction), true, "NonUS");
        vm.startPrank(owner);
        protonAuction.startAuction();
        protonAuction.setToken(IERC20(address(USDT)));
        USDT.mint(user2, 100 ether);
        assertEq(USDT.balanceOf(user2), 100 ether);
        vm.startPrank(user2);
        USDT.approve(address(protonAuction), 100 ether);
        assertEq(USDT.allowance(user2, address(protonAuction)), 100 ether);
        protonAuction.buyTokens(IERC20(address(USDT)), 1 ether);
        assertEq(proton.balanceOf(user2), 1 ether);
        vm.startPrank(registrar);
        proton.register(user2, "NonUS");
        vm.startPrank(whitelister);
        proton.setWhitelist(user2, true, "NonUS");
        vm.startPrank(user2);
        console.log("before transfer", proton.balanceOf(user2));
        console.log("lock", proton.getLockedAmount(user2));

        // console.log(proton.getLockedAmount(user2));
        vm.expectRevert(
            "The transfer was restricted due to timelocked tokens."
        );
        proton.transfer(user3, 100 ether);
        console.log("after  transfer", proton.balanceOf(user2));
    }

    function test_transfer_after_registration_and_after_time_lock_over()
        public
    {
        vm.startPrank(minter);
        proton.mint(address(protonAuction), 100 ether);
        assertEq(proton.balanceOf(address(protonAuction)), 100 ether);
        vm.startPrank(registrar);
        proton.register(address(protonAuction), "Contract");
        vm.startPrank(whitelister);
        proton.setWhitelist(address(protonAuction), true, "NonUS");
        vm.startPrank(owner);
        protonAuction.startAuction();
        protonAuction.setToken(IERC20(address(USDT)));
        USDT.mint(user2, 100 ether);
        assertEq(USDT.balanceOf(user2), 100 ether);
        vm.startPrank(user2);
        USDT.approve(address(protonAuction), 100 ether);
        assertEq(USDT.allowance(user2, address(protonAuction)), 100 ether);
        protonAuction.buyTokens(IERC20(address(USDT)), 1 ether);
        assertEq(proton.balanceOf(user2), 1 ether);
        vm.startPrank(registrar);
        proton.register(user2, "NonUS");
        vm.startPrank(whitelister);
        proton.setWhitelist(user2, true, "NonUS");
        vm.startPrank(user2);
        console.log("before transfer", proton.balanceOf(user2));
        console.log("lock", proton.getLockedAmount(user2));

        (uint256[] memory amounts, uint256[] memory releaseTimes) = proton.checkLockup(user2);

        for (uint i = 0; i < amounts.length; i++) {
            console.log("lock amounts", amounts[i], amounts[i] / 10 ** 18);
        }

        for (uint i = 0; i < releaseTimes.length; i++) {
            console.log("lock releaseTimes", releaseTimes[i]);
        }
        console.log("current time", block.timestamp);
        //checking transfering before lock time
        uint extendtime = block.timestamp + 170;
        vm.warp(extendtime);
        console.log(
            "time extend for checking lock functionality before transfer token time not over,",
            extendtime
        );
        vm.expectRevert(
            "The transfer was restricted due to timelocked tokens."
        );
        proton.transfer(user3, 1 ether);

        extendtime = block.timestamp + 200;
        vm.warp(extendtime);
        console.log("time extend for checking lock functionality,", extendtime);
        proton.transfer(user3, 1 ether);
        console.log("after  transfer", proton.balanceOf(user2));
    }

    function test_transfer_after_multiple_buys_and_time_lock() public {
        // Setup
        vm.startPrank(minter);
        proton.mint(address(protonAuction), 1000 ether);
        vm.stopPrank();

        vm.startPrank(registrar);
        proton.register(address(protonAuction), "Contract");
        proton.register(user2, "NonUS");
        vm.stopPrank();

        vm.startPrank(whitelister);
        proton.setWhitelist(address(protonAuction), true, "NonUS");
        proton.setWhitelist(user2, true, "NonUS");
        vm.stopPrank();

        vm.prank(owner);
        protonAuction.startAuction();
        protonAuction.setToken(IERC20(address(USDT)));

        // Mint USDT for user2
        USDT.mint(user2, 100 ether);

        // User2 buys tokens 100 times
        vm.startPrank(user2);
        USDT.approve(address(protonAuction), 100 ether);
        
        for (uint i = 0; i < 100; i++) {
          
            console.log("before buy",block.timestamp);
            protonAuction.buyTokens(IERC20(address(USDT)), 1 ether);
              vm.warp(i + 10); // Increase time by 10 seconds between purchases
                console.log("after buy",block.timestamp);
        }

        

        // Check initial balances and locked amounts
        uint256 initialBalance = proton.balanceOf(user2);
        uint256 initialLockedAmount = proton.getLockedAmount(user2);
        console.log("Initial balance:              ", initialBalance);
        console.log("Initial locked amount:        ", initialLockedAmount);

        // Try to transfer immediately after purchases (should fail)
        vm.expectRevert("The transfer was restricted due to timelocked tokens.");
        proton.transfer(user3, initialBalance);

        // Advance time by 100 seconds
        vm.warp(block.timestamp + 100);

        // Check balances and locked amounts after time advance
        uint256 balanceAfterTimeSkip = proton.balanceOf(user2);
        uint256 lockedAmountAfterTimeSkip = proton.getLockedAmount(user2);
        console.log("Balance after time skip:      ", balanceAfterTimeSkip);
        console.log("Locked amount after time skip:", lockedAmountAfterTimeSkip);

        // Calculate transferable amount
        uint256 transferableAmount = balanceAfterTimeSkip - lockedAmountAfterTimeSkip;
        console.log("Transferable amount:", transferableAmount);

        // Try to transfer more than the transferable amount (should fail)
        vm.expectRevert("The transfer was restricted due to timelocked tokens.");
        proton.transfer(user3, transferableAmount + 1);

        // Transfer the exact transferable amount (should succeed)
        proton.transfer(user3, transferableAmount);

        // Verify the transfer
        assertEq(proton.balanceOf(user3), transferableAmount, "Transfer to user3 failed");
         vm.expectRevert("The transfer was restricted due to timelocked tokens.");
        proton.transfer(user2, lockedAmountAfterTimeSkip);
        console.log("after transfer " , proton.balanceOf(user2));
         assertEq(proton.balanceOf(user2), lockedAmountAfterTimeSkip, "Incorrect remaining balance for user2");

        vm.stopPrank();
    }
}