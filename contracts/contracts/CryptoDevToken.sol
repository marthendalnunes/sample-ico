// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './ICryptoDevs.sol';

contract CryptoDev is ERC20, Ownable {
  uint256 public constant tokenPrice = 0.001 ether;
  uint256 public constant DECIMALS = 10**18;
  uint256 public constant tokensPerNFT = 10 * DECIMALS;
  uint256 public constant maxSupply = 10000 * DECIMALS;

  ICryptoDevs CryptoDevsNFT;

  mapping(uint256 => bool) public tokenIdsClaimed;

  constructor(address _cryptoDevsContract) ERC20('Crypto Dev Token', 'CD') {
    CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
  }

  function mint(uint256 amount) public payable {
    uint256 _requiredAmount = tokenPrice * amount;
    require(msg.value >= _requiredAmount, 'Not enough funds to buy the tokens');
    uint256 amountWithDecimals = amount * DECIMALS;
    require(
      (totalSupply() + amountWithDecimals) <= maxSupply,
      'Maximum token supply reached'
    );
    _mint(msg.sender, amountWithDecimals);
  }

  function _claim() public {
    uint256 balance = CryptoDevsNFT.balanceOf(msg.sender);
    require(balance > 0, 'Address has no CryptoDevs NFT');
    uint256 amount;
    for (uint256 i = 0; i < balance; i++) {
      uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(msg.sender, i);
      // if the tokenId has not been claimed, increase the amount
      if (!tokenIdsClaimed[tokenId]) {
        amount += 1;
        tokenIdsClaimed[tokenId] = true;
      }
    }
    require(
      (totalSupply() + amount * tokensPerNFT) <= maxSupply,
      'Max supply reached'
    );
    _mint(msg.sender, amount * tokensPerNFT);
  }

  function withdraw() public onlyOwner {
    address _owner = owner();
    uint256 amount = address(this).balance;
    (bool sent, ) = _owner.call{value: amount}('');
    require(sent, 'Failed to send Ether');
  }

  receive() external payable {}

  fallback() external payable {}
}
