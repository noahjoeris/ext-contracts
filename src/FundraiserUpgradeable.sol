// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title FundraiserUpgradeable contract to manage a fundraising campaign. Can be upgraded.
/// @author Lastic Team
contract FundraiserUpgradeable is OwnableUpgradeable {
    /// @notice The goal amount to be raised in the fundraising campaign
    uint256 public goal;
    /// @notice The total amount contributed to the fundraising campaign
    uint256 public totalContributed;
    /// @notice Store the contributions of each contributor
    mapping(address => uint256) public contributions;
    /// @notice Boolean to check if the fundraising campaign has been canceled
    bool public canceled;
    /// @notice Boolean to check if the fundraising campaign has been successful
    bool public succeeded;

    // Event declarations
    event ContributionReceived(address contributor, uint256 amount);
    event GoalReached(uint256 totalContributed);
    event MoneyWithdrawn(address contributor, uint256 amount);
    event CampaignCancelled();
    event Payout(address receiver, uint256 amount);

    /// @notice initializes the fundraising campaign with a specific goal.
    /// @param _goal The goal amount to be raised in the fundraising campaign.
    function initialize(uint256 _goal) public initializer {
        require(_goal > 0, "Goal must be greater than 0");
        goal = _goal;
        __Ownable_init(msg.sender);
    }

    /// @notice Receive function to handle plain ETH or GLMR transfers
    receive() external payable {
        contribute();
    }

    /// @notice Function to contribute to the fundraising campaign
    function contribute() public payable {
        require(!canceled, "The fundraising was canceled");
        require(!succeeded, "Fundraising already completed");
        require(msg.value > 0, "Contribution must be greater than 0");
        require(!goalReached(), "Goal has already been reached");

        // Check if the contribution exceeds the goal
        uint256 amountToAccept = msg.value;
        if (totalContributed + msg.value > goal) {
            amountToAccept = goal - totalContributed;
        }

        // update state
        contributions[msg.sender] += amountToAccept;
        totalContributed += amountToAccept;
        emit ContributionReceived(msg.sender, amountToAccept);

        // Check if the goal has been reached
        if (goalReached()) {
            emit GoalReached(totalContributed);
        }

        // refund excess amount
        if (amountToAccept < msg.value) {
            uint256 excessAmount = msg.value - amountToAccept;
            (bool sent, ) = payable(msg.sender).call{value: excessAmount}("");
            require(sent, "Failed to refund excess contribution");
        }
    }

    /** @notice Function to be executed when the goal is reached. Currently not implemented and not supposed to be used.
     *  @dev Placeholder for bulk coretime purchase logic.
     *       In upcoming versions of the contract, this function will make use of moonbeams xcm transactor V3 precompile to buy bulk coretime without the owner needing to take action.
     *       It will make it possible to make xcm calls from this smart contract directly to the coretime chain to buy a core. It will use a computed origin that only this contract has access to.
     *       Here is a simple pseudocode example how it might look like:
     * ```
     * import {XcmTransactorV3} from XCMTransactorV3.sol;
     *
     * XcmTransactorV3 xcmTransactor = XcmTransactorV3(transactorAddress);
     * xcmTransactor.transactThroughSigned(...);
     * // or
     * xcmTransactor.transactThroughSignedMultilocation(...);
     *
     * ```
     */
    function purchase_core(address beneficiary) internal onlyOwner {
        require(goalReached(), "Goal not reached yet");
        require(!succeeded, "Core already purchased");
        require(!canceled, "The fundraising was canceled");
        succeeded = true;
        // Placeholder for core purchase logic
        emit Payout(beneficiary, totalContributed);
    }

    /// @notice Function to pay out the money to the owner once the goal is reached
    /// @param beneficiary The address to send the funds to
    /// @dev Will be replaced in the future with purchase_core.
    function payout(address beneficiary) public onlyOwner {
        require(goalReached(), "Goal not reached yet");
        require(!succeeded, "Core already purchased");
        require(!canceled, "The fundraising was canceled");

        succeeded = true;
        (bool sent, ) = payable(beneficiary).call{value: totalContributed}("");
        require(sent, "Failed to payout");

        emit Payout(beneficiary, totalContributed);
    }

    /// @notice Function for contributors to withdraw their funds. Either if the fundraiser is cancelled or not finished yet.
    /// @param amount The amount to withdraw
    function withdraw(uint256 amount) public {
        uint256 availableFunds = contributions[msg.sender];
        require(availableFunds > 0, "No contributions to withdraw");
        require(!succeeded, "Your funds were already used to buy a core");
        require(availableFunds >= amount, "Not enough funds to withdraw");

        // update state
        contributions[msg.sender] = availableFunds - amount;
        totalContributed -= amount;

        // send funds
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Failed to withdraw funds");

        emit MoneyWithdrawn(msg.sender, amount);
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
