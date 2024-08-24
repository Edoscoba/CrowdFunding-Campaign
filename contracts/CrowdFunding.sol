
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Crowdfunding {
    // Campaign struct
    struct Campaign {
        string title;
        string description;
        address benefactor;
        uint goal;
        uint deadline;
        uint amountRaised;
        bool ended;
    }

    mapping(uint => Campaign) public campaigns;

    mapping(uint => mapping(address => uint)) public donors;

    uint public campaignIdCounter;

    event CampaignCreated(uint campaignId, string title, address benefactor, uint goal, uint deadline);

    event DonationReceived(uint campaignId, address donor, uint amount);

    event CampaignEnded(uint campaignId, address benefactor, uint amountRaised);

    function createCampaign(string memory _title, string memory _description, address _benefactor, uint _goal, uint _duration) public {
        require(_goal > 0, "Goal must be greater than zero");
        require(_benefactor != address(0), "Benefactor cannot be zero address");

        uint deadline = block.timestamp + _duration;

        campaigns[campaignIdCounter] = Campaign(_title, _description, _benefactor, _goal, deadline, 0, false);

        emit CampaignCreated(campaignIdCounter, _title, _benefactor, _goal, deadline);

        campaignIdCounter++;
    }

    function donate(uint _campaignId) public payable {
        Campaign storage campaign = campaigns[_campaignId];

        require(campaign.deadline > block.timestamp, "Campaign has ended");

        require(campaign.benefactor != address(0), "Campaign does not exist");

        donors[_campaignId][msg.sender] += msg.value;

        campaign.amountRaised += msg.value;

        emit DonationReceived(_campaignId, msg.sender, msg.value);
    }

    function endCampaign(uint _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];

        require(campaign.deadline <= block.timestamp, "Campaign has not ended");
        require(campaign.benefactor != address(0), "Campaign does not exist");

        payable(campaign.benefactor).transfer(campaign.amountRaised);

        campaign.ended = true;

        emit CampaignEnded(_campaignId, campaign.benefactor, campaign.amountRaised);
    }
}
