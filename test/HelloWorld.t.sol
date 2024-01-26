// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.20;

import {Test} from "@forge-std/Test.sol";
import {Roles} from "@src/Roles.sol";
import {MockHelloWorld} from "@test/mock/MockHelloWorld.sol";
import {MockAccessManager} from "@test/mock/MockAccessManager.sol";

import {console} from "@forge-std/console.sol";
import {console2} from "@forge-std/console2.sol";

contract TestHelloWorld is Test {
    event HelloWorld();

    address private admin = address(1);
    address public alice = address(2);
    address public bob = address(3);

    uint256 HOUR = 60 * 60;

    uint32 GRANT_DELAY = 24 hours;
    uint32 EXECUTION_DELAY = 5 hours;

    MockHelloWorld private helloWorld;
    MockAccessManager private accessManager;

    function setUp() public {
        accessManager = new MockAccessManager(admin);
        helloWorld = new MockHelloWorld(address(accessManager));

        vm.startPrank(admin);
        accessManager.setGrantDelay(Roles.ADMIN, GRANT_DELAY);

        accessManager.grantRole(Roles.ADMIN, admin, EXECUTION_DELAY);

        accessManager.setRoleAdmin(Roles.ADMIN, Roles.ADMIN);

        accessManager.setRoleAdmin(Roles.GOVERNOR, Roles.ADMIN);
        accessManager.setRoleAdmin(Roles.USER, Roles.ADMIN);
        accessManager.setRoleAdmin(Roles.GUARDIAN, Roles.ADMIN);

        vm.stopPrank();

        // accessManager.labelRole(Roles.ADMIN, "ADMIN");
    }

    function testTargetClose() public {
        vm.startPrank(admin);
        accessManager.setTargetClosed(address(helloWorld), true);
        assertEq(accessManager.isTargetClosed(address(helloWorld)), true);

        vm.expectRevert();
        helloWorld.hello();

        accessManager.setTargetClosed(address(helloWorld), false);
        assertEq(accessManager.isTargetClosed(address(helloWorld)), false);

        // vm.expectEmit(true, true, false, true, address(helloWorld));
        // emit HelloWorld();
        helloWorld.hello();
        vm.stopPrank();
    }

    function testRoleRestriction() public {
        vm.prank(admin);
        bool isGoverner;
        uint256 roleDelay;
        accessManager.grantRole(Roles.GOVERNOR, alice, EXECUTION_DELAY);
        (isGoverner, roleDelay) = accessManager.hasRole(Roles.GOVERNOR, alice);

        assertEq(isGoverner, true);
        assertEq(roleDelay, EXECUTION_DELAY);

        bytes4[] memory selectors;
        selectors = new bytes4[](1);
        selectors[0] = bytes4(keccak256("hello()"));

        vm.prank(admin);
        accessManager.setTargetFunctionRole(
            address(helloWorld),
            selectors,
            Roles.GOVERNOR
        );

        console.log("================test===============");
        // vm.expectEmit(true, true, false, true, address(helloWorld));
        // emit HelloWorld();

        vm.warp(block.timestamp + EXECUTION_DELAY);

        accessManager.schedule(
            address(helloWorld),
            selectors,
            block.timestamp + EXECUTION_DELAY
        );

        vm.prank(alice);
        helloWorld.hello();

        vm.warp(block.timestamp + EXECUTION_DELAY);

        vm.prank(alice);

        vm.expectRevert();

        helloWorld.hello();
    }

    receive() external payable {}
}
