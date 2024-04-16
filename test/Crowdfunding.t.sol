// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Fundraiser} from "../src/Crowdfunding.sol";

contract FundraiserTest is Test {
    Fundraiser fundraiser;
    address owner;
    address contributor;
    address contributor2;

    function setUp() public {
        owner = address(this);
        contributor = makeAddr("contributor");
        vm.deal(contributor, 5 ether);
        vm.deal(contributor2, 5 ether);

        fundraiser = new Fundraiser(1 ether);
        vm.startPrank(owner);
        fundraiser.transferOwnership(owner);
        vm.stopPrank();
    }

    function test_SetUpState() public {
        assertEq(fundraiser.goal(), 1 ether);
        assertFalse(fundraiser.canceled());
        assertFalse(fundraiser.succeeded());
    }

    function test_contribute_Works() public {
        vm.prank(contributor);
        fundraiser.contribute{value: 0.5 ether}();
        assertEq(fundraiser.totalContributed(), 0.5 ether);
        assertEq(fundraiser.contributions(contributor), 0.5 ether);
    }

    function test_contribute_RevertWhen_ContributingAfterCancel() public {
        fundraiser.cancelFundraiser();
        vm.expectRevert("The fundraising was canceled");
        vm.prank(contributor);
        fundraiser.contribute{value: 0.5 ether}();
    }

    function test_contribute_RevertWhen_ContributingAfterSuccess() public {
        vm.prank(contributor);
        fundraiser.contribute{value: 1 ether}(); // Goal reached

        vm.expectRevert("Goal has already been reached");
        fundraiser.contribute{value: 0.5 ether}(); // Should revert
    }

    function test_goalReached_GoalIsReached() public {
        vm.prank(contributor);
        fundraiser.contribute{value: 1 ether}();
        assertTrue(fundraiser.goalReached());
    }

    function test_goalReached_GoalIsNotReached() public {
        vm.prank(contributor);
        fundraiser.contribute{value: 0.5 ether}();
        assertFalse(fundraiser.goalReached());
    }

    function test_withdraw_Works() public {
        vm.startPrank(contributor);
        fundraiser.contribute{value: 0.5 ether}();
        assertEq(fundraiser.contributions(contributor), 0.5 ether); // contributions made

        fundraiser.withdraw();
        vm.stopPrank();
        assertEq(fundraiser.contributions(contributor), 0); // contributions withdrawn
    }

    function test_withdraw_WorksAfterGoalReached() public {
        vm.startPrank(contributor);
        fundraiser.contribute{value: 2 ether}();

        assertEq(fundraiser.totalContributed(), 2 ether);
        assertEq(fundraiser.contributions(contributor), 2 ether); // contributions made
        assertTrue(fundraiser.goalReached());

        fundraiser.withdraw();
        assertEq(fundraiser.contributions(contributor), 0); // contributions withdrawn
        assertEq(fundraiser.totalContributed(), 0 ether); // totalContributed reset
        assertFalse(fundraiser.goalReached());
        vm.stopPrank();
    }

    function test_withdraw_RevertWhen_NoContributions() public {
        vm.expectRevert("No contributions to withdraw");
        vm.startPrank(contributor);
        fundraiser.withdraw(); // Should revert

        fundraiser.contribute{value: 2 ether}();
        assertEq(fundraiser.contributions(contributor), 2 ether); // contributions made
        vm.stopPrank();

        vm.expectRevert("No contributions to withdraw");
        vm.prank(contributor2);
        fundraiser.withdraw(); // Different contributor - Should revert
    }

    /* function test_payout_Works() public {
        vm.prank(contributor);
        fundraiser.contribute{value: 1 ether}();
        assertTrue(fundraiser.goalReached());
        uint256 preBalance = owner.balance;
        fundraiser.payout();
        uint256 postBalance = owner.balance;
        assertEq(postBalance - preBalance, 1 ether);
        assertTrue(fundraiser.succeeded());
    } */

    function test_cancelFundraiser_Works() public {
        fundraiser.cancelFundraiser();
        assertTrue(fundraiser.canceled());
    }
}
