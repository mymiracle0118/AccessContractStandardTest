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
    bytes32 internal constant GOVERNOR = keccak256("GOVERNOR_ROLE");

    /// @notice can do anything arbitrarily
    bytes32 internal constant ADMIN = keccak256("ADMIN_ADMIN_ROLE");

    /// @notice
    bytes32 internal constant USER = keccak256("USER_ROLE");

    /// @notice
    bytes32 internal constant GUARDIAN = keccak256("GUARDIAN_ROLE");
}
