// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EventOrganization {
    address public organizer;
    string public eventName;
    uint256 public ticketPrice;
    uint256 public totalTickets;
    uint256 public ticketsSold;
    bool public eventCanceled;
    
    mapping(address => uint256) public ticketHolders;

    event TicketsPurchased(address indexed buyer, uint256 amount);
    event EventCanceled();

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can perform this action");
        _;
    }

    modifier eventNotCanceled() {
        require(!eventCanceled, "The event is canceled");
        _;
    }

    constructor(string memory _eventName, uint256 _ticketPrice, uint256 _totalTickets) {
        organizer = msg.sender;
        eventName = _eventName;
        ticketPrice = _ticketPrice;
        totalTickets = _totalTickets;
        ticketsSold = 0;
        eventCanceled = false;
    }

    function purchaseTickets(uint256 _ticketCount) external payable eventNotCanceled {
        require(_ticketCount > 0, "Must purchase at least one ticket");
        require(ticketsSold + _ticketCount <= totalTickets, "Not enough tickets available");
        require(msg.value == ticketPrice * _ticketCount, "Incorrect payment amount");

        ticketsSold += _ticketCount;
        ticketHolders[msg.sender] += _ticketCount;

        emit TicketsPurchased(msg.sender, _ticketCount);
    }

    function cancelEvent() external onlyOrganizer eventNotCanceled {
        eventCanceled = true;
        emit EventCanceled();
    }

    function withdrawFunds() external onlyOrganizer {
        require(eventCanceled, "Event must be canceled to withdraw funds");
        uint256 balance = address(this).balance;
        payable(organizer).transfer(balance);
    }
}
