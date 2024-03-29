// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.20;

import "@src/MultisigWallet.sol";

contract MockMultisigWallet is MultiSigWallet {
    constructor(
        address[] memory _owners,
        uint _numConfirmationsRequired
    ) MultiSigWallet(_owners, _numConfirmationsRequired) {}

    function getDataWithoutAccessManager() public pure returns (bytes memory) {
        return abi.encodeWithSignature("multisig()");
    }

    function getDataWithAccessManager() public pure returns (bytes memory) {
        return abi.encodeWithSignature("hello()");
    }
}
