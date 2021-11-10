// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./TokenGen.sol";
import "./TicketMachine.sol";

contract AdminChech{
    TicketCtrl ticket;

     function checkStatus(uint _ticketid) public view returns(string memory) {
        ticket.getUsedStatus(_ticketid);
        if ( tkData.isUsed == true) {
            string memory message = "This ticket is avilable";
            return message;
        }
        else {
            string memory message = "This ticket is unavilable";
            return message;
        }
     }

    // function changeStatus(uint _ticketid) public view returns(string memory) {

    // }

    function getAudienceInfo(uint _ticketid) public view returns(string memory) {
      return ticket.getDetail(_ticketid);
    }
}