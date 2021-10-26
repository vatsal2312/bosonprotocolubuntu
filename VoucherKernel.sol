// SPDX-License-Identifier: LGPL-3.0-or-later

pragma solidity 0.7.6;

//preparing for ERC-1066, ERC-1444, EIP-838

/**
 * @title VoucherKernel contract controls the core business logic
 * @dev Notes:
 *  - The usage of block.timestamp is honored since vouchers are defined currently with day-precision.
 *      See: https://ethereum.stackexchange.com/questions/5924/how-do-ethereum-mining-nodes-maintain-a-time-consistent-with-the-network/5931#5931
 */
// solhint-disable-next-line

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

interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC1155ERC721 is IERC165 {
    ///  SHARED INTERFACE

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address _operator, bool _approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address _account, address _operator)
        external
        view
        returns (bool);

    /// STANDARD ERC1155 SPECIFICS

    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _value
    );

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256[] _ids,
        uint256[] _values
    );

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string _value, uint256 indexed _id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address _account, uint256 _id)
        external
        view
        returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] calldata _accounts,
        uint256[] calldata _ids
    ) external view returns (uint256[] memory);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes calldata _data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _amounts,
        bytes calldata _data
    ) external;

    /// STANDARD ERC721 SPECIFICS

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address _owner) external view returns (uint256 _balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 _tokenId) external view returns (address _owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address _to, uint256 _tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 _tokenId)
        external
        view
        returns (address _operator);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    ) external;

    ///// IERC1155ERC721 SPECIFICS

    /**
     * @notice Mint an amount of a desired token
     * Currently no restrictions as to who is allowed to mint - so, it is external.
     * @dev ERC-1155
     * @param _to       owner of the minted token
     * @param _tokenId  ID of the token to be minted
     * @param _value    Amount of the token to be minted
     * @param _data     Additional data forwarded to onERC1155BatchReceived if _to is a contract
     */
    function mint(
        address _to,
        uint256 _tokenId,
        uint256 _value,
        bytes calldata _data
    ) external;

    /**
     * @notice Burn an amount of tokens with the given ID
     * @dev ERC-1155
     * @param _account  Account which owns the token
     * @param _tokenId  ID of the token
     * @param _value    Amount of the token
     */
    function burn(
        address _account,
        uint256 _tokenId,
        uint256 _value
    ) external;

    /**
     * @notice Function to mint tokens.
     * @dev ERC-721
     * @param _to The address that will receive the minted tokens.
     * @param _tokenId The token id to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _tokenId) external returns (bool);

    /**
     * @notice Get the address of Voucher Kernel contract
     * @return Address of Voucher Kernel contract
     */
    function getVoucherKernelAddress() external view returns (address);

    /**
     * @notice Get the address of Cashier contract
     * @return Address of Cashier address
     */
    function getCashierAddress() external view returns (address);
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

