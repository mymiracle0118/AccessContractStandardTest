// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.20;

import {Test} from "@forge-std/Test.sol";
import {Roles} from "@src/Roles.sol";
import {MockMultisigWallet} from "@test/mock/MockMultisigWallet.sol";

import {console} from "@forge-std/console.sol";
import {console2} from "@forge-std/console2.sol";

contract TestMockMultisigWallet is Test {
    address private admin = address(1);
    address[] public defaultOwnerAddresses = [
        address(1),
        address(2),
        address(3),
        address(4)
    ];
    address public bob = address(3);

    uint256 threshold = 2;
    address AddressZero = address(0);

    MockMultisigWallet private multisigWallet;

    function setUp() public {
        // accessManager.labelRole(Roles.ADMIN, "ADMIN");
    }

    // Should fail when passing the non-zero multisig data with the incorrect number of bytes
    function testCreateFail() public {
        // vm.expectRevert();
        // vm.expectRevert();
        // console.log("test");
        // gnosisSafeMultisig.create(defaultOwnerAddresses, threshold, "0x55");
    }

    function testTargetClose() public {}

    function testSetRole() public {}

    function testCallHelloWithRole() public {}

    receive() external payable {}
}
