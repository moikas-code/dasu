// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/openzeppelin-presets/token/ERC20/ERC20.sol";
import "@thirdweb-dev/contracts/extension/interface/IMintableERC20.sol";
import "@thirdweb-dev/contracts/extension/interface/IBurnableERC20.sol";
import "@thirdweb-dev/contracts/extension/PermissionsEnumerable.sol";

contract KAIERC20 is
    ERC20,
    IMintableERC20,
    IBurnableERC20,
    PermissionsEnumerable
{
    bytes32 internal constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(address => uint256) private _balances;

    address payable public dev_wallet;

    uint256 burned = 0;

    constructor(
        address _defaultAdmin,
        address _dev_wallet,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
        _setupRole(MINTER_ROLE, _defaultAdmin);
        _setupRole(MINTER_ROLE, address(0));
        dev_wallet = payable(_dev_wallet);
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
        burned += amount;
        super._burn(account, amount);
    }

    function mintTo(address to, uint256 amount) external override {
        require(hasRole(MINTER_ROLE, _msgSender()), "not minter.");
        super._mint(to, amount);
    }

    function burn(uint256 amount) external override {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) external override {
        uint256 decreasedAllowance = allowance(account, _msgSender()) - amount;

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        uint256 fromBalance = _balances[from];
        uint256 total_tokens = value + (treasury_reward + tokens_burned);
        require(
            fromBalance >= total_tokens,
            "ERC20: transfer amount exceeds balance"
        );

        // burn tokens on transfers between wallets
        if (from != address(0) && to != address(0)) {
            uint256 treasury_reward = calculate_treasury_reward(value); // Reward Treasury
            _balances[from] -= treasury_reward;
            uint256 tokens_burned = calculate_tokens_burned(value); // Burn Tokens
            _burn(from, tokens_burned);
            _balances[dev_wallet] += treasury_reward;
            emit Transfer(from, dev_wallet, treasury_reward);
        }
        super._transfer(from, to, value);
    }
}
