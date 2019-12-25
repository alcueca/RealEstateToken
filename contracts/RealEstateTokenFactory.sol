pragma solidity ^0.5.0;

import "./RealEstateToken.sol";

contract RealEstateTokenFactory {
    address[] public deployedRealEstateTokens;

    function createRealEstateToken(uint _supply) public {
        RealEstateToken newRealEstateToken = 
        new RealEstateToken(msg.sender,_supply);
        deployedRealEstateTokens.push(address(newRealEstateToken));
    }

    function getDeployedRealEstateTokens() 
    public view returns (address[] memory) {
        return deployedRealEstateTokens;
    }
}