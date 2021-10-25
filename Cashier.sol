// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity 0.7.6;

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {
  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    require(token.approve(spender, value));
  }
}
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface IVoucherKernel {
    /**
     * @notice Pause the process of interaction with voucherID's (ERC-721), in case of emergency.
     * Only Cashier contract is in control of this function.
     */
    function pause() external;

    /**
     * @notice Unpause the process of interaction with voucherID's (ERC-721).
     * Only Cashier contract is in control of this function.
     */
    function unpause() external;

    /**
     * @notice Creating a new promise for goods or services.
     * Can be reused, e.g. for making different batches of these (but not in prototype).
     * @param _seller      seller of the promise
     * @param _validFrom   Start of valid period
     * @param _validTo     End of valid period
     * @param _price       Price (payment amount)
     * @param _depositSe   Seller's deposit
     * @param _depositBu   Buyer's deposit
     */
    function createTokenSupplyId(
        address _seller,
        uint256 _validFrom,
        uint256 _validTo,
        uint256 _price,
        uint256 _depositSe,
        uint256 _depositBu,
        uint256 _quantity
    ) external returns (uint256);

    /**
     * @notice Creates a Payment method struct recording the details on how the seller requires to receive Price and Deposits for a certain Voucher Set.
     * @param _tokenIdSupply     _tokenIdSupply of the voucher set this is related to
     * @param _paymentMethod  might be ETHETH, ETHTKN, TKNETH or TKNTKN
     * @param _tokenPrice   token address which will hold the funds for the price of the voucher
     * @param _tokenDeposits   token address which will hold the funds for the deposits of the voucher
     */
    function createPaymentMethod(
        uint256 _tokenIdSupply,
        uint8 _paymentMethod,
        address _tokenPrice,
        address _tokenDeposits
    ) external;

    /**
     * @notice Mark voucher token that the payment was released
     * @param _tokenIdVoucher   ID of the voucher token
     */
    function setPaymentReleased(uint256 _tokenIdVoucher) external;

    /**
     * @notice Mark voucher token that the deposits were released
     * @param _tokenIdVoucher   ID of the voucher token
     */
    function setDepositsReleased(uint256 _tokenIdVoucher) external;

    /**
     * @notice Extract a standard non-fungible tokens ERC-721 from a supply stored in ERC-1155
     * @dev Token ID is derived following the same principles for both ERC-1155 and ERC-721
     * @param _issuer          The address of the token issuer
     * @param _tokenIdSupply   ID of the token type
     * @param _qty   qty that should be burned
     */
    function burnSupplyOnPause(
        address _issuer,
        uint256 _tokenIdSupply,
        uint256 _qty
    ) external;

    /**
     * @notice Redemption of the vouchers promise
     * @param _tokenIdVoucher   ID of the voucher
     * @param _messageSender owner of the voucher
     */
    function redeem(uint256 _tokenIdVoucher, address _messageSender) external;

    /**
     * @notice Refunding a voucher
     * @param _tokenIdVoucher   ID of the voucher
     * @param _messageSender owner of the voucher
     */
    function refund(uint256 _tokenIdVoucher, address _messageSender) external;

    /**
     * @notice Issue a complain for a voucher
     * @param _tokenIdVoucher   ID of the voucher
     * @param _messageSender owner of the voucher
     */
    function complain(uint256 _tokenIdVoucher, address _messageSender) external;

    /**
     * @notice Cancel/Fault transaction by the Seller, admitting to a fault or backing out of the deal
     * @param _tokenIdVoucher   ID of the voucher
     * @param _messageSender owner of the voucher set (seller)
     */
    function cancelOrFault(uint256 _tokenIdVoucher, address _messageSender)
        external;

    /**
     * @notice Cancel/Fault transaction by the Seller, cancelling the remaining uncommitted voucher set so that seller prevents buyers from committing to vouchers for items no longer in exchange.
     * @param _tokenIdSupply   ID of the voucher
     * @param _issuer   owner of the voucher
     */
    function cancelOrFaultVoucherSet(uint256 _tokenIdSupply, address _issuer)
        external
        returns (uint256);

    /**
     * @notice Fill Voucher Order, iff funds paid, then extract & mint NFT to the voucher holder
     * @param _tokenIdSupply   ID of the supply token (ERC-1155)
     * @param _issuer          Address of the token's issuer
     * @param _holder          Address of the recipient of the voucher (ERC-721)
     * @param _paymentMethod   method being used for that particular order that needs to be fulfilled
     */
    function fillOrder(
        uint256 _tokenIdSupply,
        address _issuer,
        address _holder,
        uint8 _paymentMethod
    ) external;

    /**
     * @notice Mark voucher token as expired
     * @param _tokenIdVoucher   ID of the voucher token
     */
    function triggerExpiration(uint256 _tokenIdVoucher) external;

    /**
     * @notice Mark voucher token to the final status
     * @param _tokenIdVoucher   ID of the voucher token
     */
    function triggerFinalizeVoucher(uint256 _tokenIdVoucher) external;

    /**
     * @notice Set the address of the new holder of a _tokenIdSupply on transfer
     * @param _tokenIdSupply   _tokenIdSupply which will be transferred
     * @param _newSeller   new holder of the supply
     */
    function setSupplyHolderOnTransfer(
        uint256 _tokenIdSupply,
        address _newSeller
    ) external;

    /**
     * @notice Set the general cancelOrFault period, should be used sparingly as it has significant consequences. Here done simply for demo purposes.
     * @param _cancelFaultPeriod   the new value for cancelOrFault period (in number of seconds)
     */
    function setCancelFaultPeriod(uint256 _cancelFaultPeriod) external;

    /**
     * @notice Set the address of the Cashier contract
     * @param _cashierAddress   The address of the Cashier contract
     */
    function setCashierAddress(address _cashierAddress) external;

    /**
     * @notice Set the general complain period, should be used sparingly as it has significant consequences. Here done simply for demo purposes.
     * @param _complainPeriod   the new value for complain period (in number of seconds)
     */
    function setComplainPeriod(uint256 _complainPeriod) external;

    /**
     * @notice Get the promise ID at specific index
     * @param _idx  Index in the array of promise keys
     * @return      Promise ID
     */
    function getPromiseKey(uint256 _idx) external view returns (bytes32);

    /**
     * @notice Get the address of the token where the price for the supply is held
     * @param _tokenIdSupply   ID of the voucher token
     * @return                  Address of the token
     */
    function getVoucherPriceToken(uint256 _tokenIdSupply)
        external
        view
        returns (address);

    /**
     * @notice Get the address of the token where the deposits for the supply are held
     * @param _tokenIdSupply   ID of the voucher token
     * @return                  Address of the token
     */
    function getVoucherDepositToken(uint256 _tokenIdSupply)
        external
        view
        returns (address);

    /**
     * @notice Get Buyer costs required to make an order for a supply token
     * @param _tokenIdSupply   ID of the supply token
     * @return                  returns a tuple (Payment amount, Buyer's deposit)
     */
    function getBuyerOrderCosts(uint256 _tokenIdSupply)
        external
        view
        returns (uint256, uint256);

    /**
     * @notice Get Seller deposit
     * @param _tokenIdSupply   ID of the supply token
     * @return                  returns sellers deposit
     */
    function getSellerDeposit(uint256 _tokenIdSupply)
        external
        view
        returns (uint256);

    /**
     * @notice Get the promise ID from a voucher token
     * @param _tokenIdVoucher   ID of the voucher token
     * @return                  ID of the promise
     */
    function getIdSupplyFromVoucher(uint256 _tokenIdVoucher)
        external
        pure
        returns (uint256);

    /**
     * @notice Get the promise ID from a voucher token
     * @param _tokenIdVoucher   ID of the voucher token
     * @return                  ID of the promise
     */
    function getPromiseIdFromVoucherId(uint256 _tokenIdVoucher)
        external
        view
        returns (bytes32);

    /**
     * @notice Get all necessary funds for a supply token
     * @param _tokenIdSupply   ID of the supply token
     * @return                  returns a tuple (Payment amount, Seller's deposit, Buyer's deposit)
     */
    function getOrderCosts(uint256 _tokenIdSupply)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    /**
     * @notice Get the remaining quantity left in supply of tokens (e.g ERC-721 left in ERC-1155) of an account
     * @param _tokenSupplyId  Token supply ID
     * @param _owner    holder of the Token Supply
     * @return          remaining quantity
     */
    function getRemQtyForSupply(uint256 _tokenSupplyId, address _owner)
        external
        view
        returns (uint256);

    /**
     * @notice Get the payment method for a particular _tokenIdSupply
     * @param _tokenIdSupply   ID of the voucher supply token
     * @return                  payment method
     */
    function getVoucherPaymentMethod(uint256 _tokenIdSupply)
        external
        view
        returns (uint8);

    /**
     * @notice Get the current status of a voucher
     * @param _tokenIdVoucher   ID of the voucher token
     * @return                  Status of the voucher (via enum)
     */
    function getVoucherStatus(uint256 _tokenIdVoucher)
        external
        view
        returns (
            uint8,
            bool,
            bool,
            uint256,
            uint256
        );

    /**
     * @notice Get the holder of a supply
     * @param _tokenIdSupply    _tokenIdSupply ID of the order (aka VoucherSet) which is mapped to the corresponding Promise.
     * @return                  Address of the holder
     */
    function getSupplyHolder(uint256 _tokenIdSupply)
        external
        view
        returns (address);

    /**
     * @notice Get the holder of a voucher
     * @param _tokenIdVoucher   ID of the voucher token
     * @return                  Address of the holder
     */
    function getVoucherHolder(uint256 _tokenIdVoucher)
        external
        view
        returns (address);

    /**
     * @notice Checks whether a voucher is in valid period for redemption (between start date and end date)
     * @param _tokenIdVoucher ID of the voucher token
     */
    function isInValidityPeriod(uint256 _tokenIdVoucher)
        external
        view
        returns (bool);

    /**
     * @notice Checks whether a voucher is in valid state to be transferred. If either payments or deposits are released, voucher could not be transferred
     * @param _tokenIdVoucher ID of the voucher token
     */
    function isVoucherTransferable(uint256 _tokenIdVoucher)
        external
        view
        returns (bool);

    /**
     * @notice Get address of the Boson Router contract to which this contract points
     * @return Address of the Boson Router contract
     */
    function getBosonRouterAddress() external view returns (address);

    /**
     * @notice Get address of the Cashier contract to which this contract points
     * @return Address of the Cashier contract
     */
    function getCashierAddress() external view returns (address);

    /**
     * @notice Get the token nonce for a seller
     * @param _seller Address of the seller
     * @return The seller's
     */
    function getTokenNonce(address _seller) external view returns (uint256);

    /**
     * @notice Get the current type Id
     * @return type Id
     */
    function getTypeId() external view returns (uint256);

    /**
     * @notice Get the complain period
     * @return complain period
     */
    function getComplainPeriod() external view returns (uint256);

    /**
     * @notice Get the cancel or fault period
     * @return cancel or fault period
     */
    function getCancelFaultPeriod() external view returns (uint256);

    /**
     * @notice Get promise data not retrieved by other accessor functions
     * @param _promiseKey   ID of the promise
     * @return promise data not returned by other accessor methods
     */
    function getPromiseData(bytes32 _promiseKey)
        external
        view
        returns (
            bytes32,
            uint256,
            uint256,
            uint256,
            uint256
        );

    /**
     * @notice Get the promise ID from a voucher set
     * @param _tokenIdSupply   ID of the voucher token
     * @return                  ID of the promise
     */
    function getPromiseIdFromSupplyId(uint256 _tokenIdSupply)
        external
        view
        returns (bytes32);

    /**
     * @notice Get the address of ERC1155ERC721 contract
     * @return Address of ERC1155ERC721 contract
     */
    function getTokensContractAddress() external view returns (address);
}

