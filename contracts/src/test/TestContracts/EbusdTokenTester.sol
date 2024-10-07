// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "../../EbusdToken.sol";

contract EbusdTokenTester is EbusdToken {
    constructor(address _owner) EbusdToken(_owner) {}

    function unprotectedMint(address _account, uint256 _amount) external {
        _mint(_account, _amount);
    }
}
