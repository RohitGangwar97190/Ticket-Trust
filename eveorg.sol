// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EventOrganization {
    address public organizer;
    string public eventName;
    uint256 public ticketPrice;
    uint256 public totalTickets;
    uint256 public ticketsSold;
    string public destination;
    
    mapping(address => uint256) public ticketBalances;

    event TicketPurchased(address indexed buyer, uint256 amount);
    event TicketCanceled(address indexed buyer, uint256 amount);

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can perform this action");
        _;
    }

    constructor(
        string memory _eventName,
        uint256 _ticketPrice,
        uint256 _totalTickets,
        string memory _destination
    ) {
        organizer = msg.sender;
        eventName = _eventName;
        ticketPrice = _ticketPrice;
        totalTickets = _totalTickets;
        ticketsSold = 0;
        destination = _destination;
    }

    function buyTicket(uint256 _ticketCount) external payable {
        require(_ticketCount > 0, "Must purchase at least one ticket");
        require(ticketsSold + _ticketCount <= totalTickets, "Not enough tickets available");
        uint256 totalPrice = _ticketCount * ticketPrice;
        require(msg.value >= totalPrice, "Insufficient payment");

        ticketsSold += _ticketCount;
        ticketBalances[msg.sender] += _ticketCount;
        payable(organizer).transfer(msg.value);

        emit TicketPurchased(msg.sender, _ticketCount);
    }

    function cancelTicket(uint256 _ticketCount) external {
        require(_ticketCount > 0, "Must cancel at least one ticket");
        require(ticketBalances[msg.sender] >= _ticketCount, "Insufficient tickets to cancel");

        ticketsSold -= _ticketCount;
        ticketBalances[msg.sender] -= _ticketCount;

        emit TicketCanceled(msg.sender, _ticketCount);
    }

    function getEventDetails() external view returns (string memory, uint256, uint256, uint256, string memory) {
        return (eventName, ticketPrice, totalTickets, ticketsSold, destination);
    }
}
