// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./TokenGen.sol";

contract TicketMachine{
     TicketCtrl ticket;
     uint tkprice = 4 ether;

     function extra() public {
        ticket = new TicketCtrl();
     }

    function getTicketID(string memory t_name,string memory s_detail,string memory date_detail) public view returns(string memory) {
      return ticket.getIDByNameAndDetail(memory t_name, memory s_detail, memory date_detail);
    }

    function transferTK(address to_addr,uint t_id) {
      // User โอนสิทธิ์ความเป็นเจ้าของตั๋ว
      return ticket.transferTicket(to_addr, t_id);
    }

    function getTKprice(string memory t_name,string memory s_detail,string memory date_detail) public view returns(string memory) {
      // สรุปราคาของตั๋ว
       _ticketid = getTicketID(memory t_name, memory s_detail, memory date_detail);
       return ticket.getPrice(_ticketid);
    }

    function buyTicket(uint _ticketid, address payable _maker) public payable returns(address) {
        // ตรวจสอบยอดการชำระเงิน และทำการโอนสิทธิ์ตั๋วให้กับ  User
        if (msg.value < tkprice) {
            revert("Not enough Ether!");
        }
        else {
            return ticket.transferFrom(_maker, buyer, _ticketid);
        }
    }

    function requestRefund() {
          // User ทำการขอเงินคืนจากระบบ
        }

    function checkOwnership() {
        // ตรวจสอบสิทธิ์ความเป็นเจ้าของตั๋ว โดยใช้ Transaction hash
    }
}