interface ICashier {
    /**
     * @notice Pause the Cashier && the Voucher Kernel contracts in case of emergency.
     * All functions related to creating new batch, requestVoucher or withdraw will be paused, hence cannot be executed.
     * There is special function for withdrawing funds if contract is paused.
     */
    function pause() external;

    /**
     * @notice Unpause the Cashier && the Voucher Kernel contracts.
     * All functions related to creating new batch, requestVoucher or withdraw will be unpaused.
     */
    function unpause() external;

    function canUnpause() external view returns (bool);

    /**
     * @notice Trigger withdrawals of what funds are releasable
     * The caller of this function triggers transfers to all involved entities (pool, issuer, token holder), also paying for gas.
     * @dev This function would be optimized a lot, here verbose for readability.
     * @param _tokenIdVoucher  ID of a voucher token (ERC-721) to try withdraw funds from
     */
    function withdraw(uint256 _tokenIdVoucher) external;

    /**
     * @notice External function for withdrawing deposits. Caller must be the seller of the goods, otherwise reverts.
     * @notice Seller triggers withdrawals of remaining deposits for a given supply, in case the voucher set is no longer in exchange.
     * @param _tokenIdSupply an ID of a supply token (ERC-1155) which will be burned and deposits will be returned for
     * @param _burnedQty burned quantity that the deposits should be withdrawn for
     * @param _messageSender owner of the voucher set
     */
    function withdrawDepositsSe(
        uint256 _tokenIdSupply,
        uint256 _burnedQty,
        address payable _messageSender
    ) external;

    /**
     * @notice Get the amount in escrow of an address
     * @param _account  The address of an account to query
     * @return          The balance in escrow
     */
    function getEscrowAmount(address _account) external view returns (uint256);

    /**
     * @notice Update the amount in escrow of an address with the new value, based on VoucherSet/Voucher interaction
     * @param _account  The address of an account to query
     */
    function addEscrowAmount(address _account) external payable;

    /**
     * @notice Update the amount in escrowTokens of an address with the new value, based on VoucherSet/Voucher interaction
     * @param _token  The address of a token to query
     * @param _account  The address of an account to query
     * @param _newAmount  New amount to be set
     */
    function addEscrowTokensAmount(
        address _token,
        address _account,
        uint256 _newAmount
    ) external;

    /**
     * @notice Hook which will be triggered when a _tokenIdVoucher will be transferred. Escrow funds should be allocated to the new owner.
     * @param _from prev owner of the _tokenIdVoucher
     * @param _to next owner of the _tokenIdVoucher
     * @param _tokenIdVoucher _tokenIdVoucher that has been transferred
     */
    function onERC721Transfer(
        address _from,
        address _to,
        uint256 _tokenIdVoucher
    ) external;

