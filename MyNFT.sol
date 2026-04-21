// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC721 {
    function balanceOf(address owner) external view returns(uint256 balance);
    function ownerOf(uint256 tokenId) external view returns(address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns(bool);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator, 
        address from, 
        uint256 tokenId, 
        bytes calldata data
        ) external returns(bytes4); 
}


interface IERC721Metadata {
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function tokenURI() external view returns(string memory);
}


contract MyToken{
    //===========================事件==============================
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event StringLog(string str);
    event IntLog(uint256 integer);

    //=========================状态变量=============================
    //合约名称
    string _myToken;
    //合约别称
    string _myTokenSymbol;
    //owner
    address _owner;
    //地址到拥有NFT的的余额
    mapping(address=>uint256) _balances;
    //单个tokenId到所有者
    mapping(uint256 => address) _owners;
    //单个NFT的授权信息：tokenId=>授权地址(单个授权)
    mapping(uint256 => address) _tokenApprovals;
    //全量授权信息：所有者地址=>操作者地址=>是否授权(全局授权)
    mapping(address=>mapping(address=>bool)) _operatorApprovals;
    //tokenId=>元数据URI
    mapping(uint256=>string) private _tokenURIs;
    //基础URI
    string private _baseURI;
    //下一个tokenId
    uint256 _nextTokenId = 1;
    //总供应量限制
    uint256 public _maxSupply = 1000;
    //铸造开关
    bool public _mintEnabled = true;

    //===========================修饰器==============================
    modifier onlyOwner(){
        require(msg.sender == _owner,"Not owner");
        _;
    }

    modifier whenMintingEnable(){
        require(_mintEnabled,"Minting disabled");
        _;
    }

    modifier validTokenId(uint256 tokenId){
        require(_exists(tokenId), "token does not exist");
        _;
    }

    //=========================构造函数==============================
    constructor(
        string memory myToken_,
        string memory symbol_,
        string memory baseTokenURI_
    ){
        _owner = msg.sender;
        _myToken = myToken_;
        _myTokenSymbol = symbol_;
        _baseURI = baseTokenURI_;
    }

    //=======================核心721函数=============================
    function name() external view returns(string memory){ return _myToken;}
    function symbol() external view returns(string memory){ return _myTokenSymbol;}
    function ownerOf(uint256 tokenId) external view validTokenId(tokenId) returns(address){return _owners[tokenId];}
    function balanceOf(address owner) external view returns(uint256){return _balances[owner];}

    /*
    *@dev安全转账,即授权转账+接收方(合约)校验NFT处理能力
    *@param from 发送方
    *@param to 接收方
    *@param tokenId 代币id
    *@param data 附加数据
    */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public{
        _transfer(from, to, tokenId);
        onERC721Received(from, to, tokenId, data);
    }

    /*
    @dev 安全转账重载函数，即不附带任何内容的安全转账
    */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /*
    @dev 授权转账，不带接收方处理NFT能力校验的授权转账
    *@param from 转账方
     *@param to 接收方
     *@param tokenId 代币id
    */
    function transferFrom(address from, address to, uint256 tokenId) public{
        _transfer(from, to, tokenId);
    }

    /*
    @dev 单个NFT授权
     *@param spender 授权地址
     *@param tokenId 代币id
    */
    function approve(address spender, uint256 tokenId) public {
        address owner = _owners[tokenId];
        require(owner == msg.sender || isApprovedForAll(owner, msg.sender), "ERC721: transfer caller is not owner nor approved");
        _approve(spender, tokenId);
    }

    /*
     *@dev 判断spender是否被授权操作owner的所有代币
     *@param owner 代币所有者
     *@param spender 授权操作方
    */
    function isApprovedForAll(address owner, address spender) public view returns (bool) {
        return _operatorApprovals[owner][spender];
    }

    /*
     *@dev 批量授权
     *@param operator 授权操作方
     *@param approved 是否授权
    */
    function setApprovalForAll(address operator, bool approved) external {
        require(operator != msg.sender, "ERC721: approve to caller");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /*
    @dev 获取单个代币授权地址
     *@param tokenId 代币id
    */
    function getApproved(uint256 tokenId) public view returns(address){return _tokenApprovals[tokenId];}

    //========================元数据函数=============================
    /*
    @dev 获取tokenuri
    *@param tokenId 代币id
    */
    function tokenURI(uint256 tokenId) public view validTokenId(tokenId) returns(string memory){
        string memory _tokenURI = _tokenURIs[tokenId];
        if (bytes(_tokenURI).length >0) {
            return _tokenURI;
        }
        return string(abi.encodePacked(_baseURI, _toString(tokenId)));
    } 

    /*
     *@dev 设置tokenuri
     *@param tokenId 代币id
     *@param tokenURI_ 代币uri
    */
    function _setTokenURI(uint256 tokenId, string memory tokenURI_) internal {
        _tokenURIs[tokenId] = tokenURI_;
    }

    /*
     *@dev 设置baseuri
     *@param baseURI_ baseuri
    */
    function setBaseURI(string memory baseURI_) public onlyOwner {
        _baseURI = baseURI_;
    }
    //=========================铸造函数==============================
    //=========================销毁函数==============================
    //=========================内部函数==============================

    /*
    *@dev 判断tokenId是否存在
     *@param tokenId 代币id
    */
    function _exists(uint256 tokenId) internal view returns(bool){
        return _owners[tokenId] != address(0);
    }

    /*
     *@dev 授权
     *@param spender 授权地址
     *@param tokenId 代币id
    */
    function _approve(address spender, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = spender;
        emit Approval(_owners[tokenId], spender, tokenId);
    }

    /*
    @dev 判断spender是否是owner或被授权
    @param spender 被授权地址
    @param tokenId 代币id
    @return 是否是owner或被授权
    */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns(bool){
        address owner = _owners[tokenId];
        return (
            spender == owner || 
            _operatorApprovals[owner][spender] || 
            spender == _tokenApprovals[tokenId]);
    }

    /*
    *@dev授权转账函数
     *@param from 发送方
     *@param to 接收方
     *@param tokenId 代币id
    */
    function _transfer(address from, address to, uint256 tokenId) internal {
        require(_owners[tokenId] == from, "Transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance > 0, "ERC721: transfer of token that is not own");
        uint256 toBalance = _balances[to];
        require(_isApprovedOrOwner(msg.sender, tokenId), "Transfer caller is not owner nor approved");

        //清除授权
        _approve(address(0), tokenId);
        //更新发送方和接收方的余额
        _balances[from] = fromBalance - 1;
        _balances[to] = toBalance + 1;
        //更新发送方和接收方的tokenId
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    //=====================ERC721Reciver检查=========================
    /*
     *@dev 检查接收方是否支持 ERC721Receiver 
     
     attention-import:这个函数的入参跟实际使用起来有点出入，
                        不过这个只是用来校验接收方合约是否实现对NFT有无处理能力，
                        所以只要：函数名，参数顺序，参数类型 ，对得上就行，因为校验的是函数选择器，并无真实功能校验
                        如果想要偷懒，函数体可直接返回true即可
     *@param to 接收方
     *@param tokenId 代币id
    */
    function onERC721Received(
        address from,
        address to, 
        uint256 tokenId, 
        bytes memory data) private {
            //判断是否合约
            if (to.code.length > 0){
                //合约的话检查是否实现了onERC721Received函数，即支持ERC721接收并能处理的能力
                try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) 
                    returns(bytes4 retval)
                {
                    require(retval == IERC721Receiver.onERC721Received.selector, "Invalid receiver");
                }
                catch (bytes memory reason) {
                    if (reason.length == 0){
                        revert("transfer to non ERC721Receiver");
                    } else {
                        assembly {
                            revert(add(32, reason), mload(reason))
                        }
                    }
                }
            }
        }

    //========================接口支持检查============================
    /*
    @dev 返回合约是否支持某个接口,
    attention:这是一个共识机制的校验，对于合约设计者而言，如果带着欺骗性的对该函数造假，是无法分辨的，只能通过测试才能辨别
    @param interfaceId 要检查的接口ID
    @return 如果支持，则为true，否则为false
    */
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId;
    }

    //=========================工具函数===============================
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        //确定位数，辗转除10法
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits ++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + (value%10)));
            value /= 10;
        }

        return string(buffer);

    }
    //=========================接口定义===============================

    //===========================修饰器==============================

}
