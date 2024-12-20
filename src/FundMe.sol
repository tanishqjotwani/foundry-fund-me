// SPDX-License-Identifier:MIT
pragma solidity 0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe_NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint public constant MINIMUM_USD = 5e18;

    address[] private s_funders;
    mapping(address funder => uint256 amountFunded)
        private s_addressToAmountFunded;

    address private immutable i_owner;

    AggregatorV3Interface private s_pricefeed;

    constructor(address pricefeed) {
        i_owner = msg.sender;
        s_pricefeed = AggregatorV3Interface(pricefeed);
    }

    uint256 public myValue = 1;

    function fund() public payable {
        myValue = myValue + 2;

        require(
            msg.value.getConversionRate(s_pricefeed) > MINIMUM_USD,
            "Didn't send enough ETH"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (uint256 i = 0; i < fundersLength; i++) {
            s_addressToAmountFunded[s_funders[i]] = 0;
        }

        s_funders = new address[](0);

        address payable reciepient = payable(msg.sender);

        (bool callSuccess, ) = reciepient.call{value: address(this).balance}(
            ""
        );
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe_NotOwner();
        }
        _;
    }

    function getVersion() public view returns (uint256) {
        return s_pricefeed.version();
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
