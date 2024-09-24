// SPDX-License-Identifier: MIT
pragma solidity 0.5.8;

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

contract IERC1404Success is IERC1404getSuccessCode, IERC1404 {}

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

library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(
        Role storage role,
        address account
    ) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract OwnerRole {
    using Roles for Roles.Role;

    event OwnerAdded(address indexed addedOwner, address indexed addedBy);
    event OwnerRemoved(address indexed removedOwner, address indexed removedBy);

    Roles.Role private _owners;

    modifier onlyOwner() {
        require(
            isOwner(msg.sender),
            "OwnerRole: caller does not have the Owner role"
        );
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return _owners.has(account);
    }

    function addOwner(address account) public onlyOwner {
        _addOwner(account);
    }

    function removeOwner(address account) public onlyOwner {
        require(
            msg.sender != account,
            "Owners cannot remove themselves as owner"
        );
        _removeOwner(account);
    }

    function _addOwner(address account) internal {
        _owners.add(account);
        emit OwnerAdded(account, msg.sender);
    }

    function _removeOwner(address account) internal {
        _owners.remove(account);
        emit OwnerRemoved(account, msg.sender);
    }
}

contract Context {
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(
                amount,
                "ERC20: burn amount exceeds allowance"
            )
        );
    }
}

contract RevokerRole is OwnerRole {
    event RevokerAdded(address indexed addedRevoker, address indexed addedBy);
    event RevokerRemoved(
        address indexed removedRevoker,
        address indexed removedBy
    );

    Roles.Role private _revokers;

    modifier onlyRevoker() {
        require(
            isRevoker(msg.sender),
            "RevokerRole: caller does not have the Revoker role"
        );
        _;
    }

    function isRevoker(address account) public view returns (bool) {
        return _revokers.has(account);
    }

    function addRevoker(address account) public onlyOwner {
        _addRevoker(account);
    }

    function removeRevoker(address account) public onlyOwner {
        _removeRevoker(account);
    }

    function _addRevoker(address account) internal {
        _revokers.add(account);
        emit RevokerAdded(account, msg.sender);
    }

    function _removeRevoker(address account) internal {
        _revokers.remove(account);
        emit RevokerRemoved(account, msg.sender);
    }
}

contract Revocable is ERC20, RevokerRole {
    event Revoke(address indexed revoker, address indexed from, uint256 amount);

    function revoke(
        address _from,
        uint256 _amount
    ) public onlyRevoker returns (bool) {
        ERC20._transfer(_from, msg.sender, _amount);
        emit Revoke(msg.sender, _from, _amount);
        return true;
    }
}

contract WhitelisterRole is OwnerRole {
    event WhitelisterAdded(
        address indexed addedWhitelister,
        address indexed addedBy
    );
    event WhitelisterRemoved(
        address indexed removedWhitelister,
        address indexed removedBy
    );

    Roles.Role private _whitelisters;

    modifier onlyWhitelister() {
        require(
            isWhitelister(msg.sender),
            "WhitelisterRole: caller does not have the Whitelister role"
        );
        _;
    }

    function isWhitelister(address account) public view returns (bool) {
        return _whitelisters.has(account);
    }

    function addWhitelister(address account) public onlyOwner {
        _addWhitelister(account);
    }
    function removeWhitelister(address account) public onlyOwner {
        _removeWhitelister(account);
    }

    function _addWhitelister(address account) internal {
        _whitelisters.add(account);
        emit WhitelisterAdded(account, msg.sender);
    }

    function _removeWhitelister(address account) internal {
        _whitelisters.remove(account);
        emit WhitelisterRemoved(account, msg.sender);
    }
}

contract Whitelistable is WhitelisterRole {
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
    ) public onlyWhitelister onlyOwner returns (bool) {
        require(isWhitelister(to), "Add to whitelist");
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
        return whitelist[from].status && whitelist[to].status;
    }
}

