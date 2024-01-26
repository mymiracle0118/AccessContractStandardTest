// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.20;

import {Test} from "@forge-std/Test.sol";
import {Roles} from "@src/Roles.sol";
import {MockHelloWorld} from "@test/mock/MockHelloWorld.sol";
import {MockAccessManager} from "@test/mock/MockAccessManager.sol";

import {console} from "@forge-std/console.sol";
import {console2} from "@forge-std/console2.sol";

contract TesthelloWorld is Test {
    event HelloWorld();

    address private admin = address(1);
    address public alice = address(2);
    address public bob = address(3);

    uint256 HOUR = 60 * 60;

    uint256 GRANT_DELAY = 24 * HOUR;
    uint256 EXECUTION_DELAY = 5 * HOUR;
    uint256 ACCOUNT = admin;

    MockHelloWorld private helloWorld;
    MockAccessManager private accessManager;

    function setUp() public {
        accessManager = new MockAccessManager(admin);
        helloWorld = new MockHelloWorld(accessManager);

        vm.prank(admin);
        accessManager.setGrantDelay(Role.ADMIN, GRANT_DELAY);

        vm.prank(admin);
        accessManager.grantRole(Role.ADMIN, admin, EXECUTION_DELAY);

        accessManager.setRoleAdmin(Role.ADMIN, Role.ADMIN);
        accessManager.setRoleAdmin(Role.GOVERNOR, Role.ADMIN);
        accessManager.setRoleAdmin(Role.USER, Role.ADMIN);
        accessManager.setRoleAdmin(Role.GUARDIAN, Role.ADMIN);

        accessManager.labelRole(Role.ADMIN, "ADMIN");
    }

    function testSchedule() public {}

    function testTargetClose() public {
        vm.prank(admin);
        accessManager.setTargetClosed(helloWorld, true);

        vm.expectRevert();
        vm.prank(admin);
        helloWorld.hello();

        vm.prank(admin);
        accessManager.setTargetClosed(target, false);

        assertEq(accessManager.isTargetClosed(helloWorld), true);

        vm.expectRevert();
        helloWorld.hello();

        vm.expectEmit(true, true, false, true, address(helloWorld));
        emit HelloWorld();

        assertEq(accessManager.isTargetClosed(helloWorld), false);
    }

    function testRoleRestriction() public {
        vm.prank(admin);
        accessManager.grantRole(Roles.GOVENER, alice, EXECUTION_DELAY);
        (isGoverner, roleDelay) = accessManager.hasRole(Roles.GOVENER, alice);

        assertEq(isGoverner, true);
        assertEq(roleDelay, EXECUTION_DELAY);

        accessManager.setTargetFunctionRole(
            helloWorld,
            [helloWorld.hello.selector],
            Roles.GOVENER
        );
        vm.prank(alice);

        vm.expectEmit(true, true, false, true, address(helloWorld));
        emit HelloWorld();

        helloWorld.hello();

        vm.warp(block.timestamp + ROUND_DURATION);

        vm.prank(alice);

        vm.expectRevert();

        helloWorld.hello();
    }

    // function testSetCoreSucceeds() public {
    //     Core core2 = new Core();

    //     vm.prank(admin);

    //     vm.expectEmit(true, true, false, true, address(helloWorld));
    //     emit HellowUpdate(address(core), address(core2));

    //     helloWorld.setCore(address(core2));

    //     assertEq(address(helloWorld.core()), address(core2));
    // }

    // function testSetCoreAddressZeroSucceedsBricksContract() public {
    //     vm.prank(admin);
    //     vm.expectEmit(true, true, false, true, address(helloWorld));
    //     emit HellowUpdate(address(core), address(0));

    //     helloWorld.setCore(address(0));

    //     assertEq(address(helloWorld.core()), address(0));

    //     // cannot check role because core doesn't respond
    //     vm.expectRevert();
    //     helloWorld.pause();
    // }

    // function testSetCoreFails() public {
    //     vm.expectRevert("UNAUTHORIZED");
    //     helloWorld.setCore(address(0));

    //     assertEq(address(helloWorld.core()), address(core));
    // }

    // function testHelloWorldForAdmin() public {
    //     vm.prank(admin);

    //     vm.expectEmit(true, true, false, true, address(helloWorld));
    //     emit HellowWorldAdmin();

    //     helloWorld.helloWorldAdmin();

    //     vm.expectRevert();
    //     vm.prank(address(this));
    //     helloWorld.helloWorldAdmin();
    // }

    // function testHelloWorldForGoverner() public {
    //     vm.prank(governor);

    //     vm.expectEmit(true, true, false, true, address(helloWorld));
    //     emit HellowWorldGoverner();

    //     helloWorld.helloWorlGoverner();

    //     vm.expectRevert();
    //     vm.prank(address(this));
    //     helloWorld.helloWorlGoverner();
    // }

    // function testHelloWorldForUser() public {
    //     vm.prank(user);

    //     vm.expectEmit(true, true, false, true, address(helloWorld));
    //     emit HellowWorldUser();

    //     helloWorld.helloWorldUser();

    //     vm.expectRevert();
    //     vm.prank(address(this));
    //     helloWorld.helloWorldUser();
    // }

    // function testPausableSucceedsGuardian() public {
    //     assertTrue(!helloWorld.paused());
    //     vm.prank(guardian);
    //     helloWorld.pause();
    //     assertTrue(helloWorld.paused());
    //     vm.prank(guardian);
    //     helloWorld.unpause();
    //     assertTrue(!helloWorld.paused());
    // }

    // function testPauseFailsNonGuardian() public {
    //     vm.expectRevert("UNAUTHORIZED");
    //     helloWorld.pause();
    // }

    receive() external payable {}
}
