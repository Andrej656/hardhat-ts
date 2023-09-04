// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SoulboundToken is ERC721Enumerable, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    string private _name = "SoulboundToken";
    string private _symbol = "SBT";

    struct TokenInfo {
        address owner;
        bool isSoulbound;
        uint256 creationTime;
    }

    mapping(uint256 => TokenInfo) private _tokenInfo;

    event TokenSoulbound(uint256 indexed tokenId, address indexed soul);
    event TokenTransferred(uint256 indexed tokenId, address indexed from, address indexed to);

    constructor() ERC721(_name, _symbol) {}

    function mintSoulboundToken(address soul) public onlyOwner {
        uint256 tokenId = totalSupply() + 1;
        _mint(msg.sender, tokenId);
        _tokenInfo[tokenId] = TokenInfo({
            owner: msg.sender,
            isSoulbound: true,
            creationTime: block.timestamp
        });
        emit TokenSoulbound(tokenId, soul);
    }

    function isSoulbound(uint256 tokenId) public view returns (bool) {
        return _tokenInfo[tokenId].isSoulbound;
    }

    function getTokenOwner(uint256 tokenId) public view returns (address) {
        return _tokenInfo[tokenId].owner;
    }

    function getTokenCreationTime(uint256 tokenId) public view returns (uint256) {
        return _tokenInfo[tokenId].creationTime;
    }

    function transferToken(uint256 tokenId, address to) public nonReentrant {
        require(_exists(tokenId), "Token does not exist");
        require(_isApprovedOrOwner(msg.sender, tokenId), "Sender is not the owner");
        require(!_tokenInfo[tokenId].isSoulbound, "Soulbound tokens cannot be transferred");

        _transfer(msg.sender, to, tokenId);
        _tokenInfo[tokenId].owner = to;
        emit TokenTransferred(tokenId, msg.sender, to);
    }

    function burnToken(uint256 tokenId) public onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        _burn(tokenId);
        delete _tokenInfo[tokenId];
    }
}
