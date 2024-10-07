// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts/contracts/utils/math/Math.sol";

import "../../../Interfaces/IEbusdToken.sol";
import "./UniswapV3/ISwapRouter.sol";
import "./UniswapV3/IQuoterV2.sol";
import "./UniswapV3/IUniswapV3SwapCallback.sol";
import "../../Interfaces/IExchange.sol";
import {DECIMAL_PRECISION} from "../../../Dependencies/Constants.sol";

// import "forge-std/console2.sol";

contract UniV3Exchange is IExchange, IUniswapV3SwapCallback {
    using SafeERC20 for IERC20;

    IERC20 public immutable collToken;
    IEbusdToken public immutable ebusdToken;
    uint24 public immutable fee;
    ISwapRouter public immutable uniV3Router;
    IQuoterV2 public immutable uniV3Quoter;

    // From library TickMath
    /// @dev The minimum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MIN_TICK)
    //uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    /// @dev The maximum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MAX_TICK)
    //uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    constructor(
        IERC20 _collToken,
        IEbusdToken _ebusdToken,
        uint24 _fee,
        ISwapRouter _uniV3Router,
        IQuoterV2 _uniV3Quoter
    ) {
        collToken = _collToken;
        ebusdToken = _ebusdToken;
        fee = _fee;
        uniV3Router = _uniV3Router;
        uniV3Quoter = _uniV3Quoter;
    }

    // See: https://docs.uniswap.org/contracts/v3/reference/periphery/interfaces/IQuoterV2
    // These functions are not marked view because they rely on calling non-view functions and reverting to compute the result.
    // They are also not gas efficient and should not be called on-chain.
    function getEbusdAmountToSwap(uint256, /*_ebusdAmount*/ uint256 _maxEbusdAmount, uint256 _minCollAmount)
        external /* view */
        returns (uint256)
    {
        // See: https://github.com/Uniswap/v3-core/blob/d8b1c635c275d2a9450bd6a78f3fa2484fef73eb/contracts/UniswapV3Pool.sol#L608
        //uint160 sqrtPriceLimitX96 = _zeroForOne(ebusdToken, collToken) ? MIN_SQRT_RATIO + 1: MAX_SQRT_RATIO - 1;
        uint256 maxPrice = _maxEbusdAmount * DECIMAL_PRECISION / _minCollAmount;
        uint160 sqrtPriceLimitX96 = priceToSqrtPrice(ebusdToken, collToken, maxPrice);
        IQuoterV2.QuoteExactOutputSingleParams memory params = IQuoterV2.QuoteExactOutputSingleParams({
            tokenIn: address(ebusdToken),
            tokenOut: address(collToken),
            amount: _minCollAmount,
            fee: fee,
            sqrtPriceLimitX96: sqrtPriceLimitX96
        });
        (uint256 amountIn,,,) = uniV3Quoter.quoteExactOutputSingle(params);

        return amountIn;
    }

    function swapFromEbusd(uint256 _ebusdAmount, uint256 _minCollAmount, address _zapper) external returns (uint256) {
        ISwapRouter uniV3RouterCached = uniV3Router;
        IEbusdToken ebusdTokenCached = ebusdToken;
        ebusdTokenCached.transferFrom(_zapper, address(this), _ebusdAmount);
        ebusdTokenCached.approve(address(uniV3RouterCached), _ebusdAmount);

        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams({
            tokenIn: address(ebusdTokenCached),
            tokenOut: address(collToken),
            fee: fee,
            recipient: _zapper,
            deadline: block.timestamp,
            amountOut: _minCollAmount,
            amountInMaximum: _ebusdAmount,
            sqrtPriceLimitX96: 0 // See: https://ethereum.stackexchange.com/a/156018/9205
        });

        return uniV3RouterCached.exactOutputSingle(params);
    }

    function swapToEbusd(uint256 _collAmount, uint256 _minEbusdAmount, address _zapper) external returns (uint256) {
        ISwapRouter uniV3RouterCached = uniV3Router;
        IERC20 collTokenCached = collToken;
        collTokenCached.safeTransferFrom(_zapper, address(this), _collAmount);
        collTokenCached.approve(address(uniV3RouterCached), _collAmount);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: address(collTokenCached),
            tokenOut: address(ebusdToken),
            fee: fee,
            recipient: _zapper,
            deadline: block.timestamp,
            amountIn: _collAmount,
            amountOutMinimum: _minEbusdAmount,
            sqrtPriceLimitX96: 0 // See: https://ethereum.stackexchange.com/a/156018/9205
        });

        return uniV3RouterCached.exactInputSingle(params);
    }

    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata) external {
        //_requireCallerIsUniV3Router();
        IEbusdToken ebusdTokenCached = ebusdToken;
        IERC20 collTokenCached = collToken;
        IERC20 token0;
        IERC20 token1;
        if (_zeroForOne(ebusdTokenCached, collTokenCached)) {
            token0 = ebusdTokenCached;
            token1 = collTokenCached;
        } else {
            token0 = collTokenCached;
            token1 = ebusdTokenCached;
        }

        if (amount0Delta > 0) {
            token0.transfer(msg.sender, uint256(amount0Delta));
        }
        if (amount1Delta > 0) {
            token1.transfer(msg.sender, uint256(amount1Delta));
        }
    }

    function priceToSqrtPrice(IEbusdToken _ebusdToken, IERC20 _collToken, uint256 _price) public pure returns (uint160) {
        // inverse price if Ebusd goes first
        uint256 price = _zeroForOne(_ebusdToken, _collToken) ? DECIMAL_PRECISION * DECIMAL_PRECISION / _price : _price;
        return uint160(Math.sqrt((price << 192) / DECIMAL_PRECISION));
    }

    // See: https://github.com/Uniswap/v3-periphery/blob/main/contracts/lens/QuoterV2.sol#L207C9-L207C60
    function _zeroForOne(IEbusdToken _ebusdToken, IERC20 _collToken) internal pure returns (bool) {
        return address(_ebusdToken) < address(_collToken);
    }

    function _requireCallerIsUniV3Router() internal view {
        require(msg.sender == address(uniV3Router), "Not UniV3Router");
    }
}
