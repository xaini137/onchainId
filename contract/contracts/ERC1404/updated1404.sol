//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

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
    function balanceOf(address account) external view returns (uint256);

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
    bytes32 public constant USER_REGISTRAR_ROLE = keccak256("USER_REGISTRAR_ROLE");
    string constant NON_US = "NonUS";
    string constant ACCREDITED = "Accredited";
    string constant INSTITUTIONAL = "Institutional";
    string constant CONTRACT = "Contract";

    mapping(address => string) private userTypes;

    event UserRegistered(address indexed user, string userType);

    modifier onlyRegistered(address user) {
        require(bytes(userTypes[user]).length != 0, "User not registered");
        _;
    }

    function register(
        address _user,
        string calldata _userType
    ) external onlyRole(USER_REGISTRAR_ROLE) {
        require(isValidUserType(_userType), "Invalid user type");
        userTypes[_user] = _userType;
        emit UserRegistered(_user, _userType);
    }

    function getUserType(address _user) external view returns (string memory) {
        return userTypes[_user];
    }

    function isRegistered(address _user) external view returns (bool) {
        return bytes(userTypes[_user]).length != 0;
    }

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

contract Whitelistable is AccessControl {
    bytes32 public constant WHITELISTER_ROLE = keccak256("WHITELISTER_ROLE");
    event WhitelistUpdate(address _address, bool status, string data);

    struct whiteListItem {
        bool status;
        string data;
    }

    mapping(address => whiteListItem) public whitelist;

    function setWhitelist(
        address to,
        bool status,
        string memory data
    ) public onlyRole(WHITELISTER_ROLE) returns (bool) {
        whitelist[to] = whiteListItem(status, data);
        emit WhitelistUpdate(to, status, data);
        return true;
    }

    function getWhitelistStatus(address _address) public view returns (bool) {
        return whitelist[_address].status;
    }

    function getWhitelistData(
        address _address
    ) public view returns (string memory) {
        return whitelist[_address].data;
    }

    function checkWhitelists(
        address from,
        address to
    ) external view returns (bool) {
        return whitelist[from].status;
    }
}

contract Timelockable is AccessControl {
    bytes32 public constant TIMELOCKER_ROLE = keccak256("TIMELOCKER_ROLE");
    struct LockupItem {
        uint256 amount;
        uint256 releaseTime;
    }

    mapping(address => LockupItem[]) public lockups;

    event AccountLock(
        address indexed _address,
        uint256 amount,
        uint256 releaseTime
    );
    event AccountRelease(address indexed _address, uint256 amount);

    function _lock(
        address _address,
        uint256 amount,
        uint256 releaseTime
    ) internal {
        require(releaseTime > block.timestamp, "Release time in the future");
        require(_address != address(0), "Address must be valid");
        lockups[_address].push(LockupItem(amount, releaseTime));
        emit AccountLock(_address, amount, releaseTime);
    }

    function lock(
        address _address,
        uint256 amount,
        uint256 releaseTime
    ) external returns (bool) {
        _lock(_address, amount, releaseTime);
        return true;
    }

    function release(
        address _address,
        uint256 amountToRelease
    ) public onlyRole(TIMELOCKER_ROLE) returns (bool) {
        require(_address != address(0), "Invalid address");

        uint256 totalReleased = 0;
        LockupItem[] storage userLockups = lockups[_address];

        for (uint256 i = 0; i < userLockups.length; i++) {
            if (
                userLockups[i].releaseTime <= block.timestamp &&
                totalReleased < amountToRelease
            ) {
                uint256 remainingAmount = amountToRelease - totalReleased;
                if (userLockups[i].amount <= remainingAmount) {
                    totalReleased = totalReleased + userLockups[i].amount;
                    userLockups[i].amount = 0;
                } else {
                    userLockups[i].amount =
                        userLockups[i].amount -
                        remainingAmount;
                    totalReleased = totalReleased + remainingAmount;
                }
            }
        }

        emit AccountRelease(_address, totalReleased);
        return true;
    }

    function checkTimelock(
        address _address,
        uint256 amount,
        uint256 balance
    ) external view returns (bool) {
        uint256 lockedAmount = getLockedAmount(_address);
        if (balance < amount) {
            return false;
        }
        uint256 nonLockedAmount = balance + lockedAmount;
        return amount <= nonLockedAmount;
    }

    function getLockedAmount(address _address) public view returns (uint256) {
        uint256 totalLocked = 0;
        LockupItem[] storage userLockups = lockups[_address];

        for (uint256 i = 0; i < userLockups.length; i++) {
            if (block.timestamp < userLockups[i].releaseTime) {
                totalLocked = totalLocked + userLockups[i].amount;
            }
        }

        return totalLocked;
    }
}

