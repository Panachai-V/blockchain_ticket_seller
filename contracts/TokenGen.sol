// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@quant-finance/solidity-datetime/contracts/DateTime.sol";

//-------------------------------CONTRACT VERSION 0.4.0 ------------------------------------------------------------//
/*      จุดที่มีการเปลี่ยนแปลง
เปลี่ยนการเก็บค่า วันเวลาเป็นแบบ unix (ค่า integer 1 ตัว) เนื่องจาก solidity จะใช้การอ่านเวลาแบบนี้
(เก็บเป็น String แบบเดิม solidity เรียกใช้ยากกว่า)

1. ตอนสร้างตั๋ว   ให้กรอกข้อมูลตามนี้ => address ,ชื่อ, เลขตำแหน่งที่นั่ง,ราคา,วันที่จัดงาน,เดือนที่จัด,ปีที่จัด,ชั่วโมง,นาที
2. function getDetail จะมี 4 แบบย่อย   
    2.1 getDetail(tkID) จะส่งค่าออกมาสองค่าคือ :return (str เลขตำแหน่งที่นั่ง,uint เวลาแบบ unix)
    อยากให้เลิกใช้ถ้าเป็นไปได้เพราะแทนที่ด้วย 3 อันล่างได้
    2.2 getDateDetail(tkID) จะเป็นวันเวลาที่จัดงานแบบที่คนอ่านได้ จะส่งค่า uint ออกมา 5 ค่าคือ (วัน,เดือน,ปี,ชั่วโมง,นาที)
    2.2 getDateUnix(tkID) จะเป็นวันเวลาที่จัดงานแบบ unix :return (uint เวลาแบบ unix)
    2.4 getSeatDetail(tkID) จะส่งค่าออกมาสองค่าคือ :return (str เลขตำแหน่งที่นั่ง,uint เวลาแบบ unix)
3. มีตัวเช็คการกรอกเลขเวลา
*/

