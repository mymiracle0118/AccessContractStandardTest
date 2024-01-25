// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.13;

import {Test} from "@forge-std/Test.sol";
import {Core} from "@src/Core.sol";
import {Roles} from "@src/Roles.sol";
import {MockHelloWorld} from "@test/mock/MockHelloWorld.sol";

import {console} from "@forge-std/console.sol";
import {console2} from "@forge-std/console2.sol";

contract TesthelloWorld is Test {
    address private governor = address(1);
    address private guardian = address(2);
    address private user = address(3);
    address private admin = address(4);

    Core private core;
    MockHelloWorld private helloWorld;

    event HellowUpdate(address indexed oldCore, address indexed newCore);

    /// @notice HelloWorld emit for Admin
    event HellowWorldAdmin();

    /// @notice HelloWorld emit for User
    event HellowWorldUser();

    /// @notice HelloWorld emit for Governer
    event HellowWorldGoverner();

    function revertMe() external pure {
        revert();
    }

    function setUp() public {
        core = new Core();
        console.log("test");
        console.log(uint256(Roles.ADMIN));
        core.grantRole(Roles.ADMIN, admin);
        core.grantRole(Roles.GOVERNOR, governor);
        core.grantRole(Roles.GUARDIAN, guardian);
        core.grantRole(Roles.USER, user);

        core.renounceRole(Roles.ADMIN, address(this));

        helloWorld = new MockHelloWorld(address(core));

        vm.label(address(core), "core");
        vm.label(address(helloWorld), "helloWorld");
    }

    function testSetup() public {
        assertEq(address(helloWorld.core()), address(core));
    }

    function testSetCoreSucceeds() public {
        Core core2 = new Core();

        vm.prank(admin);

        vm.expectEmit(true, true, false, true, address(helloWorld));
        emit HellowUpdate(address(core), address(core2));

        helloWorld.setCore(address(core2));

        assertEq(address(helloWorld.core()), address(core2));
    }

    function testSetCoreAddressZeroSucceedsBricksContract() public {
        vm.prank(admin);
        vm.expectEmit(true, true, false, true, address(helloWorld));
        emit HellowUpdate(address(core), address(0));

        helloWorld.setCore(address(0));

        assertEq(address(helloWorld.core()), address(0));

        // cannot check role because core doesn't respond
        vm.expectRevert();
        helloWorld.pause();
    }

    function testSetCoreFails() public {
        vm.expectRevert("UNAUTHORIZED");
        helloWorld.setCore(address(0));

        assertEq(address(helloWorld.core()), address(core));
    }

    function testHelloWorldForAdmin() public {
        vm.prank(admin);

        vm.expectEmit(true, true, false, true, address(helloWorld));
        emit HellowWorldAdmin();

        helloWorld.helloWorldAdmin();

        vm.expectRevert();
        vm.prank(address(this));
        helloWorld.helloWorldAdmin();
    }

    function testHelloWorldForGoverner() public {
        vm.prank(governor);

        vm.expectEmit(true, true, false, true, address(helloWorld));
        emit HellowWorldGoverner();

        helloWorld.helloWorlGoverner();

        vm.expectRevert();
        vm.prank(address(this));
        helloWorld.helloWorlGoverner();
    }

    function testHelloWorldForUser() public {
        vm.prank(user);

        vm.expectEmit(true, true, false, true, address(helloWorld));
        emit HellowWorldUser();

        helloWorld.helloWorldUser();

        vm.expectRevert();
        vm.prank(address(this));
        helloWorld.helloWorldUser();
    }

    function testPausableSucceedsGuardian() public {
        assertTrue(!helloWorld.paused());
        vm.prank(guardian);
        helloWorld.pause();
        assertTrue(helloWorld.paused());
        vm.prank(guardian);
        helloWorld.unpause();
        assertTrue(!helloWorld.paused());
    }

    function testPauseFailsNonGuardian() public {
        vm.expectRevert("UNAUTHORIZED");
        helloWorld.pause();
    }

    receive() external payable {}
}
