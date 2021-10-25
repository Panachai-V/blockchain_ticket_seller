pragma solidity ^0.8.2;

import "./TokenGen.sol";

contract TicketMachine{
     MinimalERC721 token;

     function extra() public{
        token = new MinimalERC721();
     }

     function ticketMake(address _maker, string memory _name, string memory _detail) public{
         return token.tokenMake(_maker, _name, _detail);
     }

    function getTicketID(string memory _name, string memory _detail) public {
        // return เป็น ID สำหรับใช้ getPrice
    }

    function getSummary(uint ticketid) public{
        // return token.getPrice(ticketid);
        // อาจจะเก็บในตัวแปรอื่น เพราะต้องใช้อีก
    }

    function checkPayment(uint ticketid) public {
        // ทำการตรวจสอบการชำระเงิน และโอนตั๋ว

        // รูปแบบที่ 1 ตรวจสอบยอดเงินการโอนเทียบกับราคารวมของตั๋ว
        // if >= ทำการโอนตั๋วให้ผู้ซื้อ "ระบุทำรายการสำเร็จ"
        // else < โอนเงินคืนอัตโนมัติ "ระบุทำรายการไม่สำเร็จ"

        // รูปแบบที่ 2 ราคารวมของตั๋วแสดงใน metamask
        // if ทำรายการสำเร็จ ทำการโอนตั๋วให้ผู้ซื้อ "ระบุทำรายการสำเร็จ"
        // else "ระบุทำรายการไม่สำเร็จ"
        // มีตัวเลือกสำหรับยกเลิกรายการ

    }
}
