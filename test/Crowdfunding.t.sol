// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Fundraiser} from "../src/Crowdfunding.sol";
import {console} from "forge-std/console.sol";

contract FundraiserTest is Test {
    Fundraiser fundraiser;
    address owner;
    address contributor;
    address contributor2;

    function setUp() public {
        owner = makeAddr("owner");
        contributor = makeAddr("contributor");
        vm.deal(contributor, 5 ether);
        vm.deal(contributor2, 5 ether);

        fundraiser = new Fundraiser(1 ether);
        fundraiser.transferOwnership(owner);
    }

    function test_SetUpState() public {
        assertEq(fundraiser.goal(), 1 ether);
        assertFalse(fundraiser.canceled());
        assertFalse(fundraiser.succeeded());
        assertEq(fundraiser.owner(), owner);
    }

    function test_contribute_Works() public {
        vm.prank(contributor);
        fundraiser.contribute{value: 0.5 ether}();
        assertEq(fundraiser.totalContributed(), 0.5 ether);
        assertEq(fundraiser.contributions(contributor), 0.5 ether);
    }

    function test_contribute_RevertWhen_ContributingAfterCancel() public {
        vm.prank(owner);
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

    function test_withdraw_RevertsIf_PayoutAlreadyMade() public {
        vm.prank(contributor);
        fundraiser.contribute{value: 2 ether}();

        vm.prank(owner);
        fundraiser.payout(owner);

        vm.expectRevert("Your funds were already used to buy a core");
        vm.prank(contributor);
        fundraiser.withdraw();
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

    function test_cancelFundraiser_Works() public {
        vm.prank(owner);
        fundraiser.cancelFundraiser();
        assertTrue(fundraiser.canceled());
    }

    function test_cancelFundraiser_RevertWhen_CalledNotOwner() public {
        vm.expectRevert();
        vm.prank(contributor);
        fundraiser.cancelFundraiser();
    }

    function test_cancelFundraiser_RevertWhen_CancelTwice() public {
        vm.startPrank(owner);
        fundraiser.cancelFundraiser();
        vm.expectRevert("Fundraising is already canceled");
        fundraiser.cancelFundraiser();
        vm.stopPrank();
    }

    function test_cancelFundraiser_RevertWhen_PayoutMade() public {
        vm.prank(contributor);
        fundraiser.contribute{value: 1 ether}();
        vm.prank(owner);
        fundraiser.payout(owner);

        vm.expectRevert(
            "Fundraising is already finished and cannot be canceled"
        );
        vm.prank(owner);
        fundraiser.cancelFundraiser();
    }

    function test_payout_Works() public {
        // reach goal
        vm.prank(contributor);
        fundraiser.contribute{value: 1 ether}();
        assertTrue(fundraiser.goalReached());
        assertEq(address(fundraiser).balance, fundraiser.totalContributed());

        // payout
        uint256 preBalance = owner.balance;
        vm.prank(owner);
        fundraiser.payout(owner);
        uint256 postBalance = owner.balance;

        assertEq(postBalance - preBalance, fundraiser.totalContributed());
        assertTrue(fundraiser.succeeded());
    }

    function test_payout_RevertWhen_GoalNotReached() public {
        vm.prank(contributor);
        fundraiser.contribute{value: 0.7 ether}();
        assertFalse(fundraiser.goalReached());

        // payout
        vm.expectRevert("Goal not reached yet");
        vm.prank(owner);
        fundraiser.payout(owner);
    }
}
