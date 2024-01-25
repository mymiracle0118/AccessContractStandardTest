// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.13;

import {Core} from "@src/Core.sol";
import {Roles} from "@src/Roles.sol";

import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

import {console} from "@forge-std/console.sol";
import {console2} from "@forge-std/console2.sol";

/// @title A HelloWorld to Core
/// @author Iwaki Hiroto
/// @notice defines some modifiers and utilities around interacting with Core
abstract contract HelloWorld is Pausable {
    /// @notice emitted when the reference to core is updated
    event HellowUpdate(address indexed oldCore, address indexed newCore);

    /// @notice HelloWorld emit for Admin
    event HellowWorldAdmin();

    /// @notice HelloWorld emit for User
    event HellowWorldUser();

    /// @notice HelloWorld emit for Governer
    event HellowWorldGoverner();

    /// @notice reference to Core
    Core private _core;

    constructor(address coreAddress) {
        _core = Core(coreAddress);
        // console2.log("----core address----");
        console.log(address(_core));
    }

    /// @notice named onlyCore to prevent collision with OZ onlyRole modifier
    modifier onlyCore(bytes32 role) {
        require(_core.hasRole(role, msg.sender), "UNAUTHORIZED");
        _;
    }

    /// @notice address of the Core contract referenced
    function core() public view returns (Core) {
        // console2.log("core() function indside");
        return _core;
    }

    /// @notice WARNING CALLING THIS FUNCTION CAN POTENTIALLY
    /// BRICK A CONTRACT IF CORE IS SET INCORRECTLY
    /// @notice set new reference to core
    /// only callable by governor
    /// @param newCore to reference
    function setCore(address newCore) external onlyCore(Roles.ADMIN) {
        _setCore(newCore);
    }

    /// @notice WARNING CALLING THIS FUNCTION CAN POTENTIALLY
    /// BRICK A CONTRACT IF CORE IS SET INCORRECTLY
    /// @notice set new reference to core
    /// @param newCore to reference
    function _setCore(address newCore) internal {
        address oldCore = address(_core);
        _core = Core(newCore);

        emit HellowUpdate(oldCore, newCore);
    }

    /// @notice set pausable methods to paused
    function pause() public onlyCore(Roles.GUARDIAN) {
        _pause();
    }

    /// @notice set pausable methods to unpaused
    function unpause() public onlyCore(Roles.GUARDIAN) {
        _unpause();
    }

    /// @notice emit hellow world event
    function helloWorldAdmin() public onlyCore(Roles.ADMIN) {
        emit HellowWorldAdmin();
    }

    /// @notice emit hellow world event
    function helloWorlGoverner() public onlyCore(Roles.GOVERNOR) {
        emit HellowWorldGoverner();
    }

    /// @notice emit hellow world event
    function helloWorldUser() public onlyCore(Roles.USER) {
        emit HellowWorldUser();
    }
}
