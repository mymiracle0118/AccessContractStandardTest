// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.20;

import {Test} from "@forge-std/Test.sol";
import {Roles} from "@src/Roles.sol";
import {MockHelloWorld} from "@test/mock/MockHelloWorld.sol";
import {MockAccessManager} from "@test/mock/MockAccessManager.sol";

import {MockMultisigWallet} from "@test/mock/MockMultisigWallet.sol";

import {console} from "@forge-std/console.sol";
import {console2} from "@forge-std/console2.sol";

contract TestHelloWorld is Test {
    event HelloWorld();

    address private admin = address(1);
    address public alice = address(2);
    address public bob = address(3);
    address public ded = address(4);

    uint256 confirmationCount = 2;

    uint256 HOUR = 60 * 60;

    uint32 GRANT_DELAY = 24 hours;
    uint32 EXECUTION_DELAY = 5 hours;

    MockHelloWorld private helloWorld;
    MockAccessManager private accessManager;
    MockMultisigWallet private multisigWallet;

    function setUp() public {
        address[] memory owners = new address[](4);
        // address[] memory owners;
        owners[0] = admin;
        owners[1] = alice;
        owners[2] = bob;
        owners[3] = ded;

        multisigWallet = new MockMultisigWallet(owners, confirmationCount);

        accessManager = new MockAccessManager(admin);
        helloWorld = new MockHelloWorld(address(accessManager));

        vm.startPrank(admin);
        // accessManager.setGrantDelay(Roles.ADMIN, GRANT_DELAY);
        // accessManager.grantRole(Roles.ADMIN, admin, GRANT_DELAY);
        accessManager.grantRole(Roles.ADMIN, admin, 0);

        accessManager.setRoleAdmin(Roles.ADMIN, Roles.ADMIN);

        accessManager.setRoleAdmin(Roles.GOVERNOR, Roles.ADMIN);
        accessManager.setRoleAdmin(Roles.USER, Roles.ADMIN);
        accessManager.setRoleAdmin(Roles.GUARDIAN, Roles.ADMIN);

        vm.stopPrank();

        // accessManager.labelRole(Roles.ADMIN, "ADMIN");
    }

    function testUpdateAuthority() public {
        vm.prank(admin);
        accessManager.updateAuthority(address(helloWorld), address(helloWorld));
        assertEq(helloWorld.authority(), address(helloWorld));
    }

    function testTargetClose() public {
        vm.startPrank(admin);
        accessManager.setTargetClosed(address(helloWorld), true);
        assertEq(accessManager.isTargetClosed(address(helloWorld)), true);

        // vm.expectRevert();
        // helloWorld.hello();

        accessManager.setTargetClosed(address(helloWorld), false);
        assertEq(accessManager.isTargetClosed(address(helloWorld)), false);

        // vm.expectEmit(true, true, false, true, address(helloWorld));
        // emit HelloWorld();
        // helloWorld.hello();
        vm.stopPrank();
    }

    function testSetRole() public {
        bool isGoverner;
        uint256 roleDelay;

        vm.prank(admin);
        accessManager.setRoleAdmin(Roles.USER, Roles.GOVERNOR);

        assertEq(accessManager.getRoleAdmin(Roles.USER), Roles.GOVERNOR);

        vm.prank(admin);
        accessManager.grantRole(Roles.GOVERNOR, alice, 0);

        (isGoverner, roleDelay) = accessManager.hasRole(Roles.GOVERNOR, alice);

        assertEq(isGoverner, true);
        assertEq(roleDelay, 0);

        vm.prank(alice);
        accessManager.grantRole(Roles.USER, bob, 0);

        (isGoverner, roleDelay) = accessManager.hasRole(Roles.USER, bob);
        assertEq(isGoverner, true);
        assertEq(roleDelay, 0);
    }

    function testCallHelloWithRole() public {
        bool isGoverner;
        uint256 roleDelay;

        // // Time should be passed for grant role
        // vm.warp(block.timestamp + GRANT_DELAY + 1);

        // console.log("block timestamp", block.timestamp);

        // Set Governer role to the alice
        vm.prank(admin);
        accessManager.grantRole(Roles.GOVERNOR, alice, 0);

        // Check has role
        (isGoverner, roleDelay) = accessManager.hasRole(Roles.GOVERNOR, alice);

        assertEq(isGoverner, true);
        assertEq(roleDelay, 0);

        bytes4[] memory selectors2;
        selectors2 = new bytes4[](1);
        selectors2[0] = bytes4(keccak256("hello()"));

        vm.prank(admin);
        accessManager.setTargetFunctionRole(
            address(helloWorld),
            selectors2,
            Roles.GOVERNOR
        );

        // console.log("-----------get function role-----------");
        // console.log(
        //     accessManager.getTargetFunctionRole(
        //         address(helloWorld),
        //         selectors2[0]
        //     )
        // );

        // console.log("================test===============");
        // vm.expectEmit(true, true, false, true, address(helloWorld));
        // emit HelloWorld();
        // bytes4 FUNC_SELECTOR = bytes4(keccak256("hello()"));
        // bytes memory data = abi.encodeWithSelector(FUNC_SELECTOR);

        // vm.warp(block.timestamp + EXECUTION_DELAY);
        // vm.prank(alice);
        // accessManager.schedule(
        //     address(helloWorld),
        //     data,
        //     uint48(block.timestamp + GRANT_DELAY + 1)
        // );

        vm.warp(block.timestamp + GRANT_DELAY + 4);

        vm.prank(alice);
        helloWorld.hello();

        vm.prank(alice);

        // vm.expectRevert();

        helloWorld.hello();
    }

    function testExecutionWithAccessManager() public {
        bool isGoverner;
        uint256 roleDelay;

        vm.prank(admin);
        accessManager.grantRole(Roles.GOVERNOR, address(multisigWallet), 0);

        // Check has role
        (isGoverner, roleDelay) = accessManager.hasRole(
            Roles.GOVERNOR,
            address(multisigWallet)
        );

        assertEq(isGoverner, true);
        assertEq(roleDelay, 0);

        bytes4[] memory selectors2;
        selectors2 = new bytes4[](1);
        selectors2[0] = bytes4(keccak256("hello()"));

        vm.prank(admin);
        accessManager.setTargetFunctionRole(
            address(helloWorld),
            selectors2,
            Roles.GOVERNOR
        );

        vm.startPrank(ded);
        multisigWallet.submitTransaction(
            address(helloWorld),
            0,
            multisigWallet.getDataWithAccessManager()
        );
        vm.stopPrank();

        vm.prank(alice);
        multisigWallet.confirmTransaction(0);

        vm.prank(bob);
        multisigWallet.confirmTransaction(0);

        vm.prank(ded);
        multisigWallet.executeTransaction(0);
    }

    receive() external payable {}
}
