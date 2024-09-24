// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

interface IERC1404 {
    function detectTransferRestriction(
        address from,
        address to,
        uint256 value
    ) external view returns (uint8);
    function detectTransferFromRestriction(
        address sender,
        address from,
        address to,
        uint256 value
    ) external view returns (uint8);
    function messageForTransferRestriction(
        uint8 restrictionCode
    ) external view returns (string memory);
}
interface IERC1404getSuccessCode {
    function getSuccessCode() external view returns (uint256);
}

abstract contract IERC1404Success is IERC1404getSuccessCode, IERC1404 {}

    interface IERC1404Validators {
    function balanceOf(address account) external  view returns (uint256);
    function paused() external view returns (bool);
    function checkWhitelists(
        address from,
        address to
    ) external view returns (bool);
    function checkTimelock(
        address _address,
        uint256 amount,
        uint256 balance
    ) external view returns (bool);
    function isRegistered(address _user) external view returns (bool);
}


contract UserRegistration is AccessControl {
       bytes32 public constant REGISTER_ROLE = keccak256("USER_ROLE");
    // Define user types as constants
    string constant NON_US = "NonUS";
    string constant ACCREDITED = "Accredited";
    string constant INSTITUTIONAL = "Institutional";
    string constant CONTRACT = "Contract";

    // Mapping to store registered users and their types
    mapping(address => string) private userTypes;

    // Event to log the registration of users
    event UserRegistered(address indexed user, string userType);

    // Modifier to ensure that a user is registered
    modifier onlyRegistered(address user) {
        require(bytes(userTypes[user]).length != 0, "User not registered");
        _;
    }

    // Function to register a user with a specified type (only callable by the owner)
    function register(
        address _user,
        string calldata _userType
    ) external onlyOwner {
        // require(bytes(userTypes[_user]).length == 0, "User already registered");
        require(isValidUserType(_userType), "Invalid user type");
        userTypes[_user] = _userType;
        emit UserRegistered(_user, _userType);
    }

    // Function to get the user type for a registered user
    function getUserType(
        address _user
    ) external view  returns (string memory) {
        return userTypes[_user];
    }

    // Function to check if a user is registered
    function isRegistered(address _user) external view returns (bool) {
        return bytes(userTypes[_user]).length != 0;
    }

    // Function to validate the provided user type
    function isValidUserType(
        string memory _userType
    ) internal pure returns (bool) {
        return (keccak256(abi.encodePacked(_userType)) ==
            keccak256(abi.encodePacked(NON_US)) ||
            keccak256(abi.encodePacked(_userType)) ==
            keccak256(abi.encodePacked(ACCREDITED)) ||
            keccak256(abi.encodePacked(_userType)) ==
            keccak256(abi.encodePacked(CONTRACT)) ||
            keccak256(abi.encodePacked(_userType)) ==
            keccak256(abi.encodePacked(INSTITUTIONAL)));
    }
}

contract MyToken is ERC20, ERC20Burnable, ERC20Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");


    constructor( address pauser, address minter)
        ERC20("MyToken", "MTK")
       
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(MINTER_ROLE, minter);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
}
