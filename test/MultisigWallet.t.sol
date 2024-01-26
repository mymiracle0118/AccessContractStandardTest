// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.20;

import {Test} from "@forge-std/Test.sol";
import {Roles} from "@src/Roles.sol";
import {MockMultisigWallet} from "@test/mock/MockMultisigWallet.sol";

import {console} from "@forge-std/console.sol";
import {console2} from "@forge-std/console2.sol";

contract TestMockMultisigWallet is Test {
    address private admin = address(1);
    uint256 confirmationCount = 2;
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
        multisigWallet = new MockMultisigWallet(
            defaultOwnerAddresses,
            confirmationCount
        );
    }

    // Should fail with same addresses input
    function testCreateFail() public {
        address[] memory testOwnerAddresses = new address[](4);
        testOwnerAddresses[0] = address(0);
        testOwnerAddresses[1] = address(1);
        testOwnerAddresses[2] = address(2);
        testOwnerAddresses[3] = address(2);
        // vm.expectRevert();
        MockMultisigWallet multisigWallet1;
        vm.expectRevert("invalid owner");
        multisigWallet1 = new MockMultisigWallet(
            testOwnerAddresses,
            confirmationCount
        );
    }

    function testTargetClose() public {}

    function testSetRole() public {}

    function testCallHelloWithRole() public {}

    receive() external payable {}
}