//-------------------------------เปลี่ยนโครงสร้าง Structure------------------------------------------------------------//
contract TicketCtrl is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;
    constructor() ERC721("TicketAdmin", "TK_A") {}
    //string makername = "TicketAdmin";

    //ตัวแปรสำหรับเก็บข้อมูลของตั๋ว 
     struct ticketData {
        string concertName;             // ชื่อตั๋ว
        string ticketSeat;              // ที่นั่งหรือเลขที่นั่ง
        uint valid_event_date;          // วันที่จัดงาน เก็บค่าวันที่ แบบ unix
        string event_where;             // สถานที่จัดงาน
        uint price;                     // ราคาตั๋ว
        address ticketMaker;            // address คนสร้าง
        bool isUsed;                    // สถานะการใช้งานตั๋ว
        uint usedWhen;                  // สถานะการใช้งานตั๋ว เวลาที่ใช้งาน แบบ unix
    }

    // ผูกข้อมูลเข้ากับ ตั๋วแต่ละใบ (เรียกใช้โดย เลข ID ตั๋ว)
    mapping (uint => ticketData) tk_dat;

    function ticketMake(
        address _to,
        string memory name,
        string memory seat_dt,
        uint t_price,
        uint e_day,
        uint e_month,
        uint e_year,
        uint e_hour,
        uint e_minute) 
        public onlyOwner 
        returns (uint t_ID_NO) {

        if (timeIsError(e_day, e_month, e_year,e_hour , e_minute)) {
            revert("Datetime value is wrong or not support, Please change value");
        }

        uint linux_time = DateTime.timestampFromDateTime(e_year, e_month, e_day, e_hour, e_minute, 0);
        (bool tk_exist,) = getIDByNameAndDetail(name, seat_dt,linux_time);      //check if ticket has already made
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
        // tkData.eventDate = t_date; 
        tkData.valid_event_date = linux_time;
        tkData.isUsed = false;
        _tokenIdTracker.increment();
        return now_ID;
    }

    // การโอนตั๋วโดยใช้ address คนขาย ใช้ function transferFrom(address from,address to, uint256 tokenId) 
    // Function get ค่าต่างๆในตั๋ว (ป้อน ID ตั๋ว)
    // get ค่า address เจ้าของตั๋ว ให้ใช้ ownerOf(uint tokenId) แทน

    function getPrice(uint ticketId) public view returns(uint price_num) {
        ticketData storage tkData = tk_dat[ticketId];
        return tkData.price;
    }

    function getName(uint ticketId) public view returns(string memory) {
        ticketData storage tkData = tk_dat[ticketId];
        return tkData.concertName;
    }

    function getDetail(uint ticketId) public view returns(string memory seat,uint unix_date) {
        ticketData storage tkData = tk_dat[ticketId];
        return (tkData.ticketSeat,tkData.valid_event_date);     
    }

    function getSeatDetail(uint ticketId) public view returns(string memory seat) {
        ticketData storage tkData = tk_dat[ticketId];
        return tkData.ticketSeat;     
    }

    function getDateDetail(uint ticketId) public view returns(
        uint event_day,
        uint event_month,
        uint event_year,
        uint event_hour,
        uint event_minute) {
        ticketData storage tkData = tk_dat[ticketId];
        (uint eventYear,uint eventMonth,uint eventDay,uint eventHour,uint eventSecond,) = 
        DateTime.timestampToDateTime(tkData.valid_event_date);
        return (eventDay,eventMonth,eventYear,eventHour,eventSecond);
    }

    function getDateUNIX(uint ticketId)  public view returns(uint) {
        ticketData storage tkData = tk_dat[ticketId];
        return tkData.valid_event_date;                         //เวลาที่ return ออกมา เป็น unix timestamp
    }

    function getUsedStatus(uint ticketId) public view returns(bool) {
        ticketData storage tkData = tk_dat[ticketId];
        return tkData.isUsed;
    }

    function getMakerAddress(uint ticketId) public view returns(address) {
        ticketData storage tkData = tk_dat[ticketId];
        return tkData.ticketMaker;
    }

    // ป้อนค่า name กับ detail ของตั๋ว เพื่อ Return ID ออกมา
    // ค่าที่ Return จะเป็น tuple โดยที่ ค่าแรก จะบอกว่ามีตั๋วที่มีข้อมูลตรงกับที่กรอกอยู่ในระบบ
    // ส่วนอีกค่า จะเป็นเลข ID ของตั๋ว
    function getIDByNameAndDetail(string memory t_name,string memory s_detail,uint date_unix) public view returns(bool tkExist,uint ticketID_Number) {

        for(uint i = 0; i <= _tokenIdTracker.current(); i++){
            ticketData storage tkData = tk_dat[i];
            bool a = (keccak256(abi.encodePacked(tkData.concertName)) == keccak256(abi.encodePacked(t_name)));     //name & detail compare
            bool b = (keccak256(abi.encodePacked(tkData.ticketSeat)) == keccak256(abi.encodePacked(s_detail))); //Comparing string but we can't compare them directly
            bool c = (tkData.valid_event_date == date_unix);
            if ( a && b && c )           // if ticket that has these detail exist
            {                       // return ticket ID and said it exist
                return (true,i);    // solidity can't return multiple value type in 1 variales so It need to return boolean and ID  
            }
        }
        return (false,0);           // return 0 and said it not exist (false)
    }

    function getIDbyName_HumanDate(string memory t_name,string memory s_detail,uint d,uint mth,uint yrs,uint hr,uint mins) 
    public view returns(bool tkExist,uint ticketID_Number) {
        uint date_unix = DateTime.timestampFromDateTime(yrs, mth, d, hr, mins, 0);
        return getIDByNameAndDetail(t_name, s_detail, date_unix);
    }


    // แก้ไขข้อมูลบนตั๋ว

    function editTicket(uint tokenId,string memory rename,string memory re_detail) public onlyOwner returns(string memory) {
        ticketData storage tkData = tk_dat[tokenId];
        (bool itExist,uint tkID) = getIDByNameAndDetail(rename,re_detail,tkData.valid_event_date);
        if (itExist && (tkID != tokenId)){
            revert("Another ticket has been made cannot editing");
        }
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

    function editEventDate(uint tokenId,uint new_day,uint new_month,uint new_year,uint new_hour,uint new_minute) public onlyOwner{
        ticketData storage tkData = tk_dat[tokenId];
        uint new_timestamp = DateTime.timestampFromDateTime(new_year, new_month, new_day, new_hour, new_minute, 0);
        (bool itExist,uint tkID) = getIDByNameAndDetail(tkData.concertName,tkData.ticketSeat,new_timestamp);
        if (itExist && (tkID != tokenId)){
            revert("Another ticket has been made,Cancel editing");
        }

        tkData.valid_event_date = new_timestamp;
    }

    function pumpTimeStamp(uint tokenId) public {           
        ticketData storage tkData = tk_dat[tokenId];        // ประทับเวลาที่ใช้งาน stamp
        tkData.usedWhen = block.timestamp;
        tkData.isUsed = true;                               // เปลี่ยนสถานะตั๋วเป็น "ใช้แล้ว"
    }

    function revertUsedStatus(uint tokenId) public {        // แก้ไขสถานะตั๋วกลับเป็น "ไม่ได้ใช้"           
        ticketData storage tkData = tk_dat[tokenId];            
        tkData.isUsed = false;        
    }

    //ฟังก์ชั่นที่ใช้ในการโอนตั๋ว โดยผู้ถือตั๋วเดิมต้องเป็นคนทำเท่านั้น
    function transferTicket(address to_addr,uint t_id) public {
        super.transferFrom(msg.sender,to_addr,t_id);
    }


    function timeIsError(uint day_i,uint mth_i,uint yr_i,uint hr_i,uint m_i ) private pure returns(bool){
        bool dayNot_error = ((day_i >= 1) && (day_i < 32));
        bool monthNot_error = ((mth_i >= 1) && (mth_i <= 12));
        bool yearNot_error = ((yr_i >= 1970) && (yr_i < 2038));
        bool hourNot_error = (hr_i <= 24);
        bool minuteNot_error = (m_i <= 60);
        if ( dayNot_error && monthNot_error && yearNot_error && hourNot_error && minuteNot_error){
            return false;
        }
        else {
            return true;
        }
    }
    // -------------------------------------EXTEND FUNCTION ZONE----------------------------------------//
    // -------------------------------------ฟังก์ชั่นเพิ่มเติม (เสริม)----------------------------------------//
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
