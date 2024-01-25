// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.13;

import {HelloWorld} from "@src/HelloWorld.sol";

contract MockHelloWorld is HelloWorld {
    constructor(address core) HelloWorld(core) {}
}