contract VoucherKernel is IVoucherKernel, Ownable, Pausable, ReentrancyGuard, UsingHelpers {
    using Address for address;
    using SafeMath for uint256;

    //AssetRegistry assetRegistry;
    address private tokensContract;

    //promise for an asset could be reusable, but simplified here for brevity
    struct Promise {
        bytes32 promiseId;
        uint256 nonce; //the asset that is offered
        address seller; //the seller who created the promise
        //we simplify the value for the demoapp, otherwise voucher details would be packed in one bytes32 field value
        uint256 validFrom;
        uint256 validTo;
        uint256 price;
        uint256 depositSe;
        uint256 depositBu;
        uint256 idx;
    }

    struct VoucherPaymentMethod {
        uint8 paymentMethod;
        address addressTokenPrice;
        address addressTokenDeposits;
    }

    address private bosonRouterAddress; //address of the Boson Router contract
    address private cashierAddress; //address of the Cashier contract

    mapping(bytes32 => Promise) private promises; //promises to deliver goods or services
    mapping(address => uint256) private tokenNonces; //mapping between seller address and its own nonces. Every time seller creates supply ID it gets incremented. Used to avoid duplicate ID's
    mapping(uint256 => VoucherPaymentMethod) private paymentDetails; // tokenSupplyId to VoucherPaymentMethod

    bytes32[] private promiseKeys;

    mapping(uint256 => bytes32) private ordersPromise; //mapping between an order (supply a.k.a. VoucherSet token) and a promise

    mapping(uint256 => VoucherStatus) private vouchersStatus; //recording the vouchers evolution

    //ID reqs
    mapping(uint256 => uint256) private typeCounters; //counter for ID of a particular type of NFT
    uint256 private constant MASK_TYPE = uint256(uint128(~0)) << 128; //the type mask in the upper 128 bits
    //1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

    uint256 private constant MASK_NF_INDEX = uint128(~0); //the non-fungible index mask in the lower 128
    //0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111

    uint256 private constant TYPE_NF_BIT = 1 << 255; //the first bit represents an NFT type
    //1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

    uint256 private typeId; //base token type ... 127-bits cover 1.701411835*10^38 types (not differentiating between FTs and NFTs)
    /* Token IDs:
    Fungibles: 0, followed by 127-bit FT type ID, in the upper 128 bits, followed by 0 in lower 128-bits
    <0><uint127: base token id><uint128: 0>
    
    Non-fungible VoucherSets (supply tokens): 1, followed by 127-bit NFT type ID, in the upper 128 bits, followed by 0 in lower 128-bits
    <1><uint127: base token id><uint128: 0    
    
    Non-fungible vouchers: 1, followed by 127-bit NFT type ID, in the upper 128 bits, followed by a 1-based index of an NFT token ID.
    <1><uint127: base token id><uint128: index of non-fungible>
    */

    uint256 private complainPeriod;
    uint256 private cancelFaultPeriod;

    event LogPromiseCreated(
        bytes32 indexed _promiseId,
        uint256 indexed _nonce,
        address indexed _seller,
        uint256 _validFrom,
        uint256 _validTo,
        uint256 _idx
    );

    event LogVoucherCommitted(
        uint256 indexed _tokenIdSupply,
        uint256 _tokenIdVoucher,
        address _issuer,
        address _holder,
        bytes32 _promiseId
    );

    event LogVoucherRedeemed(
        uint256 _tokenIdVoucher,
        address _holder,
        bytes32 _promiseId
    );

    event LogVoucherRefunded(uint256 _tokenIdVoucher);

    event LogVoucherComplain(uint256 _tokenIdVoucher);

    event LogVoucherFaultCancel(uint256 _tokenIdVoucher);

    event LogExpirationTriggered(uint256 _tokenIdVoucher, address _triggeredBy);

    event LogFinalizeVoucher(uint256 _tokenIdVoucher, address _triggeredBy);

    event LogBosonRouterSet(address _newBosonRouter, address _triggeredBy);

    event LogCashierSet(address _newCashier, address _triggeredBy);

    event LogComplainPeriodChanged(
        uint256 _newComplainPeriod,
        address _triggeredBy
    );

    event LogCancelFaultPeriodChanged(
        uint256 _newCancelFaultPeriod,
        address _triggeredBy
    );

    event LogVoucherSetFaultCancel(uint256 _tokenIdSupply, address _issuer);

    event LogFundsReleased(
        uint256 _tokenIdVoucher,
        uint8 _type //0 .. payment, 1 .. deposits
    );

    /**
     * @notice Checks that only the BosonRouter contract can call a function
    */
    modifier onlyFromRouter() {
        require(bosonRouterAddress != address(0), "UNSPECIFIED_BR");
        require(msg.sender == bosonRouterAddress, "UNAUTHORIZED_BR");
        _;
    }

    /**
     * @notice Checks that only the Cashier contract can call a function
    */
    modifier onlyFromCashier() {
        require(cashierAddress != address(0), "UNSPECIFIED_BR");
        require(msg.sender == cashierAddress, "UNAUTHORIZED_C");
        _;
    }

    /**
     * @notice Checks that only the owver of the specified voucher can call a function
    */
    modifier onlyVoucherOwner(uint256 _tokenIdVoucher, address _sender) {
        //check authorization
        require(
            IERC721(tokensContract).ownerOf(_tokenIdVoucher) == _sender,
            "UNAUTHORIZED_V"
        );
        _;
    }

    modifier notZeroAddress(address _addressToCheck) {
        require(_addressToCheck != address(0), "0A");
        _;
    }

    /**
     * @notice Construct and initialze the contract. Iniialises associated contract addresses, the complain period, and the cancel or fault period
     * @param _tokensContract address of the associated ERC1155ERC721 contract instance
     */
    constructor(address _tokensContract)
    notZeroAddress(_tokensContract)
    {
        tokensContract = _tokensContract;

        complainPeriod = 7 * 1 days;
        cancelFaultPeriod = 7 * 1 days;
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
     * @notice Creating a new promise for goods or services.
     * Can be reused, e.g. for making different batches of these (in the future).
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
    )
    external
    override
    nonReentrant
    onlyFromRouter
    returns (uint256) {
        require(_validFrom <= _validTo, "INVALID_VALIDITY_FROM");
        // solhint-disable-next-line not-rely-on-time
        require(_validTo >= block.timestamp + 5 minutes, "INVALID_VALIDITY_TO");

        bytes32 key;
        key = keccak256(
            abi.encodePacked(_seller, tokenNonces[_seller]++, _validFrom, _validTo, address(this))
        );

        if (promiseKeys.length > 0) {
            require(
                promiseKeys[promises[key].idx] != key,
                "PROMISE_ALREADY_EXISTS"
            );
        }

        promises[key] = Promise({
            promiseId: key,
            nonce: tokenNonces[_seller],
            seller: _seller,
            validFrom: _validFrom,
            validTo: _validTo,
            price: _price,
            depositSe: _depositSe,
            depositBu: _depositBu,
            idx: promiseKeys.length
        });

        promiseKeys.push(key);

        emit LogPromiseCreated(
            key,
            tokenNonces[_seller],
            _seller,
            _validFrom,
            _validTo,
            promiseKeys.length - 1
        );

        return createOrder(_seller, key, _quantity);
    }

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
    ) external override onlyFromRouter {
        require(
            _paymentMethod > 0 &&
                _paymentMethod <= 4,
            "INVALID PAYMENT METHOD"
        );
        
        paymentDetails[_tokenIdSupply] = VoucherPaymentMethod({
            paymentMethod: _paymentMethod,
            addressTokenPrice: _tokenPrice,
            addressTokenDeposits: _tokenDeposits
        });
    }

    /**
     * @notice Create an order for offering a certain quantity of an asset
     * This creates a listing in a marketplace, technically as an ERC-1155 non-fungible token with supply.
     * @param _seller     seller of the promise
     * @param _promiseId  ID of a promise (simplified into asset for demo)
     * @param _quantity   Quantity of assets on offer
     */
    function createOrder(
        address _seller,
        bytes32 _promiseId,
        uint256 _quantity
    ) private returns (uint256) {
        require(_promiseId != bytes32(0), "UNSPECIFIED_PROMISE");
        require(promises[_promiseId].seller == _seller, "UNAUTHORIZED_CO");
        require(_quantity > 0, "INVALID_QUANTITY");

        uint256 tokenIdSupply = generateTokenType(true); //create & assign a new non-fungible type

        ordersPromise[tokenIdSupply] = _promiseId;

        IERC1155ERC721(tokensContract).mint(
            _seller,
            tokenIdSupply,
            _quantity,
            ""
        );

        return tokenIdSupply;
    }

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
    )
    external
    override
    onlyFromRouter
    nonReentrant
    {
        uint8 paymentMethod = getVoucherPaymentMethod(_tokenIdSupply);

        //checks
        require(paymentMethod == _paymentMethod, "Incorrect Payment Method");
        checkOrderFillable(_tokenIdSupply, _issuer, _holder);

        //close order
        uint256 voucherTokenId = extract721(_issuer, _holder, _tokenIdSupply);

        emit LogVoucherCommitted(
            _tokenIdSupply,
            voucherTokenId,
            _issuer,
            _holder,
            getPromiseIdFromVoucherId(voucherTokenId)
        );
    }

    /**
     * @notice Check order is fillable
     * @dev Will throw if checks don't pass
     * @param _tokenIdSupply  ID of the supply token
     * @param _issuer  Address of the token's issuer
     * @param _holder  Address of the recipient of the voucher (ERC-721)
     */
    function checkOrderFillable(
        uint256 _tokenIdSupply,
        address _issuer,
        address _holder
    ) internal view {
        require(_tokenIdSupply != 0, "UNSPECIFIED_ID");

        if (_holder.isContract()) {
            require(
                IERC165(_holder).supportsInterface(0x150b7a02),
                "UNSUPPORTED_ERC721_RECEIVED"
            );

        }

        require(_holder != address(0), "UNSPECIFIED_ADDRESS");
        require(
            IERC1155(tokensContract).balanceOf(_issuer, _tokenIdSupply) > 0,
            "OFFER_EMPTY"
        );

        bytes32 promiseKey = ordersPromise[_tokenIdSupply];

        require(
            promises[promiseKey].validTo >= block.timestamp,
            "OFFER_EXPIRED"
        );
    }

    /**
     * @notice Extract a standard non-fungible token ERC-721 from a supply stored in ERC-1155
     * @dev Token ID is derived following the same principles for both ERC-1155 and ERC-721
     * @param _issuer          The address of the token issuer
     * @param _to              The address of the token holder
     * @param _tokenIdSupply   ID of the token type
     * @return                 ID of the voucher token
     */
    function extract721(
        address _issuer,
        address _to,
        uint256 _tokenIdSupply
    ) internal returns (uint256) {
        if (_to.isContract()) {
            require(
                IERC721Receiver(_to).onERC721Received(
                    _issuer,
                    msg.sender,
                    _tokenIdSupply,
                    ""
                ) == IERC721Receiver(_to).onERC721Received.selector,
                "UNSUPPORTED_ERC721_RECEIVED"
            );
            //bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))
        }

        IERC1155ERC721(tokensContract).burn(_issuer, _tokenIdSupply, 1); // This is hardcoded as 1 on purpose

        //calculate tokenId
        uint256 voucherTokenId =
            _tokenIdSupply | ++typeCounters[_tokenIdSupply];

        //set status
        vouchersStatus[voucherTokenId].status = determineStatus(
            vouchersStatus[voucherTokenId].status,
            IDX_COMMIT
        );
        vouchersStatus[voucherTokenId].isPaymentReleased = false;
        vouchersStatus[voucherTokenId].isDepositsReleased = false;

        //mint voucher NFT as ERC-721
        IERC1155ERC721(tokensContract).mint(_to, voucherTokenId);

        return voucherTokenId;
    }

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
    ) external override whenPaused onlyFromCashier {
        IERC1155ERC721(tokensContract).burn(_issuer, _tokenIdSupply, _qty);
    }

    /**
     * @notice Creating a new token type, serving as the base for tokenID generation for NFTs, and a de facto ID for FTs.
     * @param _isNonFungible   Flag for generating NFT or FT
     * @return _tokenType   Returns a newly generated token type
     */
    function generateTokenType(bool _isNonFungible)
        internal
        returns (uint256 _tokenType)
    {
        typeId++;

        if (_isNonFungible) {
            _tokenType = TYPE_NF_BIT | (typeId << 128); //upper bit is 1, followed by sequence, leaving lower 128-bits as 0
        } else {
            _tokenType = typeId << 128; //upper bit is not set, followed by sequence, leaving lower 128-bits as 0
        }

        return _tokenType;
    }

    /* solhint-disable */

    /**
     * @notice Redemption of the vouchers promise
     * @param _tokenIdVoucher   ID of the voucher
     * @param _messageSender   account that called the fn from the BR contract
     */
    function redeem(uint256 _tokenIdVoucher, address _messageSender)
        external
        override
        whenNotPaused
        onlyFromRouter
        onlyVoucherOwner(_tokenIdVoucher, _messageSender)
    {
        //check status
        require(
            isStateCommitted(vouchersStatus[_tokenIdVoucher].status),
            "ALREADY_PROCESSED"
        );

        //check validity period
        isInValidityPeriod(_tokenIdVoucher);
        Promise memory tPromise =
            promises[getPromiseIdFromVoucherId(_tokenIdVoucher)];

        vouchersStatus[_tokenIdVoucher].complainPeriodStart = block.timestamp;
        vouchersStatus[_tokenIdVoucher].status = determineStatus(
            vouchersStatus[_tokenIdVoucher].status,
            IDX_REDEEM
        );

        emit LogVoucherRedeemed(
            _tokenIdVoucher,
            _messageSender,
            tPromise.promiseId
        );
    }

    // // // // // // // //
    // UNHAPPY PATH
    // // // // // // // //

    /**
     * @notice Refunding a voucher
     * @param _tokenIdVoucher   ID of the voucher
     * @param _messageSender   account that called the fn from the BR contract
     */
    function refund(uint256 _tokenIdVoucher, address _messageSender)
        external
        override
        whenNotPaused
        onlyFromRouter
        onlyVoucherOwner(_tokenIdVoucher, _messageSender)
    {
        require(
            isStateCommitted(vouchersStatus[_tokenIdVoucher].status),
            "INAPPLICABLE_STATUS"
        );

        //check validity period
        isInValidityPeriod(_tokenIdVoucher);

        vouchersStatus[_tokenIdVoucher].complainPeriodStart = block.timestamp;
        vouchersStatus[_tokenIdVoucher].status = determineStatus(
            vouchersStatus[_tokenIdVoucher].status,
            IDX_REFUND
        );

        emit LogVoucherRefunded(_tokenIdVoucher);
    }

    /**
     * @notice Issue a complaint for a voucher
     * @param _tokenIdVoucher   ID of the voucher
     * @param _messageSender   account that called the fn from the BR contract
     */
    function complain(uint256 _tokenIdVoucher, address _messageSender)
        external
        override
        whenNotPaused
        onlyFromRouter
        onlyVoucherOwner(_tokenIdVoucher, _messageSender)
    {
        require(
            !isStatus(vouchersStatus[_tokenIdVoucher].status, IDX_COMPLAIN),
            "ALREADY_COMPLAINED"
        );
        require(
            !isStatus(vouchersStatus[_tokenIdVoucher].status, IDX_FINAL),
            "ALREADY_FINALIZED"
        );

        //check if still in the complain period
        Promise memory tPromise =
            promises[getPromiseIdFromVoucherId(_tokenIdVoucher)];

        //if redeemed or refunded
        if (
            isStateRedemptionSigned(vouchersStatus[_tokenIdVoucher].status) ||
            isStateRefunded(vouchersStatus[_tokenIdVoucher].status)
        ) {
            if (
                !isStatus(
                    vouchersStatus[_tokenIdVoucher].status,
                    IDX_CANCEL_FAULT
                )
            ) {
                require(
                    block.timestamp <=
                        vouchersStatus[_tokenIdVoucher].complainPeriodStart +
                            complainPeriod +
                            cancelFaultPeriod,
                    "COMPLAINPERIOD_EXPIRED"
                );
            } else {
                require(
                    block.timestamp <=
                        vouchersStatus[_tokenIdVoucher].complainPeriodStart +
                            complainPeriod,
                    "COMPLAINPERIOD_EXPIRED"
                );
            }

            vouchersStatus[_tokenIdVoucher].cancelFaultPeriodStart = block
                .timestamp;
            vouchersStatus[_tokenIdVoucher].status = determineStatus(
                vouchersStatus[_tokenIdVoucher].status,
                IDX_COMPLAIN
            );

            emit LogVoucherComplain(_tokenIdVoucher);

            //if expired
        } else if (isStateExpired(vouchersStatus[_tokenIdVoucher].status)) {
            if (
                !isStatus(
                    vouchersStatus[_tokenIdVoucher].status,
                    IDX_CANCEL_FAULT
                )
            ) {
                require(
                    block.timestamp <=
                        tPromise.validTo + complainPeriod + cancelFaultPeriod,
                    "COMPLAINPERIOD_EXPIRED"
                );
            } else {
                require(
                    block.timestamp <= tPromise.validTo + complainPeriod,
                    "COMPLAINPERIOD_EXPIRED"
                );
            }

            vouchersStatus[_tokenIdVoucher].cancelFaultPeriodStart = block
                .timestamp;
            vouchersStatus[_tokenIdVoucher].status = determineStatus(
                vouchersStatus[_tokenIdVoucher].status,
                IDX_COMPLAIN
            );

            emit LogVoucherComplain(_tokenIdVoucher);

            //if cancelOrFault
        } else if (
            isStatus(vouchersStatus[_tokenIdVoucher].status, IDX_CANCEL_FAULT)
        ) {
            require(
                block.timestamp <=
                    vouchersStatus[_tokenIdVoucher].complainPeriodStart +
                        complainPeriod,
                "COMPLAINPERIOD_EXPIRED"
            );

            vouchersStatus[_tokenIdVoucher].status = determineStatus(
                vouchersStatus[_tokenIdVoucher].status,
                IDX_COMPLAIN
            );

            emit LogVoucherComplain(_tokenIdVoucher);
        } else {
            revert("INAPPLICABLE_STATUS");
        }
    }

    /**
     * @notice Cancel/Fault transaction by the Seller, admitting to a fault or backing out of the deal
     * @param _tokenIdVoucher   ID of the voucher
     * @param _messageSender   account that called the fn from the BR contract
     */
    function cancelOrFault(uint256 _tokenIdVoucher, address _messageSender)
        external
        override
        onlyFromRouter
        whenNotPaused
    {
        uint256 tokenIdSupply = getIdSupplyFromVoucher(_tokenIdVoucher);
        require(
            getSupplyHolder(tokenIdSupply) == _messageSender,
            "UNAUTHORIZED_COF"
        );

        uint8 tStatus = vouchersStatus[_tokenIdVoucher].status;

        require(!isStatus(tStatus, IDX_CANCEL_FAULT), "ALREADY_CANCELFAULT");
        require(!isStatus(tStatus, IDX_FINAL), "ALREADY_FINALIZED");

        Promise memory tPromise =
            promises[getPromiseIdFromVoucherId(_tokenIdVoucher)];

        if (isStatus(tStatus, IDX_REDEEM) || isStatus(tStatus, IDX_REFUND)) {
            //if redeemed or refunded
            if (!isStatus(tStatus, IDX_COMPLAIN)) {
                require(
                    block.timestamp <=
                        vouchersStatus[_tokenIdVoucher].complainPeriodStart +
                            complainPeriod +
                            cancelFaultPeriod,
                    "COFPERIOD_EXPIRED"
                );
                vouchersStatus[_tokenIdVoucher].complainPeriodStart = block
                    .timestamp; //resetting the complain period
            } else {
                require(
                    block.timestamp <=
                        vouchersStatus[_tokenIdVoucher].cancelFaultPeriodStart +
                            cancelFaultPeriod,
                    "COFPERIOD_EXPIRED"
                );
            }
        } else if (isStatus(tStatus, IDX_EXPIRE)) {
            //if expired
            if (!isStatus(tStatus, IDX_COMPLAIN)) {
                require(
                    block.timestamp <=
                        tPromise.validTo + complainPeriod + cancelFaultPeriod,
                    "COFPERIOD_EXPIRED"
                );
                vouchersStatus[_tokenIdVoucher].complainPeriodStart = block
                    .timestamp;
            } else {
                require(
                    block.timestamp <=
                        vouchersStatus[_tokenIdVoucher].cancelFaultPeriodStart +
                            cancelFaultPeriod,
                    "COFPERIOD_EXPIRED"
                );
            }
        } else if (isStateCommitted(tStatus)) {
            //if committed only
            require(
                block.timestamp <=
                    tPromise.validTo + complainPeriod + cancelFaultPeriod,
                "COFPERIOD_EXPIRED"
            );
            vouchersStatus[_tokenIdVoucher].complainPeriodStart = block
                .timestamp; //complain period starts
        } else {
            revert("INAPPLICABLE_STATUS");
        }

        vouchersStatus[_tokenIdVoucher].status = determineStatus(
            tStatus,
            IDX_CANCEL_FAULT
        );

        emit LogVoucherFaultCancel(_tokenIdVoucher);
    }

    /**
     * @notice Cancel/Fault transaction by the Seller, cancelling the remaining uncommitted voucher set so that seller prevents buyers from committing to vouchers for items no longer in exchange.
     * @param _tokenIdSupply   ID of the voucher set
     * @param _issuer   owner of the voucher
     */
    function cancelOrFaultVoucherSet(uint256 _tokenIdSupply, address _issuer)
    external
    override
    onlyFromRouter
    nonReentrant
    whenNotPaused
    returns (uint256)
    {
        require(getSupplyHolder(_tokenIdSupply) == _issuer, "UNAUTHORIZED_COF");

        uint256 remQty = getRemQtyForSupply(_tokenIdSupply, _issuer);

        require(remQty > 0, "OFFER_EMPTY");

        IERC1155ERC721(tokensContract).burn(_issuer, _tokenIdSupply, remQty);

        emit LogVoucherSetFaultCancel(_tokenIdSupply, _issuer);

        return remQty;
    }

    // // // // // // // //
    // BACK-END PROCESS
    // // // // // // // //

    /**
     * @notice Mark voucher token that the payment was released
     * @param _tokenIdVoucher   ID of the voucher token
     */
    function setPaymentReleased(uint256 _tokenIdVoucher)
        external
        override
        onlyFromCashier
    {
        require(_tokenIdVoucher != 0, "UNSPECIFIED_ID");
        vouchersStatus[_tokenIdVoucher].isPaymentReleased = true;

        emit LogFundsReleased(_tokenIdVoucher, 0);
    }

    /**
     * @notice Mark voucher token that the deposits were released
     * @param _tokenIdVoucher   ID of the voucher token
     */
    function setDepositsReleased(uint256 _tokenIdVoucher)
        external
        override
        onlyFromCashier
    {
        require(_tokenIdVoucher != 0, "UNSPECIFIED_ID");
        vouchersStatus[_tokenIdVoucher].isDepositsReleased = true;

        emit LogFundsReleased(_tokenIdVoucher, 1);
    }

    /**
     * @notice Mark voucher token as expired
     * @param _tokenIdVoucher   ID of the voucher token
     */
    function triggerExpiration(uint256 _tokenIdVoucher) external override {
        require(_tokenIdVoucher != 0, "UNSPECIFIED_ID");

        Promise memory tPromise =
            promises[getPromiseIdFromVoucherId(_tokenIdVoucher)];

        if (
            tPromise.validTo < block.timestamp &&
            isStateCommitted(vouchersStatus[_tokenIdVoucher].status)
        ) {
            vouchersStatus[_tokenIdVoucher].status = determineStatus(
                vouchersStatus[_tokenIdVoucher].status,
                IDX_EXPIRE
            );

            emit LogExpirationTriggered(_tokenIdVoucher, msg.sender);
        }
    }

    /**
     * @notice Mark voucher token to the final status
     * @param _tokenIdVoucher   ID of the voucher token
     */
    function triggerFinalizeVoucher(uint256 _tokenIdVoucher) external override {
        require(_tokenIdVoucher != 0, "UNSPECIFIED_ID");

        uint8 tStatus = vouchersStatus[_tokenIdVoucher].status;

        require(!isStatus(tStatus, IDX_FINAL), "ALREADY_FINALIZED");

        bool mark;
        Promise memory tPromise =
            promises[getPromiseIdFromVoucherId(_tokenIdVoucher)];

        if (isStatus(tStatus, IDX_COMPLAIN)) {
            if (isStatus(tStatus, IDX_CANCEL_FAULT)) {
                //if COMPLAIN && COF: then final
                mark = true;
            } else if (
                block.timestamp >=
                vouchersStatus[_tokenIdVoucher].cancelFaultPeriodStart +
                    cancelFaultPeriod
            ) {
                //if COMPLAIN: then final after cof period
                mark = true;
            }
        } else if (
            isStatus(tStatus, IDX_CANCEL_FAULT) &&
            block.timestamp >=
            vouchersStatus[_tokenIdVoucher].complainPeriodStart + complainPeriod
        ) {
            //if COF: then final after complain period
            mark = true;
        } else if (
            isStateRedemptionSigned(tStatus) || isStateRefunded(tStatus)
        ) {
            //if RDM/RFND NON_COMPLAIN: then final after complainPeriodStart + complainPeriod
            if (
                block.timestamp >=
                vouchersStatus[_tokenIdVoucher].complainPeriodStart +
                    complainPeriod
            ) {
                mark = true;
            }
        } else if (isStateExpired(tStatus)) {
            //if EXP NON_COMPLAIN: then final after validTo + complainPeriod
            if (block.timestamp >= tPromise.validTo + complainPeriod) {
                mark = true;
            }
        }

        if (mark) {
            vouchersStatus[_tokenIdVoucher].status = determineStatus(
                tStatus,
                IDX_FINAL
            );
            emit LogFinalizeVoucher(_tokenIdVoucher, msg.sender);
        }
    }

    /* solhint-enable */

    // // // // // // // //
    // UTILS
    // // // // // // // //

    /**
     * @notice Set the address of the new holder of a _tokenIdSupply on transfer
     * @param _tokenIdSupply   _tokenIdSupply which will be transferred
     * @param _newSeller   new holder of the supply
     */
    function setSupplyHolderOnTransfer(
        uint256 _tokenIdSupply,
        address _newSeller
    ) external override onlyFromCashier {
        bytes32 promiseKey = ordersPromise[_tokenIdSupply];
        promises[promiseKey].seller = _newSeller;
    }

    /**
     * @notice Set the address of the Boson Router contract
     * @param _bosonRouterAddress   The address of the BR contract
     */
    function setBosonRouterAddress(address _bosonRouterAddress)
        external
        onlyOwner
    {
        require(_bosonRouterAddress != address(0), "UNSPECIFIED_ADDRESS");

        bosonRouterAddress = _bosonRouterAddress;

        emit LogBosonRouterSet(_bosonRouterAddress, msg.sender);
    }

    /**
     * @notice Set the address of the Cashier contract
     * @param _cashierAddress   The address of the BR contract
     */
    function setCashierAddress(address _cashierAddress)
        external
        override
        onlyOwner
    {
        require(_cashierAddress != address(0), "UNSPECIFIED_ADDRESS");

        cashierAddress = _cashierAddress;

        emit LogCashierSet(_cashierAddress, msg.sender);
    }

    /**
     * @notice Set the general complain period, should be used sparingly as it has significant consequences. Here done simply for demo purposes.
     * @param _complainPeriod   the new value for complain period (in number of seconds)
     */
    function setComplainPeriod(uint256 _complainPeriod)
        external
        override
        onlyOwner
    {
        complainPeriod = _complainPeriod;

        emit LogComplainPeriodChanged(_complainPeriod, msg.sender);
    }

    /**
     * @notice Set the general cancelOrFault period, should be used sparingly as it has significant consequences. Here done simply for demo purposes.
     * @param _cancelFaultPeriod   the new value for cancelOrFault period (in number of seconds)
     */
    function setCancelFaultPeriod(uint256 _cancelFaultPeriod)
        external
        override
        onlyOwner
    {
        cancelFaultPeriod = _cancelFaultPeriod;

        emit LogCancelFaultPeriodChanged(_cancelFaultPeriod, msg.sender);
    }

    // // // // // // // //
    // GETTERS
    // // // // // // // //

    /**
     * @notice Get the promise ID at specific index
     * @param _idx  Index in the array of promise keys
     * @return      Promise ID
     */
    function getPromiseKey(uint256 _idx)
        external
        view
        override
        returns (bytes32)
    {
        return promiseKeys[_idx];
    }

    /**
     * @notice Get the supply token ID from a voucher token
     * @param _tokenIdVoucher   ID of the voucher token
     * @return                  ID of the supply token
     */
    function getIdSupplyFromVoucher(uint256 _tokenIdVoucher)
        public
        pure
        override
        returns (uint256)
    {
        return _tokenIdVoucher & MASK_TYPE;
    }

    /**
     * @notice Get the promise ID from a voucher token
     * @param _tokenIdVoucher   ID of the voucher token
     * @return                  ID of the promise
     */
    function getPromiseIdFromVoucherId(uint256 _tokenIdVoucher)
        public
        view
        override
        returns (bytes32)
    {
        require(_tokenIdVoucher != 0, "UNSPECIFIED_ID");

        uint256 tokenIdSupply = getIdSupplyFromVoucher(_tokenIdVoucher);
        return promises[ordersPromise[tokenIdSupply]].promiseId;
    }

    /**
     * @notice Get the remaining quantity left in supply of tokens (e.g ERC-721 left in ERC-1155) of an account
     * @param _tokenSupplyId  Token supply ID
     * @param _tokenSupplyOwner    holder of the Token Supply
     * @return          remaining quantity
     */
    function getRemQtyForSupply(uint256 _tokenSupplyId, address _tokenSupplyOwner)
        public
        view
        override
        returns (uint256)
    {
        return IERC1155(tokensContract).balanceOf(_tokenSupplyOwner, _tokenSupplyId);
    }

    /**
     * @notice Get all necessary funds for a supply token
     * @param _tokenIdSupply   ID of the supply token
     * @return                  returns a tuple (Payment amount, Seller's deposit, Buyer's deposit)
     */
    function getOrderCosts(uint256 _tokenIdSupply)
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        bytes32 promiseKey = ordersPromise[_tokenIdSupply];
        return (
            promises[promiseKey].price,
            promises[promiseKey].depositSe,
            promises[promiseKey].depositBu
        );
    }

    /**
     * @notice Get Buyer costs required to make an order for a supply token
     * @param _tokenIdSupply   ID of the supply token
     * @return                  returns a tuple (Payment amount, Buyer's deposit)
     */
    function getBuyerOrderCosts(uint256 _tokenIdSupply)
        external
        view
        override
        returns (uint256, uint256)
    {
        bytes32 promiseKey = ordersPromise[_tokenIdSupply];
        return (promises[promiseKey].price, promises[promiseKey].depositBu);
    }

    /**
     * @notice Get Seller deposit
     * @param _tokenIdSupply   ID of the supply token
     * @return                  returns sellers deposit
     */
    function getSellerDeposit(uint256 _tokenIdSupply)
        external
        view
        override
        returns (uint256)
    {
        bytes32 promiseKey = ordersPromise[_tokenIdSupply];
        return promises[promiseKey].depositSe;
    }

    /**
     * @notice Get the holder of a supply
     * @param _tokenIdSupply ID of the order (aka VoucherSet) which is mapped to the corresponding Promise.
     * @return                  Address of the holder
     */
    function getSupplyHolder(uint256 _tokenIdSupply)
        public
        view
        override
        returns (address)
    {
        bytes32 promiseKey = ordersPromise[_tokenIdSupply];
        return promises[promiseKey].seller;
    }

    /**
     * @notice Get promise data not retrieved by other accessor functions
     * @param _promiseKey   ID of the promise
     * @return promise data not returned by other accessor methods
     */
    function getPromiseData(bytes32 _promiseKey)
        external
        view
        override
        returns (bytes32, uint256, uint256, uint256, uint256 )
    {
        Promise memory tPromise = promises[_promiseKey];
        return (tPromise.promiseId, tPromise.nonce, tPromise.validFrom, tPromise.validTo, tPromise.idx); 
    }

    /**
     * @notice Get the current status of a voucher
     * @param _tokenIdVoucher   ID of the voucher token
     * @return                  Status of the voucher (via enum)
     */
    function getVoucherStatus(uint256 _tokenIdVoucher)
        external
        view
        override
        returns (
            uint8,
            bool,
            bool,
            uint256,
            uint256
        )
    {
        return (
            vouchersStatus[_tokenIdVoucher].status,
            vouchersStatus[_tokenIdVoucher].isPaymentReleased,
            vouchersStatus[_tokenIdVoucher].isDepositsReleased,
            vouchersStatus[_tokenIdVoucher].complainPeriodStart,
            vouchersStatus[_tokenIdVoucher].cancelFaultPeriodStart
        );
    }

    /**
     * @notice Get the holder of a voucher
     * @param _tokenIdVoucher   ID of the voucher token
     * @return                  Address of the holder
     */
    function getVoucherHolder(uint256 _tokenIdVoucher)
        external
        view
        override
        returns (address)
    {
        return IERC721(tokensContract).ownerOf(_tokenIdVoucher);
    }

    /**
     * @notice Get the address of the token where the price for the supply is held
     * @param _tokenIdSupply   ID of the voucher supply token
     * @return                  Address of the token
     */
    function getVoucherPriceToken(uint256 _tokenIdSupply)
        external
        view
        override
        returns (address)
    {
        return paymentDetails[_tokenIdSupply].addressTokenPrice;
    }

    /**
     * @notice Get the address of the token where the deposits for the supply are held
     * @param _tokenIdSupply   ID of the voucher supply token
     * @return                  Address of the token
     */
    function getVoucherDepositToken(uint256 _tokenIdSupply)
        external
        view
        override
        returns (address)
    {
        return paymentDetails[_tokenIdSupply].addressTokenDeposits;
    }

    /**
     * @notice Get the payment method for a particular _tokenIdSupply
     * @param _tokenIdSupply   ID of the voucher supply token
     * @return                  payment method
     */
    function getVoucherPaymentMethod(uint256 _tokenIdSupply)
        public
        view
        override
        returns (uint8)
    {
        return paymentDetails[_tokenIdSupply].paymentMethod;
    }

    /**
     * @notice Checks whether a voucher is in valid period for redemption (between start date and end date)
     * @param _tokenIdVoucher ID of the voucher token
     */
    function isInValidityPeriod(uint256 _tokenIdVoucher)
        public
        view
        override
        returns (bool)
    {
        //check validity period
        Promise memory tPromise =
            promises[getPromiseIdFromVoucherId(_tokenIdVoucher)];
        require(tPromise.validFrom <= block.timestamp, "INVALID_VALIDITY_FROM");
        require(tPromise.validTo >= block.timestamp, "INVALID_VALIDITY_TO");

        return true;
    }

    /**
     * @notice Checks whether a voucher is in valid state to be transferred. If either payments or deposits are released, voucher could not be transferred
     * @param _tokenIdVoucher ID of the voucher token
     */
    function isVoucherTransferable(uint256 _tokenIdVoucher)
        external
        view
        override
        returns (bool)
    {
        return
            !(vouchersStatus[_tokenIdVoucher].isPaymentReleased ||
                vouchersStatus[_tokenIdVoucher].isDepositsReleased);
    }

    /**
     * @notice Get address of the Boson Router to which this contract points
     * @return Address of the Boson Router contract
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
     * @notice Get address of the Cashier contract to which this contract points
     * @return Address of the Cashier contract
     */
    function getCashierAddress()
        external
        view
        override
        returns (address)
    {
        return cashierAddress;
    }

    /**
     * @notice Get the token nonce for a seller
     * @param _seller Address of the seller
     * @return The seller's nonce
     */
    function getTokenNonce(address _seller)
        external
        view
        override
        returns (uint256) 
    {
        return tokenNonces[_seller];
    }

    /**
     * @notice Get the current type Id
     * @return type Id
     */
    function getTypeId()
        external
        view
        override
        returns (uint256)
    {
        return typeId;
    }

    /**
     * @notice Get the complain period
     * @return complain period
     */
    function getComplainPeriod()
        external
        view
        override
        returns (uint256)
    {
        return complainPeriod;
    }

    /**
     * @notice Get the cancel or fault period
     * @return cancel or fault period
     */
    function getCancelFaultPeriod()
        external
        view
        override
        returns (uint256)
    {
        return cancelFaultPeriod;
    }
    
     /**
     * @notice Get the promise ID from a voucher set
     * @param _tokenIdSupply   ID of the voucher token
     * @return                  ID of the promise
     */
    function getPromiseIdFromSupplyId(uint256 _tokenIdSupply)
        external
        view
        override
        returns (bytes32) 
    {
        return ordersPromise[_tokenIdSupply];
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
        return tokensContract;
    }
}
