pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Campaign {
    uint256 public currentAmount;
    uint256 public goal;
    address public creator;
    ERC20 public token;

    mapping(address => uint256) public pledges;
    event Pledge(address _pledger, uint256 _amount);
    event Claim(address _pledger, uint256 _amount);
    event Refund(address _pledger, uint256 _amount);

    constructor(address _tokenAddress, uint256 _goal) public {
        token = ERC20(_tokenAddress);
        creator = msg.sender;
        goal = _goal;
    }

    function pledge(uint256 _amount) public {
        require(token.transferFrom(msg.sender, address(this), _amount), "Could not pledge tokens.");
        pledges[msg.sender] += _amount;
        currentAmount += _amount;
        emit Pledge(msg.sender, _amount);
    }

    function claim() public {
        require(msg.sender == creator, "You are not the creator so you cannot claim the funds.");
        require(currentAmount >= goal, "The goal has not yet been reached!");
        require(token.transfer(msg.sender, currentAmount), "Something went wrong and we couldn't transfer the funds.");
        currentAmount = 0;
        emit Claim(msg.sender, currentAmount);
    }

    function refund(address _pledger) public {
        require(msg.sender == creator, "You are not the creator so you cannot refund.");
        require(pledges[_pledger] > 0, "This person has not pledged funds.");
        require(token.transfer(_pledger, pledges[_pledger]), "Something went wrong and we couldn't refund.");
        pledges[_pledger] = 0;
        currentAmount -= pledges[_pledger];
        emit Refund(_pledger, pledges[_pledger]);
    }

    function balanceOf(address _pledger) public view returns (uint256) {
        return pledges[_pledger];
    }
}