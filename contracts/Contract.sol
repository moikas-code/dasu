// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";


//Extentions
import "@thirdweb-dev/contracts/extension/Permissions.sol";

contract Contract is ERC20Base, Permissions {
      constructor(
        string memory _name,
        string memory _symbol
    )
        ERC20Base(
            _name,
            _symbol
        )
    {}

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        //block.coinbase
        super.transferFrom(from, to, amount);
        return true;
    }
}