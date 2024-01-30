//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @author Iwaki Hiroto
 * @notice Generic Vault that can accept any types of token
 */

contract TokenVault {
    using EnumerableSet for EnumerableSet.AddressSet;
    // using EnumerableSet for EnumerableSet.UintSet;

    /**
     * @dev Attempted to deposit more assets than the max amount for `receiver`.
     */
    error ERC20ExceededMaxDeposit(
        uint256 vaultId,
        address receiver,
        address asset,
        uint256 amount,
        uint256 max
    );

    /**
     * @dev Attempted to deposit more assets than the max amount for `receiver`.
     */
    error ERC20ExceededMaxWithdraw(
        uint256 vaultId,
        address receiver,
        address asset,
        uint256 amount,
        uint256 max
    );

    event DepositForERC20(
        uint256 vaultId,
        address asset,
        uint256 amount,
        address from
    );
    event WithdrawForERC20(
        uint256 vaultId,
        address asset,
        uint256 amount,
        address to
    );

    /**
     * @dev vault can handle any tokens
     */
    struct Vault {
        uint256 vaultId; // Unique id for identifying each vault
        /**
         * @dev coin handling
         */
        mapping(address => uint256) totalETHDeposited; // totoal amount of ETH
        mapping(address => uint256) userEthAmount; // user's eth amount
        /**
         * @dev ERC20 Token handling
         */
        EnumerableSet.AddressSet assetsForERC20; // tokens in each vault
        mapping(address => uint256) assetSupplyForERC20; // total amounts of erc20token
        mapping(address => mapping(address => uint256)) userAssetAmountForERC20; // user's token amount
        mapping(address => EnumerableSet.AddressSet) userOwnedAssets; // user's tokens that is deposited
        EnumerableSet.AddressSet erc721Tokens; // tokens in each vault
        EnumerableSet.AddressSet erc1155Tokens; // tokens in each vault
        EnumerableSet.AddressSet users; // users in each vault
    }

    uint256 vaultCounts; // total vaults

    mapping(uint256 => Vault) vaults; // vaultId => vaults

    /** @dev See {IERC4626-maxDeposit}. */
    function maxDeposit(address) public view returns (uint256) {
        return type(uint256).max;
    }

    /** @dev See {IERC4626-maxWithdraw}. */
    function maxWithdraw(
        uint256 vaultId,
        address asset,
        address owner
    ) public view returns (uint256) {
        return vaults[vaultId].userAssetAmountForERC20[owner][asset];
    }

    /**
     * @dev Deposit/mint common workflow.
     */
    function _deposit(
        uint256 vaultId,
        address asset,
        address caller,
        address receiver,
        uint256 amount
    ) internal {
        // If _asset is ERC777, `transferFrom` can trigger a reentrancy BEFORE the transfer happens through the
        // `tokensToSend` hook. On the other hand, the `tokenReceived` hook, that is triggered after the transfer,
        // calls the vault, which is assumed not malicious.
        //
        // Conclusion: we need to do the transfer before we mint so that any reentrancy would happen before the
        // assets are transferred and before the shares are minted, which is a valid state.
        // slither-disable-next-line reentrancy-no-eth
        SafeERC20.safeTransferFrom(
            IERC20(asset),
            caller,
            address(this),
            amount
        );

        // Add new token in valut
        if (vaults[vaultId].assetsForERC20.contains(asset)) {
            vaults[vaultId].assetsForERC20.add(asset);
        }

        // Add token amount
        vaults[vaultId].assetSupplyForERC20[asset] += amount;

        vaults[vaultId].userAssetAmountForERC20[receiver][asset] += amount;

        if (vaults[vaultId].userOwnedAssets[receiver].contains(asset)) {
            vaults[vaultId].userOwnedAssets[receiver].add(asset);
        }

        emit DepositForERC20(vaultId, asset, amount, msg.sender);
    }

    /** @dev See {IERC4626-deposit}. */
    function deposit(
        uint256 vaultId,
        address asset,
        uint256 amount
    ) public returns (uint256) {
        // validate amount
        uint256 maxAmount = maxDeposit(msg.sender);
        if (amount > maxAmount) {
            revert ERC20ExceededMaxDeposit(
                vaultId,
                msg.sender,
                asset,
                amount,
                maxAmount
            );
        }

        _deposit(vaultId, asset, msg.sender, msg.sender, amount);

        return amount;
    }

    /**
     * @dev Withdraw/redeem common workflow.
     */
    function _withdraw(
        uint256 vaultId,
        address asset,
        address caller,
        address receiver,
        uint256 amount
    ) internal virtual {
        // if (caller != owner) {
        //     _spendAllowance(owner, caller, shares);
        // }

        // If _asset is ERC777, `transfer` can trigger a reentrancy AFTER the transfer happens through the
        // `tokensReceived` hook. On the other hand, the `tokensToSend` hook, that is triggered before the transfer,
        // calls the vault, which is assumed not malicious.
        //
        // Conclusion: we need to do the transfer after the burn so that any reentrancy would happen after the
        // shares are burned and after the assets are transferred, which is a valid state.
        SafeERC20.safeTransfer(IERC20(asset), receiver, amount);

        vaults[vaultId].userAssetAmountForERC20[caller][asset] -= amount;

        if (vaults[vaultId].userAssetAmountForERC20[caller][asset] == 0) {
            vaults[vaultId].userOwnedAssets[caller].remove(asset);
        }

        // decrease token amount
        vaults[vaultId].assetSupplyForERC20[asset] -= amount;

        // Remove token
        if (vaults[vaultId].assetSupplyForERC20[asset] == 0) {
            vaults[vaultId].assetsForERC20.remove(asset);
        }

        emit WithdrawForERC20(vaultId, asset, amount, msg.sender);
    }

    /** @dev See {IERC4626-withdraw}. */
    function withdraw(
        uint256 vaultId,
        address asset,
        uint256 amount
    ) public returns (uint256) {
        uint256 maxAmount = maxWithdraw(vaultId, asset, msg.sender);
        if (amount > maxAmount) {
            revert ERC20ExceededMaxWithdraw(
                vaultId,
                msg.sender,
                asset,
                amount,
                maxAmount
            );
        }

        _withdraw(vaultId, asset, msg.sender, msg.sender, amount);

        return amount;
    }

    constructor() {}
}
