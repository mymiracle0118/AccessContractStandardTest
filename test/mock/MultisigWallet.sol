// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.20;

import {MockMultisigWallet} from "@src/MockMultisigWallet.sol";

contract MockMultisigWallet is MultisigWallet {
    constructor(
        address payable _gnosisSafe,
        address _gnosisSafeProxyFactory
    ) GnosisSafeMultisig(_gnosisSafe, _gnosisSafeProxyFactory) {}
}
