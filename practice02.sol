// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract BeggingContract{
    address public owner;
    address public begContract;
    mapping(address=>uint256) public donateOf;
    address[] public donateList;
    address[3] public topDonate;
    bool private locked=false;
    uint256 public startTime;
    uint256 public endTime;

    constructor(uint256 _durations){
        owner = msg.sender;
        begContract = payable(address(this));
        startTime = block.timestamp;
        endTime = startTime + (_durations * 1 seconds);
    }

    event Donation(address indexed from, uint256 amount, string memo);
    event Transfer(address indexed from, uint256 amount);

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier noReentrant(){
        require(!locked, "No reenTrancy");
        locked = true;
        _;
        locked = false;
    }

    function isActive() public view returns(bool){
        return block.timestamp <= endTime;
    }

    function donate(string memory memo) public payable {
        require(msg.value > 0, "donate money must more than zero");
        require(isActive(), "time over");

        uint256 donateValue = donateOf[msg.sender]; 
        if(donateValue == 0){
            donateList.push(msg.sender);
        }

        donateOf[msg.sender] += msg.value;
                //更新前3
        _updateTopThree(msg.sender);

        emit Donation(msg.sender, msg.value, memo);
    }

    function _updateTopThree(address donor) internal{
        bool alreadyInTop = false;
        uint256 insertPosition = 3;
        //先看是否在top3中，在的话改变状态，然后重新排序，更新位置
        for(uint256 i=0;i<3;i++){
            if (topDonate[i] == donor){
                alreadyInTop = true;
                break;
            }
            }

        //插入位置
        for(uint256 i=0;i<3;i++){
            if (donateOf[donor] > donateOf[topDonate[i]]){
                insertPosition = i;
                break;
            }
        }

        //不存在，直接排序插入对应位置
        if (!alreadyInTop){
            for(uint256 i=2;i>insertPosition;i--){
                topDonate[i] = topDonate[i-1];
            }
            topDonate[insertPosition] = donor;
        }

        //存在，前三重新排序
        if (alreadyInTop){
            for(uint256 i=0;i<2;i++){
                if (donateOf[topDonate[i]] < donateOf[topDonate[i+1]]){
                    address temp;
                    temp = topDonate[i];
                    topDonate[i] = topDonate[i+1];
                    topDonate[i+1] = temp;
                }
            }
        }
    }

    function getTopThreeUser() external view returns(address[3] memory){
        return topDonate;
    }

    function _withdraw() external payable onlyOwner noReentrant returns(bool success){
        uint256 remainBalance = address(this).balance;
        require(remainBalance > 0, "insufficent contract balance");
        //自定义一下gas费用
        (success,) = payable(owner).call{value:remainBalance}("");
        require(success, "Transfer failed");
        emit Transfer(msg.sender, remainBalance);
    }

    // function withdraw() external onlyWner noReentrant {
    //     uint256 balance = begContract.balance;
    //     require(balance > 0, "insufficent contract balance");
        
    //     payable(begContract).transfer(balance);

    // }

    function getDonation(address user) public view returns(uint256){
            return donateOf[user];
    }

    function getContractBalance() external view returns(uint256){
        return begContract.balance;
    }

    function getDonateList() public view returns(address[] memory){
        return donateList;
    }

    receive() external payable { 
        donate('');
    }

    function getBalance(address user) external view returns(uint256){
        return user.balance;
    }

}