contract TimelockerRole is OwnerRole {
    event TimelockerAdded(
        address indexed addedTimelocker,
        address indexed addedBy
    );
    event TimelockerRemoved(
        address indexed removedTimelocker,
        address indexed removedBy
    );

    Roles.Role private _timelockers;

    modifier onlyTimelocker() {
        require(
            isTimelocker(msg.sender),
            "TimelockerRole: caller does not have the Timelocker role"
        );
        _;
    }

    function isTimelocker(address account) public view returns (bool) {
        return _timelockers.has(account);
    }

    function addTimelocker(address account) public onlyOwner {
        _addTimelocker(account);
    }

    function removeTimelocker(address account) public onlyOwner {
        _removeTimelocker(account);
    }

    function _addTimelocker(address account) internal {
        _timelockers.add(account);
        emit TimelockerAdded(account, msg.sender);
    }

    function _removeTimelocker(address account) internal {
        _timelockers.remove(account);
        emit TimelockerRemoved(account, msg.sender);
    }
}
contract UserRegistration is OwnerRole {
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
        require(bytes(userTypes[_user]).length == 0, "User already registered");
        require(isValidUserType(_userType), "Invalid user type");
        userTypes[_user] = _userType;
        emit UserRegistered(_user, _userType);
    }

    // Function to get the user type for a registered user
    function getUserType(
        address _user
    ) external view onlyRegistered(_user) returns (string memory) {
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
contract Timelockable {
    using SafeMath for uint256;
    uint NON_US = 300;
    uint ACCREDITED = 180;
    uint INSTITUTIONAL = 0;

    struct LockupItem {
        uint256 amount;
        uint256 lockTime;
    }

    mapping(address => LockupItem[]) public lockups;

    event AccountLock(
        address indexed _address,
        uint256 amount,
        uint256 lockTime
    );
    event AccountRelease(address indexed _address, uint256 amount);
    function setlockPeroidDetail(uint userType, uint lockdays) external {
        if (userType == 1) {
            NON_US = lockdays;
        }
        if (userType == 2) {
            ACCREDITED = lockdays;
        }
        if (userType == 3) {
            INSTITUTIONAL = lockdays;
        }
    }

    function getlockPeroidDetail() external view returns (uint, uint, uint) {
        return (NON_US, ACCREDITED, INSTITUTIONAL);
    }

    function _lock(
        address _address,
        uint256 amount,
        uint256 lockTime
    ) internal {
        require(_address != address(0), "Address must be valid for lockup");

        lockups[_address].push(LockupItem(amount, lockTime));
        emit AccountLock(_address, amount, lockTime);
    }

    // Function to lock tokens for a user
    function lock(
        address _address,
        uint256 amount,
        uint256 releaseTime
    ) external returns (bool) {
        _lock(_address, amount, releaseTime);
        return true;
    }

    // Function to release tokens for a user
    // function release(
    //     address _address,
    //     uint256 amountToRelease
    //     ) public returns (bool) {
    //     require(_address != address(0), "Address must be valid for release");

    //     uint256 totalReleased = 0;

    //     LockupItem[] storage userLockups = lockups[_address];

    //     for (uint256 i = 0; i < userLockups.length; i++) {
    //         if (
    //             userLockups[i].lock <= now &&
    //             totalReleased < amountToRelease
    //         ) {
    //             uint256 remainingAmount = amountToRelease.sub(totalReleased);
    //             if (userLockups[i].amount <= remainingAmount) {
    //                 totalReleased = totalReleased.add(userLockups[i].amount);
    //                 userLockups[i].amount = 0; // Mark the lockup as fully released
    //             } else {
    //                 userLockups[i].amount = userLockups[i].amount.sub(
    //                     remainingAmount
    //                 );
    //                 totalReleased = totalReleased.add(remainingAmount);
    //             }
    //         }
    //     }

    //     emit AccountRelease(_address, totalReleased);
    //     return true;
    // }

    // Function to check if a certain amount can be transferred by a user
    function checkTimelock(
        address _address,
        uint256 amount,
        uint256 balance
    ) external view returns (bool) {
        uint256 lockedAmount = getLockedAmount(_address);

        if (balance < amount) {
            return false;
        }

        uint256 nonLockedAmount = balance.sub(lockedAmount);
        return amount <= nonLockedAmount;
    }

    function getLockedAmount(
        address from,
        address to
    ) public view returns (uint256) {
        uint256 totalLocked = 0;

        // Get user types for both from and to addresses
        string memory userTypeFrom = getUserType(from);
        string memory userTypeTo = getUserType(to);

        // Get lockup items for the from address
        LockupItem[] storage userLockups = lockups[from];

        uint lockTimeRequired = 0; // This will hold the lock period required

        // Determine the lock period based on the from and to user types
        if (
            keccak256(abi.encodePacked(userTypeFrom)) ==
            keccak256(abi.encodePacked(ACCREDITED)) &&
            keccak256(abi.encodePacked(userTypeTo)) ==
            keccak256(abi.encodePacked(ACCREDITED))
        ) {
            lockTimeRequired = ACCREDITED;
        } else if (
            keccak256(abi.encodePacked(userTypeFrom)) ==
            keccak256(abi.encodePacked(INSTITUTIONAL)) &&
            keccak256(abi.encodePacked(userTypeTo)) ==
            keccak256(abi.encodePacked(ACCREDITED))
        ) {
            lockTimeRequired = INSTITUTIONAL;
        } else if (
            keccak256(abi.encodePacked(userTypeFrom)) ==
            keccak256(abi.encodePacked(NON_US)) &&
            keccak256(abi.encodePacked(userTypeTo)) ==
            keccak256(abi.encodePacked(ACCREDITED))
        ) {
            lockTimeRequired = NON_US;
        } else {
            totalLocked = 0;
        }
        for (uint256 i = 0; i < userLockups.length; i++) {
            if (now < userLockups[i].lockTime.add(lockTimeRequired)) {
                totalLocked = totalLocked.add(userLockups[i].amount);
            }
        }
        return totalLocked;
    }

    // Function to check all lockups for a user
    function checkLockup(
        address _address
    ) public view returns (uint256[] memory, uint256[] memory) {
        LockupItem[] storage userLockups = lockups[_address];
        uint256[] memory amounts = new uint256[](userLockups.length);
        uint256[] memory releaseTimes = new uint256[](userLockups.length);

        for (uint256 i = 0; i < userLockups.length; i++) {
            amounts[i] = userLockups[i].amount;
            releaseTimes[i] = userLockups[i].lockTime;
        }

        return (amounts, releaseTimes);
    }
}

contract PauserRole is OwnerRole {
    event PauserAdded(address indexed addedPauser, address indexed addedBy);
    event PauserRemoved(
        address indexed removedPauser,
        address indexed removedBy
    );

    Roles.Role private _pausers;

    modifier onlyPauser() {
        require(
            isPauser(msg.sender),
            "PauserRole: caller does not have the Pauser role"
        );
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyOwner {
        _addPauser(account);
    }

    function removePauser(address account) public onlyOwner {
        _removePauser(account);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account, msg.sender);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account, msg.sender);
    }
}

