pragma solidity ^0.5.0;


//The ownable contract has an owner address. 

contract Ownable {
    address public owner;


    function Ownable() {
        owner = msg.sender;
    }


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    function transferOwnership(address newOwner) onlyOwner {
        if(newOwner != address(0)) {
            owner = newOwner;
        }
    }
