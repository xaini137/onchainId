
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;
// import "hardhat///console.sol";
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

abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(
        address sender,
        uint256 balance,
        uint256 needed
    );

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
    error ERC20InsufficientAllowance(
        address spender,
        uint256 allowance,
        uint256 needed
    );

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

interface IERC721Errors {

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

interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(
        address sender,
        uint256 balance,
        uint256 needed,
        uint256 tokenId
    );

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

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

abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256))
        private _allowances;

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
    function allowance(
        address owner,
        address spender
    ) public view virtual returns (uint256) {
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
    function approve(
        address spender,
        uint256 value
    ) public virtual returns (bool) {
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
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual returns (bool) {
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
    function _approve(
        address owner,
        address spender,
        uint256 value,
        bool emitEvent
    ) internal virtual {
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
    function _spendAllowance(
        address owner,
        address spender,
        uint256 value
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(
                    spender,
                    currentAllowance,
                    value
                );
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

interface IProton {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function detectTransferRestriction(
        address from,
        address to,
        uint256 amount
    ) external view returns (uint8);
    function detectTransferFromRestriction(
        address sender,
        address from,
        address to,
        uint256 amount
    ) external view returns (uint8);
    function messageForTransferRestriction(
        uint8 restrictionCode
    ) external view returns (string memory);
    function getRestrictionsAddress() external view returns (address);
    function lock(
        address _address,
        uint256 amount,
        uint256 releaseTime
    ) external returns (bool);
    function getUserType(address _user) external view returns (string memory);
}
// claimreward , auction status , startAuction 
contract ProtonAuction is Ownable {
    IERC20 public USDT;
    IProton public PROTON;
    uint256 public tokenPrice = 1 * 10 ** 18; // 1 USDT per Proton token
    // uint256 public dailySupply = 2000000 * 10 ** 18;
    uint256 public maxOversubscription = 5000000 * 10 ** 18;
    uint256 public maxOversubscriptionlimit = 1000000 * 10 ** 18;
    // uint256 public currentRoundEnd;
    uint256 public totalSell;
    uint256 public lockingDay = 180 ;
    uint256 public currentRound;
    bool    public isPaused = true;
    address public fundsWallet;
    IERC20 [] public token;
    struct Auction {
        uint256 tokensDaily;
        uint256 tokensSold;
        uint256 oversubscribed;
        uint256 bonusMultiplier;
    }
    struct Round {
        uint256 roundStart;
        uint256 roundEnd;
        mapping(uint256 => Auction) dailyAuctions;
    }
    struct UserDetails {
        uint256 reward;
        uint256 buyTotal;
    }
    mapping(uint256 => Round) public rounds; 
    mapping(uint256 => Auction) public dailyAuctions;
    mapping(address => UserDetails) public userDetail;

    event TokensPurchased(
        address indexed buyer,
        uint256 usdtAmount,
        uint256 amount , 
        uint256 lockTime
    );
event claimreward (address user , uint256 leftToken , uint256 amount , uint256 timeClaim);
event StartAuction(uint256 round , uint256 startTime , uint256 endtime);
    constructor(
        address _protonAddress,
        address _fundsWalletAdd
     ) Ownable(msg.sender) {
        PROTON = IProton(_protonAddress);
        fundsWallet = _fundsWalletAdd;
        isPaused = true;
      
    }

    modifier auctionActive() {
        require(!isPaused, "Auction is paused");
        require(block.timestamp <= rounds[currentRound].roundEnd, "Current round has ended");
        _;
    }

    modifier auctionEnded() {
        require(isPaused, "Auction is still active");
        require(block.timestamp > rounds[currentRound].roundEnd, "Auction days are not complete");
        _;
    }

    function setToken(IERC20 addr) external onlyOwner {
        token.push(addr);
    }

    function startAuction() external onlyOwner {
         require(isPaused, "Auction already started");
        isPaused = false;

        // Move to the next round
        currentRound++;
        Round storage round = rounds[currentRound];

        round.roundStart = block.timestamp;
        round.roundEnd = block.timestamp + (7 days);

        for (uint256 i = 1; i <= 7; i++) {
            dailyAuctions[i].tokensDaily = 2_000_000 * 10 ** 18;
            dailyAuctions[i].bonusMultiplier = (i <= 5) ? 3 : (i == 6)? 2: 1;
        }
        emit StartAuction(currentRound , round.roundStart ,  round.roundEnd  );
    }

    function setPrice(uint256 _tokenPrice) external onlyOwner {
        tokenPrice = _tokenPrice;
    }

    function setFundsWallet(address _fundsWalletAddr) external onlyOwner {
        fundsWallet = _fundsWalletAddr;
    }

    function setDailyDetails(
        uint256 day,
        uint256 tokensDaily,
        uint256 bonusMultiplier) external onlyOwner {
        require(day < 7 && day > 0, "ERROR: DAY value");
        dailyAuctions[day].bonusMultiplier = bonusMultiplier;
        dailyAuctions[day].tokensDaily = tokensDaily;
    }

    function AuctionTime() external view returns (uint256 _currentRound,uint256 roundStart, uint256 roundEnd) {
        return (_currentRound = currentRound ,roundStart= rounds[currentRound].roundStart,roundEnd= rounds[currentRound].roundEnd);
    }

    function getCurrentDay() public view returns (uint256) {
        Round storage round = rounds[currentRound];

        if (isPaused || block.timestamp > round.roundEnd) {
            return 8; // Return 8 if the auction has ended
        }

        uint256 elapsed = block.timestamp - round.roundStart;
        uint256 day = (elapsed / 1 days) + 1;

        // Ensure the day is not greater than 7
        if (day > 7) {
            return 7;
        }

        return day;
    }

    function buyTokens(
        IERC20 contractAddress,
    
        uint256 _amount) external auctionActive {
        uint256 currentDay = getCurrentDay();
        require(currentDay <= 7, "Auction days are complete");
       Auction storage auction = dailyAuctions[currentDay];

        if (currentDay == 7) {
            require(block.timestamp <=  rounds[currentRound].roundEnd, "Auction round has ended");
        }

        if (currentDay == 6 || currentDay == 7) {
            auction.tokensDaily = PROTON.balanceOf(address(this));
        }

           require(!isPaused, "Auction Paused");
        //    //console.log(_amount);
        //    //console.log( PROTON.balanceOf(address(this)));
        
        require(
            auction.tokensSold < maxOversubscription,
            "Not more than limit"
        );
        require(
            auction.oversubscribed < maxOversubscriptionlimit,
            "Not more than limit"
        );
        require(
            isTokenValid(contractAddress),
             "Invalid token address"
        );
        uint256 usdtAmount = (_amount * tokenPrice) / (10 ** 18);
        // //console.log(usdtAmount);
        require(
            contractAddress.transferFrom(msg.sender, fundsWallet, usdtAmount),
            "USDT transfer failed"
        );

        uint256 amount;
        //  //console.log("auction daily",auction.tokensSold ,auction.tokensDaily );
        if (auction.tokensSold + _amount > auction.tokensDaily) {
            if (auction.tokensSold > auction.tokensDaily) {
                amount = (auction.tokensSold + _amount) - auction.tokensSold;
            } else {
                amount = (auction.tokensSold + _amount) - auction.tokensDaily;
            }

            auction.oversubscribed += amount;
            userDetail[msg.sender].buyTotal += amount;
            userDetail[msg.sender].reward += amount * auction.bonusMultiplier;
        }

        totalSell += _amount;
        auction.tokensSold += _amount;
        
        uint256 lockTime ; 
        // String comparison for user type
        string memory _userType = PROTON.getUserType(msg.sender);
        // //console.log(_userType);
        lockTime = block.timestamp + lockingDay;
        // //console.log("lockTime c",lockTime);
        // }
        PROTON.lock(msg.sender, _amount, lockTime);
        // Transfer Proton tokens to the buyer
        require(PROTON.transfer(msg.sender, _amount),"Proton token transfer failed");

        emit TokensPurchased(msg.sender, usdtAmount, _amount , lockTime);
    }

    // function resetAuction() external onlyOwner {
    //     isPaused = true;
      
    //      rounds[currentRound].roundEnd = 0;
    //      rounds[currentRound].roundEnd = 0;
    //     delete dailyAuctions[1].tokensSold;
    //     delete dailyAuctions[2].tokensSold;
    //     delete dailyAuctions[3].tokensSold;
    //     delete dailyAuctions[4].tokensSold;
    //     delete dailyAuctions[5].tokensSold;
    //     delete dailyAuctions[6].tokensSold;
    //     delete dailyAuctions[7].tokensSold;
    //     delete dailyAuctions[2].oversubscribed;
    //     delete dailyAuctions[1].oversubscribed;
    //     delete dailyAuctions[3].oversubscribed;
    //     delete dailyAuctions[4].oversubscribed;
    //     delete dailyAuctions[5].oversubscribed;
    //     delete dailyAuctions[7].oversubscribed;
    //     delete dailyAuctions[6].oversubscribed;

    // }

    function auctionStatus(bool status) external onlyOwner {
        isPaused = status;
        emit  AuctionStatus(msg.sender , status , block.timestamp);
    }

    event AuctionStatus(address caller , bool status , uint256 time);

    function calculateTokenAmount(
        uint256 _usdtAmount) external view returns (uint256) {
        return (_usdtAmount * (10 ** 18)) / tokenPrice;
    }

    function getDailyAuction(uint256 roundNumber, uint256 day) external view returns ( uint256) {
        Round storage round = rounds[roundNumber];
        Auction memory auction = round.dailyAuctions[day];
         return ( auction.tokensSold);
        // return (auction.tokensDaily, auction.tokensSold, auction.bonusMultiplier);
    }

    function claimReward(
        address user,
        uint256 _usdtAmount) external auctionEnded  {
        require(
            userDetail[user].reward > 0 &&
                _usdtAmount <= userDetail[user].reward,
            "Incorrect value"
        );
        userDetail[user].reward -= _usdtAmount;
        require(
            PROTON.transfer(user, _usdtAmount),
            "Proton token transfer failed"
        );
       emit claimreward (user ,  userDetail[user].reward , _usdtAmount , block.timestamp );
    }

    function remainingToken() internal view returns(uint){
            return PROTON.balanceOf(address(this));
    }

    function isTokenValid(IERC20 contractAddress) internal view returns (bool) {
        for (uint256 i = 0; i < token.length; i++) {
            if (token[i] == contractAddress) {
            return true;
            }
        }
        return false;
    }

}
