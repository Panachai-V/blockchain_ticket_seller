pragma solidity ^0.8.2;

import "./TokenGen.sol";

contract TicketMachine{
     TicketCtrl token;
     //address maker = accounts[0];
     // ค่าตั๋วชั่วคราว สำหรับทดสอบ
     uint tkprice = 4 ether;

     function extra() public {
        token = new TicketCtrl();
     }

    function getSummary(uint _ticketid) public view returns(string memory) {
        //return tkprice = token.getPrice(_ticketid);
    }

    function buyTicket(uint _ticketid, address _maker) public payable {
        //เช็ค Ether ของ User ว่าโอนมาพอหรือไม่ ถ้าพอทำการโอน Ticket
        if (msg.value < tkprice) {
            revert("Not enough Ether!");
        }
        else {
            token.transferFrom(_maker, msg.sender, _ticketid);
        }
    }
}
