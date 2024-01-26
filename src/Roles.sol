// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.20;

/**
@author Iwaki Hiroto
@title Roles
@notice Holds a complete list of all roles which can be held by contracts inside the Project.
*/
library Roles {
    /// ----------- Core roles for access control --------------

    /// @notice the all-powerful role. Controls all other roles and protocol functionality.
    uint64 internal constant GOVERNOR = 40;

    /// @notice can do anything arbitrarily
    uint64 internal constant ADMIN = 41;

    /// @notice
    uint64 internal constant USER = 42;

    /// @notice
    uint64 internal constant GUARDIAN = 43;
}