contract Proton is
    IERC1404,
    ERC20,
    AccessControl,
    Whitelistable,
    Timelockable,
    Pausable,
    UserRegistration,
    ERC20Pausable
{
    string constant TOKEN_NAME = "PROTON";
    string constant TOKEN_SYMBOL = "PRTN";
    uint8 constant TOKEN_DECIMALS = 18;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    IERC1404Success private transferRestrictions;
    event RestrictionsUpdated(
        address newRestrictionsAddress,
        address updatedBy
    );
    event Revoke(address indexed revoker, address indexed from, uint256 amount);

    constructor(
        address admin,
        address pauser,
        address minter,
        address registrar,
         address whitelister
    ) ERC20(TOKEN_NAME, TOKEN_SYMBOL) {
        _grantRole(USER_REGISTRAR_ROLE, registrar);
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(MINTER_ROLE, minter);
         _grantRole(WHITELISTER_ROLE, whitelister);
    }

    function updateTransferRestrictions(
        address _newRestrictionsAddress
    ) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        transferRestrictions = IERC1404Success(_newRestrictionsAddress);
        emit RestrictionsUpdated(address(transferRestrictions), msg.sender);
        return true;
    }

    function revoke(
        address _from,
        uint256 _amount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        ERC20._transfer(_from, msg.sender, _amount);
        emit Revoke(msg.sender, _from, _amount);
        return true;
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Pausable) {
        super._update(from, to, value);
    }

    function burn(
        address _from,
        uint256 _amount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        _burn(_from, _amount);
        return true;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function detectTransferRestriction(
        address from,
        address to,
        uint256 amount
    ) public view returns (uint8) {
        require(
            address(transferRestrictions) != address(0),
            "TransferRestrictions contract must be set"
        );
        return transferRestrictions.detectTransferRestriction(from, to, amount);
    }

    function detectTransferFromRestriction(
        address sender,
        address from,
        address to,
        uint256 amount
    ) public view returns (uint8) {
        require(
            address(transferRestrictions) != address(0),
            "TransferRestrictions contract must be set"
        );
        return
            transferRestrictions.detectTransferFromRestriction(
                sender,
                from,
                to,
                amount
            );
    }

    function messageForTransferRestriction(
        uint8 restrictionCode
    ) external view returns (string memory) {
        return
            transferRestrictions.messageForTransferRestriction(restrictionCode);
    }

    modifier notRestricted(
        address from,
        address to,
        uint256 value
    ) {
        uint8 restrictionCode = transferRestrictions.detectTransferRestriction(
            from,
            to,
            value
        );
        require(
            restrictionCode == transferRestrictions.getSuccessCode(),
            transferRestrictions.messageForTransferRestriction(restrictionCode)
        );
        _;
    }

    modifier notRestrictedTransferFrom(
        address sender,
        address from,
        address to,
        uint256 value
    ) {
        uint8 transferFromRestrictionCode = transferRestrictions
            .detectTransferFromRestriction(sender, from, to, value);
        require(
            transferFromRestrictionCode ==
                transferRestrictions.getSuccessCode(),
            transferRestrictions.messageForTransferRestriction(
                transferFromRestrictionCode
            )
        );
        _;
    }

    function transfer(
        address to,
        uint256 value
    )
        public
        override
        notRestricted(msg.sender, to, value)
        returns (bool success)
    {
        success = ERC20.transfer(to, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        override
        notRestrictedTransferFrom(msg.sender, from, to, value)
        returns (bool success)
    {
        success = ERC20.transferFrom(from, to, value);
    }
}
