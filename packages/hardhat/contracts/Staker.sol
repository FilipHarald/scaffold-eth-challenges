// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;
  bool public openForWithdrawal = false;
  event Stake(address indexed sender, uint256 amount);
  uint256 public deadline = block.timestamp + 100 hours;

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable {
      emit Stake(msg.sender, msg.value);
      balances[msg.sender] += msg.value;
  }

  modifier notCompleted() {
      require(!exampleExternalContract.completed(), "Contract is already completed");
      _;
  }

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  function execute() public {
      if (block.timestamp > deadline) {
        if (address(this).balance >= threshold) {
          exampleExternalContract.complete{value: address(this).balance}();
        } else {
          openForWithdrawal = true;
        }
      }
  }


  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() public {
      uint256 amount = balances[msg.sender];
      balances[msg.sender] = 0;
      payable(msg.sender).transfer(amount);
  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns(uint256) {
      if (block.timestamp >= deadline) {
          return 0;
      } else {
          return deadline - block.timestamp;
      }
  }


  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
      stake();
  }

}