    /**
     * @notice After the transfer happens the _tokenSupplyId should be updated in the promise. Escrow funds for the deposits (If in ETH) should be allocated to the new owner as well.
     * @param _from prev owner of the _tokenSupplyId
     * @param _to next owner of the _tokenSupplyId
     * @param _tokenSupplyId _tokenSupplyId for transfer
     * @param _value qty which has been transferred
     */
    function onERC1155Transfer(
        address _from,
        address _to,
        uint256 _tokenSupplyId,
        uint256 _value
    ) external;

    /**
     * @notice Get the address of Voucher Kernel contract
     * @return Address of Voucher Kernel contract
     */
    function getVoucherKernelAddress() external view returns (address);

    /**
     * @notice Get the address of Boson Router contract
     * @return Address of Boson Router contract
     */
    function getBosonRouterAddress() external view returns (address);

    /**
     * @notice Get the address of ERC1155ERC721 contract
     * @return Address of ERC1155ERC721 contract
     */
    function getTokensContractAddress() external view returns (address);

    /**
     * @notice Ensure whether or not contract has been set to disaster state
     * @return disasterState
     */
    function isDisasterStateSet() external view returns (bool);

    /**
     * @notice Get the amount in escrow of an address
     * @param _token  The address of a token to query
     * @param _account  The address of an account to query
     * @return          The balance in escrow
     */
    function getEscrowTokensAmount(address _token, address _account)
        external
        view
        returns (uint256);

    /**
     * @notice Set the address of the BR contract
     * @param _bosonRouterAddress   The address of the Cashier contract
     */
    function setBosonRouterAddress(address _bosonRouterAddress) external;

    /**
     * @notice Set the address of the ERC1155ERC721 contract
     * @param _tokensContractAddress   The address of the ERC1155ERC721 contract
     */
    function setTokenContractAddress(address _tokensContractAddress) external;
}

contract UsingHelpers {
    uint8 internal constant ONE = 1;
    uint8 internal constant IDX_COMMIT = 7;
    uint8 internal constant IDX_REDEEM = 6;
    uint8 internal constant IDX_REFUND = 5;
    uint8 internal constant IDX_EXPIRE = 4;
    uint8 internal constant IDX_COMPLAIN = 3;
    uint8 internal constant IDX_CANCEL_FAULT = 2;
    uint8 internal constant IDX_FINAL = 1;

    /*  Status of the voucher in 8 bits:
        [7:COMMITTED] [6:REDEEMED] [5:REFUNDED] [4:EXPIRED] [3:COMPLAINED] [2:CANCELORFAULT] [1:FINAL] [1:/]
    */

    // Those are the payment methods we are using throughout the system.
    // Depending on how to user choose to interact with it's funds we store the method, so we could distribute its tokens afterwise
    uint8 internal constant ETHETH = 1;
    uint8 internal constant ETHTKN = 2;
    uint8 internal constant TKNETH = 3;
    uint8 internal constant TKNTKN = 4;

    struct VoucherDetails {
        uint256 tokenIdSupply;
        uint256 tokenIdVoucher;
        address issuer;
        address holder;
        uint256 price;
        uint256 depositSe;
        uint256 depositBu;
        uint256 price2pool;
        uint256 deposit2pool;
        uint256 price2issuer;
        uint256 deposit2issuer;
        uint256 price2holder;
        uint256 deposit2holder;
        uint8 paymentMethod;
        VoucherStatus currStatus;
    }

    struct VoucherStatus {
        uint8 status;
        bool isPaymentReleased;
        bool isDepositsReleased;
        uint256 complainPeriodStart;
        uint256 cancelFaultPeriodStart;
    }

    /**
     * @notice Based on its lifecycle, voucher can have many different statuses. Checks whether a voucher is in Committed state.
     * @param _status current status of a voucher.
     */
    function isStateCommitted(uint8 _status) internal pure returns (bool) {
        return _status == determineStatus(0, IDX_COMMIT);
    }

    /**
     * @notice Based on its lifecycle, voucher can have many different statuses. Checks whether a voucher is in RedemptionSigned state.
     * @param _status current status of a voucher.
     */
    function isStateRedemptionSigned(uint8 _status)
        internal
        pure
        returns (bool)
    {
        return _status == determineStatus(determineStatus(0, IDX_COMMIT), IDX_REDEEM);
    }

    /**
     * @notice Based on its lifecycle, voucher can have many different statuses. Checks whether a voucher is in Refunded state.
     * @param _status current status of a voucher.
     */
    function isStateRefunded(uint8 _status) internal pure returns (bool) {
        return _status == determineStatus(determineStatus(0, IDX_COMMIT), IDX_REFUND);
    }

    /**
     * @notice Based on its lifecycle, voucher can have many different statuses. Checks whether a voucher is in Expired state.
     * @param _status current status of a voucher.
     */
    function isStateExpired(uint8 _status) internal pure returns (bool) {
        return _status == determineStatus(determineStatus(0, IDX_COMMIT), IDX_EXPIRE);
    }

    /**
     * @notice Based on its lifecycle, voucher can have many different statuses. Checks the current status a voucher is at.
     * @param _status current status of a voucher.
     * @param _idx status to compare.
     */
    function isStatus(uint8 _status, uint8 _idx) internal pure returns (bool) {
        return (_status >> _idx) & ONE == 1;
    }

    /**
     * @notice Set voucher status.
     * @param _status previous status.
     * @param _changeIdx next status.
     */
    function determineStatus(uint8 _status, uint8 _changeIdx)
        internal
        pure
        returns (uint8)
    {
        return _status | (ONE << _changeIdx);
    }
}

/**
 * @title Contract for managing funds
 * Roughly following OpenZeppelin's Escrow at https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/payment/
 */
