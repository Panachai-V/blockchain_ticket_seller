// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Module that may import in Future

//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";          //การลบตั๋วทิ้ง
//import "@openzeppelin/contracts/access/AccessControl.sol";                            //การประกาศ Roll ต่างๆ เช่น ADMIN, Owner, Other


//--------------------------------CONTRACT VERSION 0.2.4------------------------------------------------------//
contract TicketCtrl is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;
    constructor() ERC721("Minimal", "MIN") {}
    string makername = "Default";

    //ตัวแปรสำหรับเก็บข้อมูลของตั๋ว 
     struct ticketData {
        string ticketName;              // ชื่อตั๋ว
        string ticketDetail;            // รายละเอียดตั๋ว
        address ticketMaker;            // address คนสร้าง
        uint price;
    }

    mapping (uint => ticketData) tk_dat;


    // สร้างตั๋วโดยใช้ address คนขาย
    function ticketMake(address _to,string memory name,string memory detail) public onlyOwner returns(bool ticketMake) {
        
        (bool tk_exist,) = getIDByNameAndDetail(name, detail);      //check if ticket has already made
        if (tk_exist) {
            ticketMake = false;
            revert("This ticket has already made");
        }
        super._mint(_to, _tokenIdTracker.current());
        uint now_ID = _tokenIdTracker.current();
        ticketData storage tkData = tk_dat[now_ID];
        tkData.ticketDetail = detail;
        tkData.ticketName = name;
        tkData.ticketMaker = _to;
        _tokenIdTracker.increment();
        ticketMake = true;        
    }

    // โอนตั๋วโดยใช้ address คนขาย
    /* function transferFrom(address from,address to, uint256 tokenId) public virtual override onlyOwner{
        super.transferFrom(from, to ,tokenId);
        ticketData storage tkData = tk_dat[tokenId];
    } */

    // Function get ค่าต่างในตั๋ว
    function getPrice(uint tokenId) public view returns(uint) {
        ticketData storage tkData = tk_dat[tokenId];
        return tkData.price;
    }

    function getName(uint tokenId) public view returns(string memory) {
        ticketData storage tkData = tk_dat[tokenId];
        return tkData.ticketName;
    }

    function getDetail(uint tokenId) public view returns(string memory) {
        ticketData storage tkData = tk_dat[tokenId];
        return tkData.ticketDetail;
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
    /* Still has a lot of improvement to do in this function may need to edit your contract if structure of this function
    change
    */
    function editTicket(uint tokenId,string memory rename,string memory re_detail) public onlyOwner returns(string memory) {
        ticketData storage tkData = tk_dat[tokenId];
        tkData.ticketName = rename;
        tkData.ticketDetail = re_detail;
        string memory message = "update success \nName & Detail has been Updated";
        return message;
    }

    function getIDByNameAndDetail(string memory t_name,string memory t_detail) public view returns(bool tkExist,uint ticketID_Number) {

        for(uint i = 0; i <= _tokenIdTracker.current(); i++){
            ticketData storage tkData = tk_dat[i];
            bool a = (keccak256(abi.encodePacked(tkData.ticketName)) == keccak256(abi.encodePacked(t_name)));      //name & detail compare
            bool b = (keccak256(abi.encodePacked(tkData.ticketDetail)) == keccak256(abi.encodePacked(t_detail))); //Comparing string but we can't comparedirectly
            
            if ( a && b )           // if ticket that has these detail exist
            {                       // return ticket ID and said it exist
                return (true,i);    // solidity can't return multiple value type in 1 variales so It need to return boolean and ID  
            }
        }
        return (false,0);           // return 0 and said it not exist (false)
    }
}


/* contract DigitalTicket is ERC721, ERC721Burnable, AccessControl {
    using Counters for Counters.Counter;

    //ตัวแปรสำหรับเก็บข้อมูลของตั๋ว 
    struct metadata {
        string ticketName;              // ชื่อตั๋ว
        string ticketDetail;            // รายละเอียดตั๋ว
    }

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("DigitalTicket", "MTK") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        
    }

    function safeMint(address to) public onlyRole(MINTER_ROLE) {
        _safeMint(to, _tokenIdCounter.current());
        _tokenIdCounter.increment();
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    //function addPermissionToBuyer(Address buyer) {

    //}

} */