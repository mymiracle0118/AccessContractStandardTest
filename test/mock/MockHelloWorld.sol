// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.20;

import "@src/HelloWorld.sol";

contract MockHelloWorld is HelloWorld {
    constructor(address manager) HelloWorld(manager) {}
}
