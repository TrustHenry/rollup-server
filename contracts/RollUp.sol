/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title A roll-up contract that stores block headers generated by roll-up rules in the blockchain
/// @author BOSagora Foundation
/// @notice Stored block headers sequentially
contract RollUp is Ownable {
    struct BlockHeader {
        uint64 height;
        bytes32 curBlock;
        bytes32 prevBlock;
        bytes32 merkleRoot;
        uint64 timestamp;
        string CID;
    }

    struct BlockHeight {
        uint64 height;
        bool exists;
    }

    /// @dev The most recent block height
    uint64 private lastHeight;

    /// @dev Array containing block headers
    BlockHeader[] internal blockArray;

    /// @dev Block map with block hash as key
    mapping(bytes32 => BlockHeight) internal blockMap;

    event AddedBlock(uint64 _height);

    constructor() {
        lastHeight = type(uint64).max;
    }

    /// @notice Add newly created block header
    /// @param _height Height of new block
    /// @param _curBlock Hash of this block
    /// @param _prevBlock Hash of previous block
    /// @param _merkleRoot MerkleRoot hash of this block
    /// @param _timestamp Timestamp for this block
    /// @param _cid CID of IPFS
    function add(
        uint64 _height,
        bytes32 _curBlock,
        bytes32 _prevBlock,
        bytes32 _merkleRoot,
        uint64 _timestamp,
        string memory _cid
    ) public onlyOwner {
        require(
            (lastHeight == type(uint64).max && _height == 0) || lastHeight + 1 == _height,
            "E001: Height is incorrect."
        );

        if (_height != 0 && _prevBlock != (blockArray[_height - 1]).curBlock)
            revert("E002: The previous block hash is not valid.");

        BlockHeader memory blockHeader = BlockHeader({
            height: _height,
            curBlock: _curBlock,
            prevBlock: _prevBlock,
            merkleRoot: _merkleRoot,
            timestamp: _timestamp,
            CID: _cid
        });
        blockArray.push(blockHeader);

        BlockHeight memory blockHeight = BlockHeight({ height: _height, exists: true });
        blockMap[_curBlock] = blockHeight;
        lastHeight = _height;
        emit AddedBlock(_height);
    }

    /// @notice Get a blockheader by block height
    /// @param _height Height of the block header
    /// @return Block header of the height
    function getByHeight(uint64 _height)
        public
        view
        returns (
            uint64,
            bytes32,
            bytes32,
            bytes32,
            uint64,
            string memory
        )
    {
        require(_height <= lastHeight, "E003: Must be not more than last height.");
        BlockHeader memory blockHeader = blockArray[_height];
        return (
            blockHeader.height,
            blockHeader.curBlock,
            blockHeader.prevBlock,
            blockHeader.merkleRoot,
            blockHeader.timestamp,
            blockHeader.CID
        );
    }

    /// @notice Get a blockheader by block hash
    /// @param _blockHash Block hash of the block
    /// @return Block header of the block hash
    function getByHash(bytes32 _blockHash)
        public
        view
        returns (
            uint64,
            bytes32,
            bytes32,
            bytes32,
            uint64,
            string memory
        )
    {
        require(_blockHash.length == 32, "E004: The hash length is not valid.");
        require((blockMap[_blockHash]).exists, "E005: No corresponding block hash key value.");

        uint64 height = blockMap[_blockHash].height;
        BlockHeader memory blockHeader = blockArray[height];

        return (
            blockHeader.height,
            blockHeader.curBlock,
            blockHeader.prevBlock,
            blockHeader.merkleRoot,
            blockHeader.timestamp,
            blockHeader.CID
        );
    }

    /// @notice Get a last block height
    /// @return The most recent block height
    function getLastHeight() public view returns (uint64) {
        return uint64(lastHeight);
    }

    /// @notice Get the block array length
    /// @return The block array length
    function size() public view returns (uint64) {
        return uint64(blockArray.length);
    }
}
