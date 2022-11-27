// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";
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
}