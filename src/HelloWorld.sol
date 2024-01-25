// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.20;

import {Roles} from "@src/Roles.sol";

import {AccessManaged} from "@openzeppelin/contracts/access/manager/AccessManaged.sol";

import {console} from "@forge-std/console.sol";
import {console2} from "@forge-std/console2.sol";

/// @title A HelloWorld to Core
/// @author Iwaki Hiroto
/// @notice defines some modifiers and utilities around interacting with Core
contract HelloWorld is AccessManaged {
    event HelloWorld();

    constructor(address manager) AccessManaged(manager) {}

    function hello() public restricted {
        emit HelloWorld();
    }

    // authority()
    // setAuthority(address newAuthority)
    // isConsumingScheduledOp()
}
