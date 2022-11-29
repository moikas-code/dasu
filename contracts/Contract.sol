// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";

//Extentions
// import "@thirdweb-dev/contracts/extension/Upgradeable.sol";
// import "@thirdweb-dev/contracts/extension/Initializable.sol";
import "@thirdweb-dev/contracts/extension/Permissions.sol";

contract Contract is ERC20Base, Permissions {
    uint256 burned = 0;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20Base(_name, _symbol) {}

    function calculate_block_reward(
        uint256 value
    ) private pure returns (uint256) {
        return (value * 1) / 10 ** 2;
    }

    function calculate_treasury_reward(
        uint256 value
    ) private pure returns (uint256) {
        return (value * 1) / 10 ** 2;
    }

    function calculate_tokens_burned(
        uint256 value
    ) private pure returns (uint256) {
        return (value * 1) / 10 ** 2;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        uint256 block_reward = calculate_block_reward(value); // Reward Node Mining Block
        uint256 treasury_reward = calculate_treasury_reward(value); // Reward Treasury
        uint256 tokens_burned = calculate_tokens_burned(value); // Burn Tokens
        uint256 tokens_sent = value - (block_reward + treasury_reward); // Send remaining value to recipient

        //Reward Miner Block
        if (!(from == address(0) && to == block.coinbase && to == address(0))) {
            block.coinbase.transfer(block_reward);
        }
        // burn tokens
        if (!(from == address(0) && to == address(0))) {
            _burn(from, tokens_burned);
        }
        super._beforeTokenTransfer(from, to, tokens_sent);
    }
}
