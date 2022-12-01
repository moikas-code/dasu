// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/token/TokenERC20.sol";

contract KAIERC20 is TokenERC20 {
    mapping(address => uint256) private _balances;
    address payable public dev_wallet;

    uint256 burned = 0;

    constructor(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        
        address _primarySaleRecipient,
        address _platformFeeRecipient
    ) {

        TokenERC20.initialize(
            _defaultAdmin,
            _name,
            _symbol,
            _contractURI,
            _primarySaleRecipient,
            _platformFeeRecipient,
            0
        );
        dev_wallet = payable(msg.sender);
    }

    function total_burned() public view returns (uint256) {
        return burned + balanceOf(address(0));
    }

    function update_dev_wallet(
         address addr
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        dev_wallet = payable(addr);
    }

    function calculate_treasury_reward(
        uint256 value
    ) private pure returns (uint256) {
        return (value * 2) / 10 ** 2;
    }

    function calculate_tokens_burned(
        uint256 value
    ) private pure returns (uint256) {
        return (value * 3) / 10 ** 2;
    }

    function _burn(address account, uint256 amount) internal virtual override {
        super._burn(account, amount);
        burned += amount;
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        uint256 treasury_reward = calculate_treasury_reward(value); // Reward Treasury
        uint256 tokens_burned = calculate_tokens_burned(value); // Burn Tokens
        uint256 tokens_sent = value -
            (treasury_reward + tokens_burned); // Send remaining value to recipient

        // burn tokens on transfers between wallets
        if (from != address(0) && to != address(0)) {
            _burn(from, tokens_burned);
            _balances[dev_wallet] += treasury_reward;
            emit Transfer(from, dev_wallet, treasury_reward);
        }
        super._transfer(from, to, tokens_sent);

        
    }
}
