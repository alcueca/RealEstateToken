pragma solidity ^0.5.0;

import "./RealEstateToken.sol";
/*
* The factory is used to allow anyone to deploy a RealEstateToken instance
* and become the owner without owning the source. This also makes the deployment easier as
* the deploy script automatically assigns the deployer of the Factory as the owner of the * * RealEstateTokenInstance
*/
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