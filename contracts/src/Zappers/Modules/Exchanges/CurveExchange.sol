// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import "../../../Interfaces/IEbusdToken.sol";
import "./Curve/ICurvePool.sol";
import "../../Interfaces/IExchange.sol";

// import "forge-std/console2.sol";

contract CurveExchange is IExchange {
    using SafeERC20 for IERC20;

    IERC20 public immutable collToken;
    IEbusdToken public immutable ebusdToken;
    ICurvePool public immutable curvePool;
    uint256 public immutable COLL_TOKEN_INDEX;
    uint256 public immutable EBUSD_TOKEN_INDEX;

    constructor(
        IERC20 _collToken,
        IEbusdToken _ebusdToken,
        ICurvePool _curvePool,
        uint256 _collIndex,
        uint256 _ebusdIndex
    ) {
        collToken = _collToken;
        ebusdToken = _ebusdToken;
        curvePool = _curvePool;
        COLL_TOKEN_INDEX = _collIndex;
        EBUSD_TOKEN_INDEX = _ebusdIndex;
    }

    // Helper to get the actual ebusd we need, capped by a max value, to get flash loan amount
    function getEbusdAmountToSwap(uint256 _ebusdAmount, uint256 _maxEbusdAmount, uint256 _minCollAmount)
        external
        view
        returns (uint256)
    {
        uint256 step = (_maxEbusdAmount - _ebusdAmount) / 5; // In max 5 iterations we should reach the target, unless price is lower
        uint256 dy;
        // TODO: Optimizations: binary search, change the step depending on last dy, ...
        // Or check if there’s any helper implemented anywhere
        uint256 lastEbusdAmount = _maxEbusdAmount + step;
        do {
            lastEbusdAmount -= step;
            dy = curvePool.get_dy(EBUSD_TOKEN_INDEX, COLL_TOKEN_INDEX, lastEbusdAmount);
        } while (dy > _minCollAmount && lastEbusdAmount > step);

        uint256 ebusdAmountToSwap = dy >= _minCollAmount ? lastEbusdAmount : lastEbusdAmount + step;
        require(ebusdAmountToSwap <= _maxEbusdAmount, "Ebusd amount required too high");

        return ebusdAmountToSwap;
    }

    function swapFromEbusd(uint256 _ebusdAmount, uint256 _minCollAmount, address _zapper) external returns (uint256) {
        ICurvePool curvePoolCached = curvePool;
        IEbusdToken ebusdTokenCached = ebusdToken;
        ebusdTokenCached.transferFrom(_zapper, address(this), _ebusdAmount);
        ebusdTokenCached.approve(address(curvePoolCached), _ebusdAmount);

        // TODO: make this work
        //return curvePoolCached.exchange(EBUSD_TOKEN_INDEX, COLL_TOKEN_INDEX, _ebusdAmount, _minCollAmount, false, _zapper);
        uint256 output = curvePoolCached.exchange(EBUSD_TOKEN_INDEX, COLL_TOKEN_INDEX, _ebusdAmount, _minCollAmount);
        collToken.safeTransfer(_zapper, output);

        return output;
    }

    function swapToEbusd(uint256 _collAmount, uint256 _minEbusdAmount, address _zapper) external returns (uint256) {
        ICurvePool curvePoolCached = curvePool;
        IERC20 collTokenCached = collToken;
        collTokenCached.safeTransferFrom(_zapper, address(this), _collAmount);
        collTokenCached.approve(address(curvePoolCached), _collAmount);

        //return curvePoolCached.exchange(COLL_TOKEN_INDEX, EBUSD_TOKEN_INDEX, _collAmount, _minEbusdAmount, false, _zapper);
        uint256 output = curvePoolCached.exchange(COLL_TOKEN_INDEX, EBUSD_TOKEN_INDEX, _collAmount, _minEbusdAmount);
        ebusdToken.transfer(_zapper, output);

        return output;
    }
}
