// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

//this is similar to a crowfunding contract; several accounts can fund it and only one can withdraw

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

//this contract will be able to accept some kind of payment
contract FundMe {
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    AggregatorV3Interface public priceFeed; //finding price feed addresses: https://docs.chain.link/docs/ethereum-addresses/

    constructor(address _priceFeed) public {
        //address _priceFeed: what feed adress should use instead of having it hardcoded
        //it will be executed inmediately when the contract is deployed
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender; //set the onwer as the one who creates the contract
    }

    function fund() public payable {
        //defining something as payable can be use to use funds
        uint256 minimumUSD = 50 * 10**18; //set a thresold of 50 usd converted to eth gei

        require(
            getConversionRate(msg.value) >= minimumUSD,
            "You need to spend more eth"
        ); /*similar to if; check the trueness of something
        if require is false, it will call a reverse; user will get back its money*/

        addressToAmountFunded[msg.sender] += msg.value;
        /*
        both are keywords on all contracts
        msg.sender -> sender of the money
        msg.value -> how much sender sends
        */
        funders.push(msg.sender);

        //what the ETH -> USD conversion rate is
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();

        return uint256(answer * 10000000000); //returns ETH -> USD conversion
    }

    function getConversionRate(uint256 ethAamount)
        public
        view
        returns (uint256)
    {
        //calculate how much usd is an specific amount of eth
        uint256 ethPrice = getPrice();
        uint256 ethAmountinUSD = (ethPrice * ethAamount) / 1000000000000000000;

        return ethAmountinUSD;
    }

    function getEntranceFee() public view returns (uint256) {
        // minimumUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        // return (minimumUSD * precision) / price;
        // We fixed a rounding error found in the video by adding one!
        return ((minimumUSD * precision) / price) + 1;
    }

    modifier onlyOwner() {
        //_; first execute the code and then check the reequire
        require(msg.sender == owner); //withdraw function can only be called by the owner of the contract
        _; //first check the require and then execute the next code
    }

    function withdraw() public payable onlyOwner {
        //adding onlyOwner, it will check the modifier before execute the function

        //require(msg.sender == owner);//withdraw function can only be called by the owner of the contract

        payable(msg.sender).transfer(address(this).balance); //transfer eth from one address to another
        //this refers to the contract we are in

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}
