// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./TokenGen.sol";

contract TicketMachine{
     TicketCtrl ticket;
     uint tkprice = 4 ether;
     uint public value;
     address payable public seller;
     address payable public buyer;

     modifier onlySeller() {
       require(msg.sender == seller,
         "only seller can call.");
         _;
     }

     modifier onlyBuyer() {
       require(msg.sender == buyer,
         "only buyer can call.");
         _;
     }

     function extra() public {
        ticket = new TicketCtrl();
     }

     function withdraw() public onlySeller {
       // คนขายถอนเงินจากระบบ
       buyer.transfer(address(this).balance);
     }

    function getTicketID(string memory t_name,string memory s_detail,string memory date_detail) public onlyBuyer view returns( ,uint tkID) {
      return ticket.getIDByNameAndDetail(t_name, s_detail, date_detail);
    }

    function transferTK(address to_addr,uint t_id) public onlyBuyer returns(address) {
      // User โอนสิทธิ์ความเป็นเจ้าของตั๋ว
      return ticket.transferTicket(to_addr, t_id);
    }

    function getTKprice(string memory t_name,string memory s_detail,string memory date_detail) public view returns(uint price) {
      // สรุปราคาของตั๋ว
       (, uint _ticketid) = getTicketID(t_name, s_detail, date_detail);
       return ticket.getPrice(_ticketid);
    }

    function buyTicket(uint _ticketid, address _maker, address buyer) public onlyBuyer payable returns(address) {
        // ตรวจสอบยอดการชำระเงิน และทำการโอนสิทธิ์ตั๋วให้กับ User
        //tkprice = ticket.getPrice(_ticketid);
        if (msg.value < tkprice) {
            revert("Not enough Ether!!");
        }
        else {
            return ticket.transferFrom(_maker, buyer, _ticketid);
        }
    }

    function requestRefund(uint _ticketid, address _maker, address buyer) public onlyBuyer returns(address) {
        // User ทำการขอเงินคืน ขายตั๋วคืนระบบ
        buyer.transfer(address(this).balance);
        return ticket.transferFrom(buyer, _maker, _ticketid);
    }

    function checkOwnership() {
        // ตรวจสอบสิทธิ์ความเป็นเจ้าของตั๋ว โดยใช้ Transaction hash
    }
}
