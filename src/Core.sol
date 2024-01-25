// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.13;

import {Roles} from "@src/Roles.sol";
import {AccessControlEnumerable} from "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

/// @title manage roleof the Projet
/// @author Iwaki Hiroto
/// @notice maintains roles and access control
contract Core is AccessControlEnumerable {
    /// @notice construct Core
    constructor() {
        // renounceRole(bytes32 role, address account)
        _grantRole(Roles.ADMIN, msg.sender);

        // Initial roles setup: direct hierarchy, everything under governor
        _setRoleAdmin(Roles.GOVERNOR, Roles.ADMIN);
        _setRoleAdmin(Roles.GUARDIAN, Roles.ADMIN);
        _setRoleAdmin(Roles.USER, Roles.ADMIN);
    }

    /// @notice creates a new role to be maintained
    /// @param role the new role id
    /// @param adminRole the admin role id for `role`
    /// @dev can also be used to update admin of existing role
    function createRole(
        bytes32 role,
        bytes32 adminRole
    ) external onlyRole(Roles.ADMIN) {
        _setRoleAdmin(role, adminRole);
    }

    // AccessControlEnumerable is AccessControl, and also has the following functions :
    // hasRole(bytes32 role, address account) -> bool
    // getRoleAdmin(bytes32 role) -> bytes32
    // grantRole(bytes32 role, address account)
    // revokeRole(bytes32 role, address account)
    // renounceRole(bytes32 role, address account)
    // getRoleMember(bytes32 role, uint256 index)
    // getRoleMemberCount(bytes32 role)
}
