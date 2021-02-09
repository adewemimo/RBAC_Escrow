// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract Escrow is AccessControl {
    // Create a new role identifier for the agent, buyer and seller roles
    bytes32 public constant AGENT_ROLE = keccak256("AGENT_ROLE");
    bytes32 public constant BUYER_ROLE = keccak256("BUYER_ROLE");
    bytes32 public constant SELLER_ROLE = keccak256("SELLER_ROLE");


    enum state {Awaiting_Payment, Awaiting_Delivery, Complete}

    state public currentState;

    modifier inState(state expectedState){
        require(expectedState == currentState, "incorrect state");
        _;
    }

    mapping(address => uint256) public deposits;

    constructor(address buyer, address seller) {
        // Grant the agent and buyer roles to a specified account
        _setupRole(AGENT_ROLE, msg.sender);
        _setupRole(BUYER_ROLE, buyer);
        _setupRole(SELLER_ROLE, seller);
       
    } 

    function depositPayment(address buyer, address seller) inState(state.Awaiting_Payment) public payable {
        //check that the calling account is the escrow
        require(hasRole(AGENT_ROLE, msg.sender), "Not the right agent");
        require(hasRole(BUYER_ROLE, buyer), "Not the right buyer");
        require(hasRole(SELLER_ROLE, seller), "Not the right seller");
        uint amount = msg.value;
        deposits[seller] += amount;
        currentState = state.Awaiting_Delivery;
    }

    function deliveryConfirmed(address payable buyer, address payable seller, bool status) inState(state.Awaiting_Delivery) public {
        require(hasRole(AGENT_ROLE, msg.sender), "Not the right agent");
        require(hasRole(BUYER_ROLE, buyer), "Not the right buyer");
        require(hasRole(SELLER_ROLE, seller), "Not the right seller");

        uint payment = deposits[seller];
        deposits[seller] = 0;

        if (status == true){
            seller.transfer(payment);
            currentState = state.Complete;
        }
            buyer.transfer(payment);
            currentState = state.Complete;
    }
}
    