contract Pausable is PauserRole {
    event Paused();
    event Unpaused();

    bool private _paused;

    function paused() external view returns (bool) {
        return _paused;
    }

    function _pause() internal {
        _paused = true;
        emit Paused();
    }

    function _unpause() internal {
        _paused = false;
        emit Unpaused();
    }

    function pause() public onlyPauser {
        _pause();
    }

    function unpause() public onlyPauser {
        _unpause();
    }
}

contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract Proton is
    IERC1404,
    IERC1404Validators,
    IERC20,
    ERC20Detailed,
    OwnerRole,
    Revocable,
    Whitelistable,
    Timelockable,
    Pausable
{
    string constant TOKEN_NAME = "PROTON Token";
    string constant TOKEN_SYMBOL = "PRTN";
    uint8 constant TOKEN_DECIMALS = 18;
    uint256 constant HUNDRED_MILLION = 1;
    uint256 constant TOKEN_SUPPLY =
        2 * HUNDRED_MILLION * (10 ** uint256(TOKEN_DECIMALS));
    IERC1404Success private transferRestrictions;
    event RestrictionsUpdated(
        address newRestrictionsAddress,
        address updatedBy
    );

    constructor() public ERC20Detailed("Proton Token", "PRTN", 18) {
        _mint(msg.sender, TOKEN_SUPPLY);
        _addOwner(msg.sender);
    }

    function updateTransferRestrictions(
        address _newRestrictionsAddress
    ) public onlyOwner returns (bool) {
        transferRestrictions = IERC1404Success(_newRestrictionsAddress);
        emit RestrictionsUpdated(address(transferRestrictions), msg.sender);
        return true;
    }

    function mint(address user, uint256 amount) external onlyOwner {
        // uint8 restrictionCode = transferRestrictions.detectTransferRestriction(msg.sender, user, amount);
        // require(restrictionCode == transferRestrictions.getSuccessCode(), transferRestrictions.messageForTransferRestriction(restrictionCode));
        _mint(user, amount);
    }

    function getRestrictionsAddress() public view returns (address) {
        return address(transferRestrictions);
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
    ) public notRestricted(msg.sender, to, value) returns (bool success) {
        success = ERC20.transfer(to, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        notRestrictedTransferFrom(msg.sender, from, to, value)
        returns (bool success)
    {
        success = ERC20.transferFrom(from, to, value);
    }
}
