// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.20;

import {HelloWorld} from "@src/HelloWorld.sol";

contract MockHelloWorld is HelloWorld {
    constructor(address manager) HelloWorld(manager) {}
}
