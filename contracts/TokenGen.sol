// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
//import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MinimalERC721 is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;
    constructor() ERC721("Minimal", "MIN") {}
    string makername = "Default";

    //ตัวแปรสำหรับเก็บข้อมูลของตั๋ว 
     struct ticketData {
        string ticketName;              // ชื่อตั๋ว
        string ticketDetail;            // รายละเอียดตั๋ว
        address ticketOwner;            // address เจ้าของ
        address ticketMaker;            // address คนสร้าง
        uint price;
    }

    mapping (uint => ticketData) tk_dat;

    function mint(address _to) public onlyOwner {
        super._mint(_to, _tokenIdTracker.current());
        _tokenIdTracker.increment();        
    }


    // สร้างตั๋วโดยใช้ address คนขาย
    function tokenMake(address _to,string memory name,string memory detail) public onlyOwner {
        super._mint(_to, _tokenIdTracker.current());
        uint now_ID = _tokenIdTracker.current();
        ticketData storage tkData = tk_dat[now_ID];
        tkData.ticketDetail = detail;
        tkData.ticketName = name;
        tkData.ticketMaker = _to;
        tkData.ticketOwner = _to;
        _tokenIdTracker.increment();        
    }

    function transferFrom(address from,address to, uint256 tokenId) public virtual override onlyOwner{
        super.transferFrom(from, to ,tokenId);
        ticketData storage tkData = tk_dat[tokenId];
        tkData.ticketOwner = to;
    }

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

    function getOwnerAddress(uint tokenId) public view returns(address) {
        ticketData storage tkData = tk_dat[tokenId];
        return tkData.ticketOwner;
    }

    function getMakerAddress(uint tokenId) public view returns(address) {
        ticketData storage tkData = tk_dat[tokenId];
        return tkData.ticketMaker;
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