contract Cashier is ICashier, UsingHelpers, ReentrancyGuard, Ownable, Pausable {
    using SafeERC20 for IERC20;
    using Address for address payable;
    using SafeMath for uint256;

    address private voucherKernel;
    address private bosonRouterAddress;
    address private tokensContractAddress;
    bool private disasterState;

    enum PaymentType {PAYMENT, DEPOSIT_SELLER, DEPOSIT_BUYER}

    mapping(address => uint256) private escrow; // both types of deposits AND payments >> can be released token-by-token if checks pass
    // slashedDepositPool can be obtained through getEscrowAmount(poolAddress)
    mapping(address => mapping(address => uint256)) private escrowTokens; //token address => mgsSender => amount

    uint256 internal constant CANCELFAULT_SPLIT = 2; //for POC purposes, this is hardcoded; e.g. each party gets depositSe / 2

    event LogBosonRouterSet(address _newBosonRouter, address _triggeredBy);

    event LogTokenContractSet(address _newTokenContract, address _triggeredBy);

    event LogWithdrawal(address _caller, address _payee, uint256 _payment);

    event LogAmountDistribution(
        uint256 indexed _tokenIdVoucher,
        address _to,
        uint256 _payment,
        PaymentType _type
    );

    event LogDisasterStateSet(bool _disasterState, address _triggeredBy);
    event LogWithdrawEthOnDisaster(uint256 _amount, address _triggeredBy);
    event LogWithdrawTokensOnDisaster(
        uint256 _amount,
        address _tokenAddress,
        address _triggeredBy
    );

    modifier onlyFromRouter() {
        require(bosonRouterAddress != address(0), "UNSPECIFIED_BR");
        require(msg.sender == bosonRouterAddress, "UNAUTHORIZED_BR");
        _;
    }

    modifier notZeroAddress(address _addressToCheck) {
        require(_addressToCheck != address(0), "0A");
        _;
    }

    /**
     * @notice The only caller must be tokensContractAddress, otherwise reverts.
     */
    modifier onlyTokensContract() {
        require(msg.sender == tokensContractAddress, "UT"); // Unauthorized token address
        _;
    }

    /**
     * @notice Construct and initialze the contract. Iniialises associated contract addresses. Iniialises disaster state to false.    
     * @param _voucherKernel address of the associated VocherKernal contract instance
     */
    constructor(address _voucherKernel) 
     notZeroAddress(_voucherKernel)
    {
        voucherKernel = _voucherKernel;
        disasterState = false;
    }

    /**
     * @notice Pause the process of interaction with voucherID's (ERC-721), in case of emergency.
     * Only BR contract is in control of this function.
     */
    function pause() external override onlyFromRouter {
        _pause();
    }

    /**
     * @notice Unpause the process of interaction with voucherID's (ERC-721).
     * Only BR contract is in control of this function.
     */
    function unpause() external override onlyFromRouter {
        _unpause();
    }

    /**
     * @notice If once disaster state has been set to true, the contract could never be unpaused.
     */
    function canUnpause() external view override returns (bool) {
        return !disasterState;
    }

    /**
     * @notice Once this functions is triggered, contracts cannot be unpaused anymore
     * Only BR contract is in control of this function.
     */
    function setDisasterState() external onlyOwner whenPaused {
        disasterState = true;
        emit LogDisasterStateSet(disasterState, msg.sender);
    }

    /**
     * @notice In case of a disaster this function allow the caller to withdraw all pooled funds kept in the escrow for the address provided. Funds are sent in ETH
     */
    function withdrawEthOnDisaster() external whenPaused nonReentrant {
        require(disasterState, "Owner did not allow manual withdraw");

        uint256 amount = escrow[msg.sender];

        require(amount > 0, "ESCROW_EMPTY");
        escrow[msg.sender] = 0;
        msg.sender.sendValue(amount);

        emit LogWithdrawEthOnDisaster(amount, msg.sender);
    }

    /**
     * @notice In case of a disaster this function allow the caller to withdraw all pooled funds kept in the escrowTokens for the address provided.
     * @param _token address of a token, that the caller sent the funds, while interacting with voucher or voucher-set
     */
    function withdrawTokensOnDisaster(address _token)
        external
        whenPaused
        nonReentrant
        notZeroAddress(_token)
    {
        require(disasterState, "Owner did not allow manual withdraw");

        uint256 amount = escrowTokens[_token][msg.sender];
        require(amount > 0, "ESCROW_EMPTY");
        escrowTokens[_token][msg.sender] = 0;

        SafeERC20.safeTransfer(IERC20(_token), msg.sender, amount);
        emit LogWithdrawTokensOnDisaster(amount, _token, msg.sender);
    }

    /**
     * @notice Trigger withdrawals of what funds are releasable
     * The caller of this function triggers transfers to all involved entities (pool, issuer, token holder), also paying for gas.
     * @dev This function would be optimized a lot, here verbose for readability.
     * @param _tokenIdVoucher  ID of a voucher token (ERC-721) to try withdraw funds from
     */
    function withdraw(uint256 _tokenIdVoucher)
        external
        override
        nonReentrant
        whenNotPaused
    {
        VoucherDetails memory voucherDetails;

        require(_tokenIdVoucher != 0, "UNSPECIFIED_ID");

        voucherDetails.tokenIdVoucher = _tokenIdVoucher;
        voucherDetails.tokenIdSupply = IVoucherKernel(voucherKernel)
            .getIdSupplyFromVoucher(voucherDetails.tokenIdVoucher);
        voucherDetails.paymentMethod = IVoucherKernel(voucherKernel)
            .getVoucherPaymentMethod(voucherDetails.tokenIdSupply);

        require(
            voucherDetails.paymentMethod > 0 &&
                voucherDetails.paymentMethod <= 4,
            "INVALID PAYMENT METHOD"
        );

        (
            voucherDetails.currStatus.status,
            voucherDetails.currStatus.isPaymentReleased,
            voucherDetails.currStatus.isDepositsReleased,
            ,
        ) = IVoucherKernel(voucherKernel).getVoucherStatus(
            voucherDetails.tokenIdVoucher
        );

        (
            voucherDetails.price,
            voucherDetails.depositSe,
            voucherDetails.depositBu
        ) = IVoucherKernel(voucherKernel).getOrderCosts(
            voucherDetails.tokenIdSupply
        );

        voucherDetails.issuer = payable(
            IVoucherKernel(voucherKernel).getSupplyHolder(
                voucherDetails.tokenIdSupply
            )
        );
        voucherDetails.holder = payable(
            IVoucherKernel(voucherKernel).getVoucherHolder(
                voucherDetails.tokenIdVoucher
            )
        );

        //process the RELEASE OF PAYMENTS - only depends on the redeemed/not-redeemed, a voucher need not be in the final status
        if (!voucherDetails.currStatus.isPaymentReleased) {
            releasePayments(voucherDetails);
        }

        //process the RELEASE OF DEPOSITS - only when vouchers are in the FINAL status
        if (
            !voucherDetails.currStatus.isDepositsReleased &&
            isStatus(voucherDetails.currStatus.status, IDX_FINAL)
        ) {
            releaseDeposits(voucherDetails);
        }

        if (voucherDetails.deposit2pool > 0) {
            _withdrawDeposits(
                owner(),
                voucherDetails.deposit2pool,
                voucherDetails.paymentMethod,
                voucherDetails.tokenIdSupply
            );
        }

        if (voucherDetails.price2issuer > 0) {
            _withdrawPayments(
                voucherDetails.issuer,
                voucherDetails.price2issuer,
                voucherDetails.paymentMethod,
                voucherDetails.tokenIdSupply
            );
        }

        if (voucherDetails.deposit2issuer > 0) {
            _withdrawDeposits(
                voucherDetails.issuer,
                voucherDetails.deposit2issuer,
                voucherDetails.paymentMethod,
                voucherDetails.tokenIdSupply
            );
        }

        if (voucherDetails.price2holder > 0) {
            _withdrawPayments(
                voucherDetails.holder,
                voucherDetails.price2holder,
                voucherDetails.paymentMethod,
                voucherDetails.tokenIdSupply
            );
        }

        if (voucherDetails.deposit2holder > 0) {
            _withdrawDeposits(
                voucherDetails.holder,
                voucherDetails.deposit2holder,
                voucherDetails.paymentMethod,
                voucherDetails.tokenIdSupply
            );
        }
    }

    /**
     * @notice Release of payments, for a voucher which payments had not been released already.
     * Based on the voucher status(e.g. redeemed, refunded, etc), the voucher price will be sent to either buyer or seller.
     * @param _voucherDetails keeps all required information of the voucher which the payment should be released for.
     */
    function releasePayments(VoucherDetails memory _voucherDetails) internal {
        if (isStatus(_voucherDetails.currStatus.status, IDX_REDEEM)) {
            releasePaymentToSeller(_voucherDetails);
        } else if (
            isStatus(_voucherDetails.currStatus.status, IDX_REFUND) ||
            isStatus(_voucherDetails.currStatus.status, IDX_EXPIRE) ||
            (isStatus(_voucherDetails.currStatus.status, IDX_CANCEL_FAULT) &&
                !isStatus(_voucherDetails.currStatus.status, IDX_REDEEM))
        ) {
            releasePaymentToBuyer(_voucherDetails);
        }
    }

    /**
     * @notice Following function `releasePayments`, if certain conditions for the voucher status are met, the voucher price will be sent to the seller
     * @param _voucherDetails keeps all required information of the voucher which the payment should be released for.
     */
    function releasePaymentToSeller(VoucherDetails memory _voucherDetails)
        internal
    {
        if (
            _voucherDetails.paymentMethod == ETHETH ||
            _voucherDetails.paymentMethod == ETHTKN
        ) {
            escrow[_voucherDetails.holder] = escrow[_voucherDetails.holder].sub(
                _voucherDetails.price
            );
        }
        if (
            _voucherDetails.paymentMethod == TKNETH ||
            _voucherDetails.paymentMethod == TKNTKN
        ) {
            address addressTokenPrice =
                IVoucherKernel(voucherKernel).getVoucherPriceToken(
                    _voucherDetails.tokenIdSupply
                );

            escrowTokens[addressTokenPrice][
                _voucherDetails.holder
            ] = escrowTokens[addressTokenPrice][_voucherDetails.holder].sub(
                _voucherDetails.price
            );
        }

        _voucherDetails.price2issuer = _voucherDetails.price2issuer.add(
            _voucherDetails.price
        );

        IVoucherKernel(voucherKernel).setPaymentReleased(
            _voucherDetails.tokenIdVoucher
        );

        emit LogAmountDistribution(
            _voucherDetails.tokenIdVoucher,
            _voucherDetails.issuer,
            _voucherDetails.price,
            PaymentType.PAYMENT
        );
    }

    /**
     * @notice Following function `releasePayments`, if certain conditions for the voucher status are met, the voucher price will be sent to the buyer
     * @param _voucherDetails keeps all required information of the voucher, which the payment should be released for.
     */
    function releasePaymentToBuyer(VoucherDetails memory _voucherDetails)
        internal
    {
        if (
            _voucherDetails.paymentMethod == ETHETH ||
            _voucherDetails.paymentMethod == ETHTKN
        ) {
            escrow[_voucherDetails.holder] = escrow[_voucherDetails.holder].sub(
                _voucherDetails.price
            );
        }

        if (
            _voucherDetails.paymentMethod == TKNETH ||
            _voucherDetails.paymentMethod == TKNTKN
        ) {
            address addressTokenPrice =
                IVoucherKernel(voucherKernel).getVoucherPriceToken(
                    _voucherDetails.tokenIdSupply
                );

            escrowTokens[addressTokenPrice][
                _voucherDetails.holder
            ] = escrowTokens[addressTokenPrice][_voucherDetails.holder].sub(
                _voucherDetails.price
            );
        }

        _voucherDetails.price2holder = _voucherDetails.price2holder.add(
            _voucherDetails.price
        );

        IVoucherKernel(voucherKernel).setPaymentReleased(
            _voucherDetails.tokenIdVoucher
        );

        emit LogAmountDistribution(
            _voucherDetails.tokenIdVoucher,
            _voucherDetails.holder,
            _voucherDetails.price,
            PaymentType.PAYMENT
        );
    }

    /**
     * @notice Release of deposits, for a voucher which deposits had not been released already, and had been marked as `finalized`
     * Based on the voucher status(e.g. complained, redeemed, refunded, etc), the voucher deposits will be sent to either buyer, seller, or pool owner.
     * Depending on the payment type (e.g ETH, or Token) escrow funds will be held in the `escrow` || escrowTokens mappings
     * @param _voucherDetails keeps all required information of the voucher which the deposits should be released for.
     */
    function releaseDeposits(VoucherDetails memory _voucherDetails) internal {
        //first, depositSe
        if (isStatus(_voucherDetails.currStatus.status, IDX_COMPLAIN)) {
            //slash depositSe
            distributeIssuerDepositOnHolderComplain(_voucherDetails);
        } else {
            if (isStatus(_voucherDetails.currStatus.status, IDX_CANCEL_FAULT)) {
                //slash depositSe
                distributeIssuerDepositOnIssuerCancel(_voucherDetails);
            } else {
                //release depositSe
                distributeFullIssuerDeposit(_voucherDetails);
            }
        }

        //second, depositBu
        if (
            isStatus(_voucherDetails.currStatus.status, IDX_REDEEM) ||
            isStatus(_voucherDetails.currStatus.status, IDX_CANCEL_FAULT)
        ) {
            //release depositBu
            distributeFullHolderDeposit(_voucherDetails);
        } else {
            //slash depositBu
            distributeHolderDepositOnNotRedeemedNotCancelled(_voucherDetails);
        }

        IVoucherKernel(voucherKernel).setDepositsReleased(
            _voucherDetails.tokenIdVoucher
        );
    }

    /**
     * @notice Following function `releaseDeposits` this function will be triggered if a voucher had been complained by the buyer.
     * Also checks if the voucher had been cancelled
     * @param _voucherDetails keeps all required information of the voucher which the payment should be released for.
     */
    function distributeIssuerDepositOnHolderComplain(
        VoucherDetails memory _voucherDetails
    ) internal {
        if (isStatus(_voucherDetails.currStatus.status, IDX_CANCEL_FAULT)) {
            //appease the conflict three-ways
            if (
                _voucherDetails.paymentMethod == ETHETH ||
                _voucherDetails.paymentMethod == TKNETH
            ) {
                escrow[_voucherDetails.issuer] = escrow[_voucherDetails.issuer]
                    .sub(_voucherDetails.depositSe);
            }

            if (
                _voucherDetails.paymentMethod == ETHTKN ||
                _voucherDetails.paymentMethod == TKNTKN
            ) {
                address addressTokenDeposits =
                    IVoucherKernel(voucherKernel).getVoucherDepositToken(
                        _voucherDetails.tokenIdSupply
                    );

                escrowTokens[addressTokenDeposits][
                    _voucherDetails.issuer
                ] = escrowTokens[addressTokenDeposits][_voucherDetails.issuer]
                    .sub(_voucherDetails.depositSe);
            }

            uint256 tFraction = _voucherDetails.depositSe.div(CANCELFAULT_SPLIT);
            _voucherDetails.deposit2holder = _voucherDetails.deposit2holder.add(
                tFraction
            ); //Bu gets, say, a half
            _voucherDetails.deposit2issuer = _voucherDetails.deposit2issuer.add(
                tFraction.div(CANCELFAULT_SPLIT)
            ); //Se gets, say, a quarter
            _voucherDetails.deposit2pool = _voucherDetails.deposit2pool.add(
                (_voucherDetails.depositSe.sub(tFraction)).sub(
                    tFraction.div(CANCELFAULT_SPLIT)
                )
            ); //slashing the rest

            emit LogAmountDistribution(
                _voucherDetails.tokenIdVoucher,
                _voucherDetails.holder,
                tFraction,
                PaymentType.DEPOSIT_SELLER
            );
            emit LogAmountDistribution(
                _voucherDetails.tokenIdVoucher,
                _voucherDetails.issuer,
                tFraction.div(CANCELFAULT_SPLIT),
                PaymentType.DEPOSIT_SELLER
            );
            emit LogAmountDistribution(
                _voucherDetails.tokenIdVoucher,
                owner(),
                (_voucherDetails.depositSe.sub(tFraction)).sub(
                    tFraction.div(CANCELFAULT_SPLIT)
                ),
                PaymentType.DEPOSIT_SELLER
            );

        } else {
            //slash depositSe
            if (
                _voucherDetails.paymentMethod == ETHETH ||
                _voucherDetails.paymentMethod == TKNETH
            ) {
                escrow[_voucherDetails.issuer] = escrow[_voucherDetails.issuer]
                    .sub(_voucherDetails.depositSe);
            } else {
                address addressTokenDeposits =
                    IVoucherKernel(voucherKernel).getVoucherDepositToken(
                        _voucherDetails.tokenIdSupply
                    );

                escrowTokens[addressTokenDeposits][
                    _voucherDetails.issuer
                ] = escrowTokens[addressTokenDeposits][_voucherDetails.issuer]
                    .sub(_voucherDetails.depositSe);
            }

            _voucherDetails.deposit2pool = _voucherDetails.deposit2pool.add(
                _voucherDetails.depositSe
            );

            emit LogAmountDistribution(
                _voucherDetails.tokenIdVoucher,
                owner(),
                _voucherDetails.depositSe,
                PaymentType.DEPOSIT_SELLER
            );
        }
    }

    /**
     * @notice Following function `releaseDeposits` this function will be triggered if a voucher had been cancelled by the seller.
     * Will be triggered if the voucher had not been complained.
     * @param _voucherDetails keeps all required information of the voucher which the deposits should be released for.
     */
    function distributeIssuerDepositOnIssuerCancel(
        VoucherDetails memory _voucherDetails
    ) internal {
        if (
            _voucherDetails.paymentMethod == ETHETH ||
            _voucherDetails.paymentMethod == TKNETH
        ) {
            escrow[_voucherDetails.issuer] = escrow[_voucherDetails.issuer].sub(
                _voucherDetails.depositSe
            );
        }

        if (
            _voucherDetails.paymentMethod == ETHTKN ||
            _voucherDetails.paymentMethod == TKNTKN
        ) {
            address addressTokenDeposits =
                IVoucherKernel(voucherKernel).getVoucherDepositToken(
                    _voucherDetails.tokenIdSupply
                );

            escrowTokens[addressTokenDeposits][
                _voucherDetails.issuer
            ] = escrowTokens[addressTokenDeposits][_voucherDetails.issuer].sub(
                _voucherDetails.depositSe
            );
        }

        _voucherDetails.deposit2issuer = _voucherDetails.deposit2issuer.add(
            _voucherDetails.depositSe.div(CANCELFAULT_SPLIT)
        );

        _voucherDetails.deposit2holder = _voucherDetails.deposit2holder.add(
            _voucherDetails.depositSe.sub(
                _voucherDetails.depositSe.div(CANCELFAULT_SPLIT)
            )
        );

        emit LogAmountDistribution(
            _voucherDetails.tokenIdVoucher,
            _voucherDetails.issuer,
            _voucherDetails.depositSe.div(CANCELFAULT_SPLIT),
            PaymentType.DEPOSIT_SELLER
        );

        emit LogAmountDistribution(
            _voucherDetails.tokenIdVoucher,
            _voucherDetails.holder,
            _voucherDetails.depositSe.sub(
                _voucherDetails.depositSe.div(CANCELFAULT_SPLIT)
            ),
            PaymentType.DEPOSIT_SELLER
        );
    }

    /**
     * @notice Following function `releaseDeposits` this function will be triggered if no complain, nor cancel had been made.
     * All seller deposit is returned to seller.
     * @param _voucherDetails keeps all required information of the voucher which the deposits should be released for.
     */
    function distributeFullIssuerDeposit(VoucherDetails memory _voucherDetails)
        internal
    {
        if (
            _voucherDetails.paymentMethod == ETHETH ||
            _voucherDetails.paymentMethod == TKNETH
        ) {
            escrow[_voucherDetails.issuer] = escrow[_voucherDetails.issuer].sub(
                _voucherDetails.depositSe
            );
        }

        if (
            _voucherDetails.paymentMethod == ETHTKN ||
            _voucherDetails.paymentMethod == TKNTKN
        ) {
            address addressTokenDeposits =
                IVoucherKernel(voucherKernel).getVoucherDepositToken(
                    _voucherDetails.tokenIdSupply
                );

            escrowTokens[addressTokenDeposits][
                _voucherDetails.issuer
            ] = escrowTokens[addressTokenDeposits][_voucherDetails.issuer].sub(
                _voucherDetails.depositSe
            );
        }

        _voucherDetails.deposit2issuer = _voucherDetails.deposit2issuer.add(
            _voucherDetails.depositSe
        );

        emit LogAmountDistribution(
            _voucherDetails.tokenIdVoucher,
            _voucherDetails.issuer,
            _voucherDetails.depositSe,
            PaymentType.DEPOSIT_SELLER
        );
    }

    /**
     * @notice Following function `releaseDeposits` this function will be triggered if voucher had been redeemed, or the seller had cancelled.
     * All buyer deposit is returned to buyer.
     * @param _voucherDetails keeps all required information of the voucher which the deposits should be released for.
     */
    function distributeFullHolderDeposit(VoucherDetails memory _voucherDetails)
        internal
    {
        if (
            _voucherDetails.paymentMethod == ETHETH ||
            _voucherDetails.paymentMethod == TKNETH
        ) {
            escrow[_voucherDetails.holder] = escrow[_voucherDetails.holder].sub(
                _voucherDetails.depositBu
            );
        }

        if (
            _voucherDetails.paymentMethod == ETHTKN ||
            _voucherDetails.paymentMethod == TKNTKN
        ) {
            address addressTokenDeposits =
                IVoucherKernel(voucherKernel).getVoucherDepositToken(
                    _voucherDetails.tokenIdSupply
                );

            escrowTokens[addressTokenDeposits][
                _voucherDetails.holder
            ] = escrowTokens[addressTokenDeposits][_voucherDetails.holder].sub(
                _voucherDetails.depositBu
            );
        }

        _voucherDetails.deposit2holder = _voucherDetails.deposit2holder.add(
            _voucherDetails.depositBu
        );

        emit LogAmountDistribution(
            _voucherDetails.tokenIdVoucher,
            _voucherDetails.holder,
            _voucherDetails.depositBu,
            PaymentType.DEPOSIT_BUYER
        );
    }

    /**
     * @notice Following function `releaseDeposits` this function will be triggered if voucher had not been redeemed or cancelled after finalization.
     * @param _voucherDetails keeps all required information of the voucher which the deposits should be released for.
     * All buyer deposit goes to Boson.
     */
    function distributeHolderDepositOnNotRedeemedNotCancelled(
        VoucherDetails memory _voucherDetails
    ) internal {
        if (
            _voucherDetails.paymentMethod == ETHETH ||
            _voucherDetails.paymentMethod == TKNETH
        ) {
            escrow[_voucherDetails.holder] = escrow[_voucherDetails.holder].sub(
                _voucherDetails.depositBu
            );
        }

        if (
            _voucherDetails.paymentMethod == ETHTKN ||
            _voucherDetails.paymentMethod == TKNTKN
        ) {
            address addressTokenDeposits =
                IVoucherKernel(voucherKernel).getVoucherDepositToken(
                    _voucherDetails.tokenIdSupply
                );

            escrowTokens[addressTokenDeposits][
                _voucherDetails.holder
            ] = escrowTokens[addressTokenDeposits][_voucherDetails.holder].sub(
                _voucherDetails.depositBu
            );
        }

        _voucherDetails.deposit2pool = _voucherDetails.deposit2pool.add(
            _voucherDetails.depositBu
        );

        emit LogAmountDistribution(
            _voucherDetails.tokenIdVoucher,
            owner(),
            _voucherDetails.depositBu,
            PaymentType.DEPOSIT_BUYER
        );
    }

    /**
     * @notice External function for withdrawing deposits. Caller must be the seller of the goods, otherwise reverts.
     * @notice Seller triggers withdrawals of remaining deposits for a given supply, in case the voucher set is no longer in exchange.
     * @param _tokenIdSupply an ID of a supply token (ERC-1155) which will be burned and deposits will be returned for
     * @param _burnedQty burned quantity that the deposits should be withdrawn for
     * @param _messageSender owner of the voucher set
     */
    function withdrawDepositsSe(
        uint256 _tokenIdSupply,
        uint256 _burnedQty,
        address payable _messageSender
    ) external override nonReentrant onlyFromRouter {
        require(IVoucherKernel(voucherKernel).getSupplyHolder(_tokenIdSupply) == _messageSender, "UNAUTHORIZED_V");

        uint256 deposit =
            IVoucherKernel(voucherKernel).getSellerDeposit(_tokenIdSupply);

        uint256 depositAmount = deposit.mul(_burnedQty);

        uint8 paymentMethod =
            IVoucherKernel(voucherKernel).getVoucherPaymentMethod(
                _tokenIdSupply
            );

        require(
            paymentMethod > 0 && paymentMethod <= 4,
            "INVALID PAYMENT METHOD"
        );

        if (paymentMethod == ETHETH || paymentMethod == TKNETH) {
            escrow[_messageSender] = escrow[_messageSender].sub(depositAmount);
        }

        if (paymentMethod == ETHTKN || paymentMethod == TKNTKN) {
            address addressTokenDeposits =
                IVoucherKernel(voucherKernel).getVoucherDepositToken(
                    _tokenIdSupply
                );

            escrowTokens[addressTokenDeposits][_messageSender] = escrowTokens[
                addressTokenDeposits
            ][_messageSender]
                .sub(depositAmount);
        }

        _withdrawDeposits(
            _messageSender,
            depositAmount,
            paymentMethod,
            _tokenIdSupply
        );
    }

    /**
     * @notice Internal function for withdrawing payments.
     * As unbelievable as it is, neither .send() nor .transfer() are now secure to use due to EIP-1884
     *  So now transferring funds via the last remaining option: .call()
     *  See https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/
     * @param _recipient    address of the account receiving funds from the escrow
     * @param _amount       amount to be released from escrow
     * @param _paymentMethod payment method that should be used to determine, how to do the payouts
     * @param _tokenIdSupply       _tokenIdSupply of the voucher set this is related to
     */
    function _withdrawPayments(
        address _recipient,
        uint256 _amount,
        uint8 _paymentMethod,
        uint256 _tokenIdSupply
    ) internal
      notZeroAddress(_recipient)
    {
        require(_amount > 0, "NO_FUNDS_TO_WITHDRAW");

        if (_paymentMethod == ETHETH || _paymentMethod == ETHTKN) {
            payable(_recipient).sendValue(_amount);
            emit LogWithdrawal(msg.sender, _recipient, _amount);
        }

        if (_paymentMethod == TKNETH || _paymentMethod == TKNTKN) {
            address addressTokenPrice =
                IVoucherKernel(voucherKernel).getVoucherPriceToken(
                    _tokenIdSupply
                );

            SafeERC20.safeTransfer(
                IERC20(addressTokenPrice),
                _recipient,
                _amount
            );
        }
    }

    /**
     * @notice Internal function for withdrawing deposits.
     * @param _recipient    address of the account receiving funds from the escrow
     * @param _amount       amount to be released from escrow
     * @param _paymentMethod       payment method that should be used to determine, how to do the payouts
     * @param _tokenIdSupply       _tokenIdSupply of the voucher set this is related to
     */
    function _withdrawDeposits(
        address _recipient,
        uint256 _amount,
        uint8 _paymentMethod,
        uint256 _tokenIdSupply
    ) internal    
      notZeroAddress(_recipient)
    {
        require(_amount > 0, "NO_FUNDS_TO_WITHDRAW");

        if (_paymentMethod == ETHETH || _paymentMethod == TKNETH) {
            payable(_recipient).sendValue(_amount);
            emit LogWithdrawal(msg.sender, _recipient, _amount);
        }

        if (_paymentMethod == ETHTKN || _paymentMethod == TKNTKN) {
            address addressTokenDeposits =
                IVoucherKernel(voucherKernel).getVoucherDepositToken(
                    _tokenIdSupply
                );

            SafeERC20.safeTransfer(
                IERC20(addressTokenDeposits),
                _recipient,
                _amount
            );
        }
    }

    /**
     * @notice Set the address of the BR contract
     * @param _bosonRouterAddress   The address of the Boson Route contract
     */
    function setBosonRouterAddress(address _bosonRouterAddress)
        external
        override
        onlyOwner
    {
        require(_bosonRouterAddress != address(0), "UNSPECIFIED_ADDRESS");

        bosonRouterAddress = _bosonRouterAddress;

        emit LogBosonRouterSet(_bosonRouterAddress, msg.sender);
    }

    /**
     * @notice Set the address of the ERC1155ERC721 contract
     * @param _tokensContractAddress   The address of the ERC1155ERC721 contract
     */
    function setTokenContractAddress(address _tokensContractAddress)
        external
        override
        onlyOwner
    {
     
        require(_tokensContractAddress != address(0), "UNSPECIFIED_ADDRESS");
        tokensContractAddress = _tokensContractAddress;
        emit LogTokenContractSet(_tokensContractAddress, msg.sender);
    }


    /**
     * @notice Update the amount in escrow of an address with the new value, based on VoucherSet/Voucher interaction
     * @param _account  The address of an account to update
     */
    function addEscrowAmount(address _account)
        external
        override
        payable
        onlyFromRouter
    {
        escrow[_account] = escrow[_account].add(msg.value);
    }

    /**
     * @notice Update the amount in escrowTokens of an address with the new value, based on VoucherSet/Voucher interaction
     * @param _token  The address of a token to query
     * @param _account  The address of an account to query
     * @param _newAmount  New amount to be set
     */
    function addEscrowTokensAmount(
        address _token,
        address _account,
        uint256 _newAmount
    ) external override onlyFromRouter {
        escrowTokens[_token][_account] =  escrowTokens[_token][_account].add(_newAmount);
    }

    /**
     * @notice Hook which will be triggered when a _tokenIdVoucher will be transferred. Escrow funds should be allocated to the new owner.
     * @param _from prev owner of the _tokenIdVoucher
     * @param _to next owner of the _tokenIdVoucher
     * @param _tokenIdVoucher _tokenIdVoucher that has been transferred
     */
    function onERC721Transfer(
        address _from,
        address _to,
        uint256 _tokenIdVoucher
    ) external override nonReentrant onlyTokensContract {
        address tokenAddress;

        uint256 tokenSupplyId =
            IVoucherKernel(voucherKernel).getIdSupplyFromVoucher(
                _tokenIdVoucher
            );

        uint8 paymentType =
            IVoucherKernel(voucherKernel).getVoucherPaymentMethod(
                tokenSupplyId
            );

        (uint256 price, uint256 depositBu) =
            IVoucherKernel(voucherKernel).getBuyerOrderCosts(tokenSupplyId);

        if (paymentType == ETHETH) {
            uint256 totalAmount = price.add(depositBu);

            //Reduce _from escrow amount and increase _to escrow amount
            escrow[_from] = escrow[_from].sub(totalAmount);
            escrow[_to] = escrow[_to].add(totalAmount);
        }


        if (paymentType == ETHTKN) {

            //Reduce _from escrow amount and increase _to escrow amount - price
            escrow[_from] = escrow[_from].sub(price);
            escrow[_to] = escrow[_to].add(price);

            tokenAddress = IVoucherKernel(voucherKernel).getVoucherDepositToken(
                tokenSupplyId
            );

            //Reduce _from escrow token amount and increase _to escrow token amount - deposit
            escrowTokens[tokenAddress][_from] = escrowTokens[tokenAddress][_from].sub(depositBu);
            escrowTokens[tokenAddress][_to] = escrowTokens[tokenAddress][_to].add(depositBu);

        }

        if (paymentType == TKNETH) {
            tokenAddress = IVoucherKernel(voucherKernel).getVoucherPriceToken(
                tokenSupplyId
            );
        

            //Reduce _from escrow token amount and increase _to escrow token amount - price 
            escrowTokens[tokenAddress][_from] = escrowTokens[tokenAddress][_from].sub(price);
            escrowTokens[tokenAddress][_to] = escrowTokens[tokenAddress][_to].add(price);

            //Reduce _from escrow amount and increase _to escrow amount - deposit
            escrow[_from] = escrow[_from].sub(depositBu);
            escrow[_to] = escrow[_to].add(depositBu);
        }

        if (paymentType == TKNTKN) {
            tokenAddress = IVoucherKernel(voucherKernel).getVoucherPriceToken(
                tokenSupplyId
            );


            //Reduce _from escrow token amount and increase _to escrow token amount - price 
            escrowTokens[tokenAddress][_from] = escrowTokens[tokenAddress][_from].sub(price);
            escrowTokens[tokenAddress][_to] = escrowTokens[tokenAddress][_to].add(price);

            tokenAddress = IVoucherKernel(voucherKernel).getVoucherDepositToken(
                tokenSupplyId
            );

            //Reduce _from escrow token amount and increase _to escrow token amount - deposit 
            escrowTokens[tokenAddress][_from] = escrowTokens[tokenAddress][_from].sub(depositBu);
            escrowTokens[tokenAddress][_to] = escrowTokens[tokenAddress][_to].add(depositBu);

        }
    }

    /**
     * @notice After the transfer happens the _tokenSupplyId should be updated in the promise. Escrow funds for the seller's deposits (If in ETH) should be allocated to the new owner as well.
     * @param _from prev owner of the _tokenSupplyId
     * @param _to nex owner of the _tokenSupplyId
     * @param _tokenSupplyId _tokenSupplyId for transfer
     * @param _value qty which has been transferred
     */
    function onERC1155Transfer(
        address _from,
        address _to,
        uint256 _tokenSupplyId,
        uint256 _value
    ) external override nonReentrant onlyTokensContract {
        uint8 paymentType =
            IVoucherKernel(voucherKernel).getVoucherPaymentMethod(
                _tokenSupplyId
            );

        uint256 depositSe;
        uint256 totalAmount;

        if (paymentType == ETHETH || paymentType == TKNETH) {
            depositSe = IVoucherKernel(voucherKernel).getSellerDeposit(
                _tokenSupplyId
            );
            totalAmount = depositSe.mul(_value);

            //Reduce _from escrow amount and increase _to escrow amount
            escrow[_from] = escrow[_from].sub(totalAmount);
            escrow[_to] = escrow[_to].add(totalAmount);
        }

        if (paymentType == ETHTKN || paymentType == TKNTKN) {
            address tokenDepositAddress =
                IVoucherKernel(voucherKernel).getVoucherDepositToken(
                    _tokenSupplyId
                );

            depositSe = IVoucherKernel(voucherKernel).getSellerDeposit(
                _tokenSupplyId
            );
            totalAmount = depositSe.mul(_value);

            //Reduce _from escrow token amount and increase _to escrow token amount - deposit
            escrowTokens[tokenDepositAddress][_from] = escrowTokens[tokenDepositAddress][_from].sub(totalAmount);
            escrowTokens[tokenDepositAddress][_to] = escrowTokens[tokenDepositAddress][_to].add(totalAmount);
        }

        IVoucherKernel(voucherKernel).setSupplyHolderOnTransfer(
            _tokenSupplyId,
            _to
        );
    }

    // // // // // // // //
    // GETTERS
    // // // // // // // //

    /**
     * @notice Get the address of Voucher Kernel contract
     * @return Address of Voucher Kernel contract
     */
    function getVoucherKernelAddress() 
        external 
        view 
        override
        returns (address)
    {
        return voucherKernel;
    }

    /**
     * @notice Get the address of Boson Router contract
     * @return Address of Boson Router contract
     */
    function getBosonRouterAddress() 
        external 
        view 
        override
        returns (address)
    {
        return bosonRouterAddress;
    }

    /**
     * @notice Get the address of ERC1155ERC721 contract
     * @return Address of ERC1155ERC721 contract
     */
    function getTokensContractAddress() 
        external 
        view 
        override
        returns (address)
    {
        return tokensContractAddress;
    }

    /**
     * @notice Ensure whether or not contract has been set to disaster state 
     * @return disasterState
     */
    function isDisasterStateSet() external view override returns(bool) {
        return disasterState;
    }

    /**
     * @notice Get the amount in escrow of an address
     * @param _account  The address of an account to query
     * @return          The balance in escrow
     */
    function getEscrowAmount(address _account)
        external
        view
        override
        returns (uint256)
    {
        return escrow[_account];
    }

    /**
     * @notice Get the amount in escrow of an address
     * @param _token  The address of a token to query
     * @param _account  The address of an account to query
     * @return          The balance in escrow
     */
    function getEscrowTokensAmount(address _token, address _account)
        external
        view
        override
        returns (uint256)
    {
        return escrowTokens[_token][_account];
    }
}
