pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


/**
 * @title Real Estate Token
 * @author Alberto Cuesta Canada
 * @notice Implements a real estate tokenization contract with revenue distribution.
 */
contract RealEstateToken is ERC20, Ownable {
    using SafeMath for uint256;

    /**
     * @notice We require to know who are all the stakeholders.
     */
    address[] internal stakeholders;

    /**
     * @notice The accumulated revenue for each stakeholder.
     */
    mapping(address => uint256) internal revenues;

    /**
     * @notice The funds in this contract that haven't been distributed yet.
     */
    uint256 internal accumulated;

    /**
     * @notice The constructor for the Real Estate Token. This contract relates
     * to a unique real estate portfolio and each token minted is a share.
     * @param _owner The address to receive all tokens on construction.
     * @param _supply The amount of tokens to mint on construction.
     */
    constructor(address _owner, uint256 _supply)
        public
    {
        _mint(_owner, _supply);
    }

    /**
     * @notice Method to send Ether to this contract.
     */
    function ()
        external
        payable
    {
        accumulated += msg.value;
    }

    /**
     * @notice Transfers are only allowed to registered stakeholders.
     * @param _recipient The address to receive the RealEstateTokens.
     * @param _amount The amount of RealEstateTokens to send.
     */
    function transfer(address _recipient, uint256 _amount)
        public
        returns (bool)
    {
        (bool isStakeholder, ) = isStakeholder(_recipient);
        require(isStakeholder);
        _transfer(msg.sender, _recipient, _amount);
        return true;
    }

    // ---------- STAKEHOLDERS ----------

    /**
     * @notice A method to check if an address is a stakeholder.
     * @param _address The address to verify.
     * @return bool, uint256 Whether the address is a stakeholder,
     * and if so its position in the stakeholders array.
     */
    function isStakeholder(address _address)
        public
        view
        returns(bool, uint256)
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }

    /**
     * @notice A method to add a stakeholder.
     * @param _stakeholder The stakeholder to add.
     */
    function addStakeholder(address _stakeholder)
        public
        onlyOwner
    {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if (!_isStakeholder) stakeholders.push(_stakeholder);
    }

    /**
     * @notice A method to remove a stakeholder.
     * @param _stakeholder The stakeholder to remove.
     */
    function removeStakeholder(address _stakeholder)
        public
        onlyOwner
    {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if (_isStakeholder){
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        }
    }

    /**
     * @notice A simple method that calculates the proportional share for each stakeholder.
     * @param _stakeholder The stakeholder to calculate share for.
     */
    function getShare(address _stakeholder)
        public
        view
        returns(uint256)
    {
        return balanceOf(_stakeholder) / totalSupply();
    }

    // ---------- REVENUE ----------
    /**
     * @notice A method to distribute revenues to all stakeholders.
     */
    function distribute()
        public
        onlyOwner
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            address stakeholder = stakeholders[s];
            uint256 revenue = address(this).balance * getShare(stakeholder);
            accumulated = accumulated.sub(revenue);
            revenues[stakeholder] = revenues[stakeholder].add(revenue);
        }
    }

    /**
     * @notice A method to allow a stakeholder to withdraw his revenues.
     */
    function withdraw()
        public
    {
        uint256 revenue = revenues[msg.sender];
        revenues[msg.sender] = 0;
        address(msg.sender).transfer(revenue);
    }
}
