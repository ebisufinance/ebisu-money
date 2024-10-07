// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IExchange {
    // Removing view because of Uniswap IQuoter
    function getEbusdAmountToSwap(uint256 _ebusdAmount, uint256 _maxEbusdAmount, uint256 _minCollAmount)
        external /* view */
        returns (uint256);
    function swapFromEbusd(uint256 _ebusdAmount, uint256 _minCollAmount, address _zapper) external returns (uint256);

    function swapToEbusd(uint256 _collAmount, uint256 _minEbusdAmount, address _zapper) external returns (uint256);
}
