// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./tokenGen.sol";


contract AdminCheck{
   // TicketCtrl ticket;

 
     function checkStatus(uint _ticketid) public view returns(string memory) {
        TicketCtrl ticket;
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

    function doActivateTicket(address _addr,uint _ticketid) public payable {
     TicketCtrl t = TicketCtrl(_addr);
     t.pumpTimeStamp(_ticketid);
    }
    
    function undoActivateTicket(address _addr,uint _ticketid) public payable {
     TicketCtrl t = TicketCtrl(_addr);
     t.revertUsedStatus(_ticketid);
    }
    
}