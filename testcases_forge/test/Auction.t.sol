// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Import necessary contracts and libraries
import {Test, console} from "forge-std/Test.sol";
import {Proton} from "../src/ERC1404/ERC1404_flatten.sol";
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

    address public owner;
    address public user1;
    address public user2;
    address public user3;
    address public user4;
    address public user5;
    address public user6;
    address public fundsWallet;

    // Setup function to initialize contracts and test environment
    function setUp() public {
        // Initialize USDT token
        USDT = new MyToken();
        // USDT_address = IERC20(address(USDT));
        // Initialize Proton contract
        proton = new Proton();
        // Initialize TransferRestrictions contract with Proton address
        transferRestrictions = new TransferRestrictions(address(proton));
        // Update Proton contract with TransferRestrictions address
        proton.updateTransferRestrictions(address(transferRestrictions));
        // Set up test addresses
        user1 = address(0x1);
        user2 = address(0x2);
        user3 = address(0x3);
        user4 = address(0x4);
        user5 = address(0x5);
        user6 = address(0x6);
        fundsWallet = address(0x7);
        owner = address(this);
        // Fund test addresses with 100 ether each
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
        vm.deal(user3, 100 ether);
        vm.deal(user4, 100 ether);
        vm.deal(user5, 100 ether);
        vm.deal(user6, 100 ether);
        // Initialize ProtonAuction contract
        protonAuction = new ProtonAuction(address(proton), fundsWallet);
        //   protonAuction.startAuction();
    }

    //function for start the auction
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
        (uint256 start, uint256 end) = protonAuction.AuctionTime();

        assertEq(start, block.timestamp, "start time");
        console.log("auction time", end, start, block.timestamp);
        assertEq(end, start + 7 days, "end time");
    }

    function test_get_current_day_after_end() public {
        protonAuction.startAuction();

        vm.warp(protonAuction.currentRoundEnd() + 1 days);
        assertEq(protonAuction.getCurrentDay(), 8);
    }

    function test_buy_tokens() public {
        proton.addWhitelister(owner);

        proton.setWhitelist(owner, true, "NonUS");
        proton.register(owner, "NonUS");
        proton.addWhitelister(user2);
        proton.setWhitelist(user2, true, "NonUS");
        proton.register(user2, "NonUS");

        proton.addWhitelister(address(protonAuction));
        proton.setWhitelist(address(protonAuction), true, "Contract");
        proton.register(address(protonAuction), "Contract");
        proton.transfer(address(protonAuction), 100 ether);

        protonAuction.startAuction();
        // proton.mint(user2, 100 ether);
        // Mint USDT tokens to user1
        USDT.mint(user2, 100 ether);
        assertEq(USDT.balanceOf(user2), 100 ether);
        // Start simulating user1's transactions
        vm.startPrank(user2);
        // Approve ProtonAuction contract to spend USDT on behalf of user1
        USDT.approve(address(protonAuction), 100 ether);
        assertEq(USDT.allowance(user2, address(protonAuction)), 100 ether);
        // Action: Buy tokens, pass USDT contract address

        assertEq(proton.getUserType(user2), "NonUS");
        uint currentTime;
        for (uint8 i = 1; i <= 100; i++) {
            protonAuction.buyTokens(IERC20(address(USDT)), user2, 1 ether);
            currentTime = block.timestamp + 150;
            console.log("current time", block.timestamp, currentTime);
            console.log("get total lock amount", proton.getLockedAmount(user2));
            vm.warp(currentTime);
        }
        console.log(
            "current unlocked amount",
            proton.balanceOf(user2),
            proton.balanceOf(user2) - proton.getLockedAmount(user2)
        );
        assertEq(
            proton.getLockedAmount(user2),
            23 ether,
            "checking locked amount"
        );
        assertEq(proton.balanceOf(user2), 100 ether, "user balance check 142");
        uint avail = proton.balanceOf(user2) - proton.getLockedAmount(user2);
        proton.transfer(owner, avail);
        assertEq(USDT.balanceOf(user2), 0 ether, " checking usdt balance ");

        vm.warp(currentTime + 500);
        assertEq(proton.balanceOf(user2), 23 ether, "user balance check");
        vm.stopPrank();
    }

    function test_buy_tokens_multiple_users() public {
        // Setup whitelist and mint tokens
        address[] memory users = new address[](3);
        users[0] = user1;
        users[1] = user2;
        users[2] = user3;
        proton.addWhitelister(owner);
        proton.register(owner, "NonUS");
        proton.setWhitelist(owner, true, "NonUS");
        for (uint i = 0; i < users.length; i++) {
            proton.setWhitelist(users[i], true, "NonUS");
            proton.register(users[i], "NonUS");
            USDT.mint(users[i], 100 ether);
            console.log("User", i + 1,"USDT balance:",USDT.balanceOf(users[i])
            );
        }

        proton.setWhitelist(address(protonAuction), true, "Contract");
        proton.register(address(protonAuction), "Contract");
        proton.mint(address(protonAuction), 1000000 ether);

        protonAuction.startAuction();
        console.log("Auction started");

        uint currentTime = block.timestamp;
        console.log("currentTime",currentTime);
        for (uint day = 1; day <= 100; day++) {
            console.log("\nDay", day);
            for (uint i = 0; i < users.length; i++) {
                vm.startPrank(users[i]);
                USDT.approve(address(protonAuction), 1 ether);
                uint256 tokensBefore = proton.balanceOf(users[i]);
                console.log("tokensBefore",tokensBefore);
                uint256 usdtBefore = USDT.balanceOf(users[i]);
                console.log("usdtBefore",usdtBefore);
                protonAuction.buyTokens(IERC20(address(USDT)),users[i],1 ether);
                uint256 tokensAfter = proton.balanceOf(users[i]);
                uint256 usdtAfter = USDT.balanceOf(users[i]);
                uint256 lockedAmount = proton.getLockedAmount(users[i]);
                vm.stopPrank();
            }
            currentTime += 300 seconds;
            vm.warp(currentTime);
        }

        console.log("\nFinal balances after 7 days:");
        for (uint i = 0; i < users.length; i++) {
            uint256 totalBalance = proton.balanceOf(users[i]);
            uint256 lockedAmount = proton.getLockedAmount(users[i]);
            uint256 availableBalance = totalBalance - lockedAmount;

            console.log("User", i + 1, "total balance:", totalBalance);
            console.log("User", i + 1, "locked amount:", lockedAmount);
            console.log("User", i + 1, "available balance:", availableBalance);
            vm.startPrank(users[i]);
             uint left = availableBalance -  11000000000000000000 ;
             console.log("left" , left);
           require( proton.transfer(owner, left));
              totalBalance = proton.balanceOf(users[i]);
             lockedAmount = proton.getLockedAmount(users[i]);
             availableBalance = totalBalance - lockedAmount;
            // uint amount = totalBal ance + 1000000000000000000 ;  
            //  vm.expectRevert("The transfer was restricted due to timelocked tokens.");
                 console.log("User", i + 1, "total balance: 1", totalBalance);
            console.log("User", i + 1, "locked amount: 1", lockedAmount);
            console.log("User", i + 1, "available balance: 1", availableBalance );
            console.log("checking transfer 227");

             require( proton.transfer(owner, availableBalance + 1));
              totalBalance = proton.balanceOf(users[i]);
             lockedAmount = proton.getLockedAmount(users[i]);
             availableBalance = totalBalance - lockedAmount;
            console.log("User", i + 1, "total balance: 1", totalBalance);
            console.log("User", i + 1, "locked amount: 1", lockedAmount);
            console.log("User", i + 1, "available balance: 1", availableBalance );
             vm.stopPrank();
        }
    }
}
