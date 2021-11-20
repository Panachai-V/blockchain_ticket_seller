// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./tokenGen.sol";


contract AdminCheck{

    //ฟังค์ชันสำหรับเช็กสถานะการใช้ตั๋ว
     function checkStatus(address _addr,uint _ticketid) public view returns(string memory) {
        TicketCtrl t = TicketCtrl(_addr);
        bool status = t.getUsedStatus(_ticketid);
        //ถ้าตั๋วถูกใช้
        if ( status == true) {
            string memory message = "This ticket already used.";
            return message;
        }
        //ถ้าตั๋วถูกไม่ถูกใช้
        else if ( status == false) {
            string memory message = "The ticket has not been used.";
            return message;
        }
        //ถ้าตั๋วมีข้อผิดพลาดหรือยังไม่ถูกสร้าง
        else {
            string memory message = "This ticket is invalid";
            return message;
        }
     }
    //เปลี่ยสถานะตั๋วในเป็นใช้แล้ว
    function doActivateTicket(address _addr,uint _ticketid) public payable {
     TicketCtrl t = TicketCtrl(_addr);
     t.pumpTimeStamp(_ticketid);
    }
    //เปลี่ยสถานะตั๋วในเป็นยังไม่ได้ใช้
    function undoActivateTicket(address _addr,uint _ticketid) public payable {
     TicketCtrl t = TicketCtrl(_addr);
     t.revertUsedStatus(_ticketid);
    }
    //แสดงข้อมูลผู้เข้าร่วมงาน
    function getAudienceDetail(address _addr,uint _ticketid) public view returns(string memory seat,uint unix_date) {
     TicketCtrl t = TicketCtrl(_addr);
     return t.getDetail(_ticketid);
    }
}