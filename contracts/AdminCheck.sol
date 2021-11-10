// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./TokenGen.sol";


contract AdminCheck{
    TicketCtrl ticket;

     function checkStatus(uint _ticketid) public view returns(string memory) {
        bool status = ticket.getUsedStatus(_ticketid);
        if ( status == true) {
            string memory message = "This ticket is valid.";
            return message;
        }
        else if ( status == false) {
            string memory message = "This ticket already used";
            return message;
        }
        else {
            string memory message = "This ticket is invalid";
            return message;
        }
     }

    // function changeStatus(uint _ticketid) public view returns(string memory) {

    // }

    function getAudienceInfo(uint _ticketid) public view returns(string memory seat,string memory event_datey) {
      return ticket.getDetail(_ticketid);
    }
}