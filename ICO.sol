// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ICO is Ownable {
    IERC20 public token;
    uint256 public ICO_DURATION = 86400; // 24 hours in seconds
    uint256 public ico_start_time;
    
    mapping(address => bool) public registered_addresses;
    mapping(address => bool) public claimed_addresses;

    event Registered(address indexed user, uint256 ethContributed);
    event Claimed(address indexed user, uint256 tokenAmount);

    constructor(address _token_address) {
        token = IERC20(_token_address);
        ico_start_time = block.timestamp;
    }

    function register() external payable {
        require(!registered_addresses[msg.sender], "You are already registered.");
        require(block.timestamp < ico_start_time + ICO_DURATION, "ICO has ended.");
        require(msg.value >= 0.01 ether, "You must send at least 0.01 ETH to register.");

        registered_addresses[msg.sender] = true;
        emit Registered(msg.sender, msg.value);
    }

    function claim(address _recipient) external {
        require(registered_addresses[msg.sender], "You are not registered for the ICO.");
        require(block.timestamp >= ico_start_time + ICO_DURATION, "ICO has not ended yet. or claim has not started yet");
        require(!claimed_addresses[msg.sender], "You have already claimed your tokens.");

        claimed_addresses[msg.sender] = true;
        uint256 tokenAmount = 50 * 10**18; // 50 BUNN tokens with 18 decimal places
        require(token.transfer(_recipient, tokenAmount), "Token transfer failed.");
        emit Claimed(msg.sender, tokenAmount);
    }

    function withdrawEth() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function setICOStartTime(uint256 _startTime) external onlyOwner {
        ico_start_time = _startTime;
    }
}
