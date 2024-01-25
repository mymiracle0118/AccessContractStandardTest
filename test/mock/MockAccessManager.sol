// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.20;

import {HelloWorld} from "@src/HelloWorld.sol";

import {AccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";

contract MockAccessManager is AccessManager {
    constructor(address admin) AccessManager(admin) {}
}
