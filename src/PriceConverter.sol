//SPDX-License-Identifier:MIT
pragma solidity 0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface pricefeed
    ) internal view returns (uint256) {
        // address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI
        (, int256 price, , , ) = pricefeed.latestRoundData();
        return uint256(price * 1e10);
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface pricefeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(pricefeed);
        uint256 ethAmountInUsd = (ethAmount * ethPrice) / 1e18;
        return ethAmountInUsd;
    }
}
