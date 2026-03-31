// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct Votes{
    uint256 vote;
    bool exist;
}


contract Voting{
    mapping(address=>Votes) internal  votingInformation;
    address[] internal users;

    function vote(address to) external  returns(bool){
        require(to != address(0), "to zero");
        Votes storage voteInfo = votingInformation[to];
        if (voteInfo.exist == false){
            users.push(to);
            voteInfo.exist = true;
        }
        voteInfo.vote += 1;
        return true;
    }

    function getVotes(address user) external view returns(uint256){
        return votingInformation[user].vote;
    }

    function resetVotes() external returns(bool){
        uint l = users.length;
        for (uint i = 0; i < l; i++){
            votingInformation[users[i]].vote = 0;
        }

        return true;
    }

    function getUsers() external view returns(address[] memory){
        return users;
    }
}

contract stringReverse{

    function getLength(string memory s) internal pure returns(uint256, bytes memory){
        bytes memory b = bytes(s);
        return (b.length, b);
    }

    function reverse(string memory s) public pure returns(string memory){
        (uint l, bytes memory oldBytes) = getLength(s);
        bytes memory newBytes = new bytes(l);

        for(uint i=0; i<l; i++){
            newBytes[i] = oldBytes[l-i-1];
        }

        return string(newBytes);
    }
}

contract IntToRoma{
    /*
    1-I
    5-V
    10-X
    50-L
    100-C
    500-D
    1000-M
    */
    mapping(uint32=>string) romaMpping;
    constructor(){
        romaMpping[1000] = "M";
        romaMpping[2000] = "MM";
        romaMpping[3000] = "MMM";
        romaMpping[900] = "CM";
        romaMpping[800] = "DCCC";
        romaMpping[700] = "DCC";
        romaMpping[600] = "DC";
        romaMpping[500] = "D";
        romaMpping[400] = "CD";
        romaMpping[300] = "CCC";
        romaMpping[200] = "CC";
        romaMpping[100] = "C";
        romaMpping[90] = "XC";
        romaMpping[80] = "CXXX";
        romaMpping[70] = "CXX";
        romaMpping[60] = "CX";
        romaMpping[50] = "L";
        romaMpping[40] = "XL";
        romaMpping[30] = "XXX";
        romaMpping[20] = "XX";
        romaMpping[10] = "X";
        romaMpping[9] = "IL";
        romaMpping[8] = "VIII";
        romaMpping[7] = "VII";
        romaMpping[6] = "VI";
        romaMpping[5] = "V";
        romaMpping[4] = "IV";
        romaMpping[3] = "III";
        romaMpping[2] = "II";
        romaMpping[1] = "I";
    }

    function mu(uint32 num) public pure  returns(uint32){
        return num/100;
    }

    function int2Roma(uint32 num) external view returns(string memory){
        string memory s;
        require(num < 4000, "num must be less than 4000");
        uint32 th = num/1000;
        string memory str1 = romaMpping[th*1000];
        uint32 h = (num - th*1000)/100;
        string memory str2 = romaMpping[h*100];
        uint32 te = (num - th*1000 - h*100)/10;
        string memory str3 = romaMpping[te*10];
        uint32 i = num - th*1000 - h*100 - te*10;
        string memory str4 = romaMpping[i];

        s = string(abi.encodePacked(str1, str2, str3, str4));
        return s;
    }
}

contract RomaToInt{
        /*
    1-I
    5-V
    10-X
    50-L
    100-C
    500-D
    1000-M
    */
    mapping(bytes1=>uint256) romaMpping;
    constructor(){
        romaMpping[bytes1("I")] = 1;
        romaMpping[bytes1("V")] = 5;
        romaMpping[bytes1("X")] = 10;
        romaMpping[bytes1("L")] = 50;
        romaMpping[bytes1("C")] = 100;
        romaMpping[bytes1("D")] = 500;
        romaMpping[bytes1("M")] = 1000;
    }

    function getBytesByIndex(string memory s, uint8 i) public pure returns(string memory){
        bytes memory b = bytes(s);
        uint256 l = b.length;
        require(i <= l-1, "index more than length");
        return string(abi.encodePacked(b[i]));
    }

    function roma2Int(string memory s) external view returns(uint256){
        bytes memory b = bytes(s);
        uint256 num=0;
        uint256 l = b.length;
        for(uint256 i=0;i<l;i++){
            uint256 currentValue = romaMpping[b[i]];
            if (i+1 < l){
                uint256 rightValue = romaMpping[b[i+1]];
                if (currentValue < rightValue){
                    num -= currentValue;
                }else{
                    num += currentValue;
                }
            }else {
                num += currentValue;
            }

        }

        return num;
    }
}

contract MergeArray{

    function sortArray(uint[] memory a, uint[] memory b)  public pure returns(uint[] memory){
        uint256 l1 = a.length;
        uint256 l2 = b.length;
        uint256 l = l1 + l2;
        uint[] memory c = new uint[](l);
        uint256 i=0;
        uint256 j=0;
        uint256 k=0;
        while(i<l1 && j<l2){
            if(a[i] < b[j]){
                c[k] = a[i];
                i++;
            }else{
                c[k] = b[j];
                j++;
            }
            k++;

        }

        while(i < l1){
            c[k] = a[i];
            i++;
            k++;
        }
        while(j < l2){
            c[k] = b[j];
            j++;
            k++;
        }

        return c;}
}

contract searchTarget{

    function binarySearch(uint256[] memory s, uint256 t) external pure returns(uint256 index){
        uint256 l = s.length;
        uint256 left = 0;
        uint256 right = l-1;
        if(l == 1){
            return 0;
        }
        while(left <= right){
            uint256 mid = (left + right)/2;
            if(s[mid] == t){
                return mid;
            }else if(s[mid] < t){
                left = mid + 1;
            }else{
                right = mid - 1;
            }
        }
        return 0;
    }
}


