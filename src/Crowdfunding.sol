// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Factory contract to manage multiple fundraising campaigns
/// @author Lastic Team
contract FundraiserFactory {
    /// @notice Array to store instances of fundraising campaigns
    Fundraiser[] public fundraisers;

    /// @notice Event to log the creation of a new fundraising campaign
    event FundraiseCreated(address);

    /// @notice Function to create a new fundraising campaign
    function createFundraiser(uint256 goal) public {
        Fundraiser newFundraiser = new Fundraiser(goal); // Factory creates a new non-upgradeable fundraising campaign
        newFundraiser.transferOwnership(msg.sender);
        fundraisers.push(newFundraiser);
        emit FundraiseCreated(address(newFundraiser));
    }

    /// @notice Function to get the deployed fundraising campaigns
    function getFundraisers() public view returns (Fundraiser[] memory) {
        return fundraisers;
    }
}

/// @title Fundraiser contract to manage a fundraising campaign
/// @author Lastic Team
contract Fundraiser is Ownable {
    /// @notice The goal amount to be raised in the fundraising campaign
    uint256 public goal;
    /// @notice The total amount contributed to the fundraising campaign
    uint256 public totalContributed;
    /// @notice Store the contributions of each contributor
    mapping(address => uint256) public contributions;
    /// @notice Boolean to check if the fundraising campaign has been canceled
    bool public canceled;
    /// @notice Boolean to check if the fundraising campaign has been succeeded
    bool public succeeded;

    // Event declarations
    event ContributionReceived(address contributor, uint256 amount);
    event GoalReached(uint256 totalContributed);
    event MoneyWithdrawn(address contributor, uint256 amount);
    event CampaignCancelled();
    event Payout(address receiver, uint256 amount);

    /// @notice initializes the fundraising campaign with a specific goal.
    /// @param _goal The goal amount to be raised in the fundraising campaign.
    constructor(uint256 _goal) Ownable(msg.sender) {
        require(_goal > 0, "Goal must be greater than 0");
        goal = _goal;
    }

    /// @notice Function to contribute to the fundraising campaign
    function contribute() public payable {
        require(!canceled, "The fundraising was canceled");
        require(msg.value > 0, "Contribution must be greater than 0");
        require(!goalReached(), "Goal has already been reached");

        contributions[msg.sender] = contributions[msg.sender] + (msg.value);
        totalContributed = totalContributed + (msg.value);
        emit ContributionReceived(msg.sender, msg.value);

        // Check if the goal has been reached
        if (goalReached()) {
            emit GoalReached(totalContributed);
        }
    }

    /// @notice Function to be executed when the goal is reached. Currently not implemented and not supposed to be used.
    /// @dev Placeholder for bulk coretime purchase logic. In upcoming versions of the contract, this function will make use of moonbeams xcm transact precompile to buy bulk coretime without the owner needing to take action.
    function purchase_core() internal {
        require(goalReached(), "Goal not reached yet");
        require(!succeeded, "Core already purchased");
        require(!canceled, "The fundraising was canceled");
        succeeded = true;
        // Placeholder for core purchase logic
        emit Payout(owner(), totalContributed);
    }

    /// @notice Function to pay out the money to the owner once the goal is reached
    /// @dev Will be replaced in the future with purchase_core.
    function payout() public {
        require(goalReached(), "Goal not reached yet");
        require(!succeeded, "Core already purchased");
        require(!canceled, "The fundraising was canceled");

        succeeded = true;
        (bool sent, ) = payable(owner()).call{value: totalContributed}("");
        require(sent, "Failed to payout");

        emit Payout(owner(), totalContributed);
    }

    /// @notice Function for contributors to withdraw their funds. Either if the fundraiser is cancelled or not finished yet.
    function withdraw() public {
        require(contributions[msg.sender] > 0, "No contributions to withdraw");
        require(!succeeded, "Your funds were already used to buy a core");

        uint256 contributedAmount = contributions[msg.sender];
        contributions[msg.sender] = 0;
        totalContributed = totalContributed - contributedAmount;
        payable(msg.sender).transfer(contributedAmount);
        emit MoneyWithdrawn(msg.sender, contributedAmount);
    }

    /// @notice Function for the owner to cancel the fundraising campaign. Contributors can withdraw their funds after the campaign is canceled.
    function cancelFundraiser() public onlyOwner {
        require(
            !succeeded,
            "Fundraising is already finished and cannot be canceled"
        );
        require(!canceled, "Fundraising is already canceled");
        canceled = true;
        emit CampaignCancelled();
    }

    /// @notice Function to check if the goal has been reached
    function goalReached() public view returns (bool) {
        return totalContributed >= goal;
    }
}
