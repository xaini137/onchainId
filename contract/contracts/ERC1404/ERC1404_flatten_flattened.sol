
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol


// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// File: ERC1404/ERC1404_flatten.sol


pragma solidity 0.8.20;

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



contract RevokerRole is OwnerRole {
      using Roles for Roles.Role;
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


contract WhitelisterRole is OwnerRole {
       using Roles for Roles.Role;
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
       using Roles for Roles.Role;
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

contract Timelockable {
    using SafeMath for uint256;

    struct LockupItem {
        uint256 amount;
        uint256 releaseTime;
    }

    // Mapping from user address to an array of lockup items
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
        require(releaseTime > block.timestamp, "Release time needs to be in the future");
        require(_address != address(0), "Address must be valid for lockup");
        lockups[_address].push(LockupItem(amount, releaseTime));
        emit AccountLock(_address, amount, releaseTime);
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
    function release(
        address _address,
        uint256 amountToRelease
     ) public returns (bool) {
        require(_address != address(0), "Address must be valid for release");

        uint256 totalReleased = 0;

        LockupItem[] storage userLockups = lockups[_address];

        for (uint256 i = 0; i < userLockups.length; i++) {
            if (
                userLockups[i].releaseTime <= block.timestamp &&
                totalReleased < amountToRelease
            ) {
                uint256 remainingAmount = amountToRelease.sub(totalReleased);
                if (userLockups[i].amount <= remainingAmount) {
                    totalReleased = totalReleased.add(userLockups[i].amount);
                    userLockups[i].amount = 0; // Mark the lockup as fully released
                } else {
                    userLockups[i].amount = userLockups[i].amount.sub(
                        remainingAmount
                    );
                    totalReleased = totalReleased.add(remainingAmount);
                }
            }
        }

        emit AccountRelease(_address, totalReleased);
        return true;
    }

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

    function getLockedAmount(address _address) public view returns (uint256) {
        uint256 totalLocked = 0;
       
        LockupItem[] storage userLockups = lockups[_address];

        for (uint256 i = 0; i < userLockups.length; i++) {
            if (block.timestamp < userLockups[i].releaseTime) {
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
            releaseTimes[i] = userLockups[i].releaseTime;
        }

        return (amounts, releaseTimes);
    }
}

contract PauserRole is OwnerRole {
       using Roles for Roles.Role;
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

contract Proton is
    IERC1404,
    
   ERC20,
    OwnerRole,
    RevokerRole,
    Whitelistable,
    Timelockable,
    Pausable,
    UserRegistration
    
 {
    string constant TOKEN_NAME = "PROTON Token";
    string constant TOKEN_SYMBOL = "PRTN";
    uint8 constant TOKEN_DECIMALS = 18;
    uint256 constant HUNDRED_MILLION = 100;
    uint256 constant TOKEN_SUPPLY =
        2 * HUNDRED_MILLION * (10 ** uint256(TOKEN_DECIMALS));
    IERC1404Success private transferRestrictions;
    event RestrictionsUpdated(
        address newRestrictionsAddress,
        address updatedBy
    );

    constructor()  ERC20("Proton Token", "PRTN") {
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
   event Revoke(address indexed revoker, address indexed from, uint256 amount);

    function revoke(
        address _from,
        uint256 _amount
    ) public onlyRevoker returns (bool) {
        ERC20._transfer(_from, msg.sender, _amount);
        emit Revoke(msg.sender, _from, _amount);
        return true;
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
    ) override  public notRestricted(msg.sender, to, value) returns (bool success) {
        success = ERC20.transfer(to, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
    override 
        public
        notRestrictedTransferFrom(msg.sender, from, to, value)
        returns (bool success)
    {
        success = ERC20.transferFrom(from, to, value);
    }
}
