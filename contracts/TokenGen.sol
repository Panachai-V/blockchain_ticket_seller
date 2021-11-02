// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Module that may import in Future

//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";          //การลบตั๋วทิ้ง
//import "@openzeppelin/contracts/access/AccessControl.sol";                            //การประกาศ Roll ต่างๆ เช่น ADMIN, Buyer, Other


//-------------------------------CONTRACT VERSION 0.3.2------------------------------------------------------//
//-------------------------------เปลี่ยนโครงสร้าง Str------------------------------------------------------------//
contract TicketCtrl is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;
    constructor() ERC721("TicketAdmin", "TK_A") {}
    //string makername = "TicketAdmin";

    //ตัวแปรสำหรับเก็บข้อมูลของตั๋ว 
     struct ticketData {
        string concertName;             // ชื่อตั๋ว
        string ticketSeat;              // รายละเอียดตั๋ว ที่นั่ง
        string eventDate;               // รายละเอียดตั๋ว เก็บค่าวันที่ , ยังมี ข้อบกพร่อง อยู่
        address ticketMaker;            // address คนสร้าง
        uint price;                     // ราคาตั๋ว
        bool isUsed;                    // สถานะการใช้งานตั๋ว
    }

    // ผูกข้อมูลเข้ากับ ตั๋วแต่ละใบ (เรียกใช้โดย เลข ID ตั๋ว)
    mapping (uint => ticketData) tk_dat;

    function ticketMake(
        address _to,
        string memory name,
        string memory seat_dt,
        string memory t_date,
        uint t_price) 
        public onlyOwner 
        returns (uint t_no) {
        
        (bool tk_exist,) = getIDByNameAndDetail(name, seat_dt,t_date);      //check if ticket has already made
        if (tk_exist) {
            revert("This ticket has already made");
        }
        super._mint(_to, _tokenIdTracker.current());
        uint now_ID = _tokenIdTracker.current();
        ticketData storage tkData = tk_dat[now_ID];
        tkData.ticketSeat = seat_dt;
        tkData.concertName = name;
        tkData.ticketMaker = msg.sender;
        tkData.price = t_price;
        tkData.eventDate = t_date;
        tkData.isUsed = false;
        _tokenIdTracker.increment();
        return now_ID;
    }

    

    // โอนตั๋วโดยใช้ address คนขาย (ยกเลิกครับ)
    /* function transferFrom(address from,address to, uint256 tokenId) public virtual override onlyOwner{
        super.transferFrom(from, to ,tokenId);
        ticketData storage tkData = tk_dat[tokenId];
    } */

    // Function get ค่าต่างๆในตั๋ว (ป้อน ID ตั๋ว)

    function getPrice(uint tokenId) public view returns(uint price_num) {
        ticketData storage tkData = tk_dat[tokenId];
        return tkData.price;
    }

    function getName(uint tokenId) public view returns(string memory) {
        ticketData storage tkData = tk_dat[tokenId];
        return tkData.concertName;
    }

    function getDetail(uint tokenId) public view returns(string memory seat,string memory event_date) {
        ticketData storage tkData = tk_dat[tokenId];
        return (tkData.ticketSeat,tkData.eventDate);
    }

    function getUsedStatus(uint tokenId) public view returns(bool) {
        ticketData storage tkData = tk_dat[tokenId];
        return tkData.isUsed;
    }

    // ยกเลิก Function นี้ ให้ใช้ ownerOf(uint tokenId) แทน
    // function getOwnerAddress(uint tokenId) public view returns(address) {
    //     ticketData storage tkData = tk_dat[tokenId];
    //     return tkData.ticketOwner;
    // } 

    function getMakerAddress(uint tokenId) public view returns(address) {
        ticketData storage tkData = tk_dat[tokenId];
        return tkData.ticketMaker;
    }

    // แก้ไขตั๋ว
    function editTicket(uint tokenId,string memory rename,string memory re_detail) public onlyOwner returns(string memory) {
        ticketData storage tkData = tk_dat[tokenId];
        tkData.concertName = rename;
        tkData.ticketSeat = re_detail;
        string memory message = "update success \nName & Detail has been Updated";
        return message;
    }

    function editTkPrice(uint tokenId,uint re_price) public onlyOwner returns(string memory) {
        ticketData storage tkData = tk_dat[tokenId];
        tkData.price = re_price;
        string memory message = "update success \nPrice has been Updated";
        return message;
    }

    // ป้อนค่า name กับ detail ของตั๋ว เพื่อ Return ID ออกมา
    // ค่าที่ Return จะเป็น tuple โดยที่ ค่าแรก จะบอกว่ามีตั๋วที่มีข้อมูลตรงกับที่กรอกอยู่ในระบบ
    // ส่วนอีกค่า จะเป็นเลข ID ของตั๋ว
    function getIDByNameAndDetail(string memory t_name,string memory s_detail,string memory date_detail) public view returns(bool tkExist,uint ticketID_Number) {

        for(uint i = 0; i <= _tokenIdTracker.current(); i++){
            ticketData storage tkData = tk_dat[i];
            bool a = (keccak256(abi.encodePacked(tkData.concertName)) == keccak256(abi.encodePacked(t_name)));     //name & detail compare
            bool b = (keccak256(abi.encodePacked(tkData.ticketSeat)) == keccak256(abi.encodePacked(s_detail))); //Comparing string but we can't compare them directly
            bool c = (keccak256(abi.encodePacked(tkData.eventDate)) == keccak256(abi.encodePacked(date_detail)));
            if ( a && b && c )           // if ticket that has these detail exist
            {                       // return ticket ID and said it exist
                return (true,i);    // solidity can't return multiple value type in 1 variales so It need to return boolean and ID  
            }
        }
        return (false,0);           // return 0 and said it not exist (false)
    }

    //ฟังก์ชั่นที่ใช้ในการโอนตั๋ว โดยผู้ถือตั๋วเดิมต้องเป็นคนทำเท่านั้น
    function transferTicket(address to_addr,uint t_id) public {
        super.transferFrom(msg.sender,to_addr,t_id);
    }

    // -------------------------------------EXTEND FUNCTION ZONE----------------------------------------//
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function getPriceString(uint tokenId) public view returns(string memory num_str) {
        ticketData storage tkData = tk_dat[tokenId];
        uint ticketPrice = tkData.price;
        string memory str_num = uint2str(ticketPrice); 
        return str_num;
    }
}
