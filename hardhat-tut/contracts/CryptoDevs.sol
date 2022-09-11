// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable {

     string _baseTokenURI;

       // max number of CryptoDevs
      uint256 public maxTokenIds = 20;

  //  _price is the price of one Crypto Dev NFT
      uint256 public _price = 0.01 ether;

      // total number of tokenIds minted
      uint256 public tokenIds;

      // _paused is used to pause the contract in case of an emergency
      bool public _paused;

      // Whitelist contract instance
      IWhitelist whitelist;

 // boolean to keep track of whether presale started or not
      bool public presaleStarted;

     

      // timestamp for when presale would end
      uint256 public presaleEnded;

       modifier onlyWhenNotPaused {
          require(!_paused, "Contract currently paused");
          _;
      }

      constructor (string memory baseURI, address whitelistContract) ERC721("Crypto Devs", "CD") {
          _baseTokenURI = baseURI;
          whitelist = IWhitelist(whitelistContract);
      }

          function startPresale() public onlyOwner {
          presaleStarted = true;
          // Set presaleEnded time as current timestamp + 5 minutes
          // Solidity has cool syntax for timestamps (seconds, minutes, hours, days, years)
          presaleEnded = block.timestamp + 5 minutes;
      }

       function presaleMint() public payable onlyWhenNotPaused {
          require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running");
          require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
          require(tokenIds < maxTokenIds, "Exceeded maximum Crypto Devs supply");
          require(msg.value >= _price, "Ether sent is not correct");
          tokenIds += 1;
          //_safeMint is a safer version of the _mint function as it ensures that
          // if the address being minted to is a contract, then it knows how to deal with ERC721 tokens
          // If the address being minted to is not a contract, it works the same way as _mint
          _safeMint(msg.sender, tokenIds);
      }

         function mint() public payable onlyWhenNotPaused {
          require(presaleStarted && block.timestamp >=  presaleEnded, "Presale has not ended yet");
          require(tokenIds < maxTokenIds, "Exceed maximum Crypto Devs supply");
          require(msg.value >= _price, "Ether sent is not correct");
          tokenIds += 1;
          _safeMint(msg.sender, tokenIds);
      }

 function _baseURI() internal view virtual override returns (string memory) {
          return _baseTokenURI;
      }

  function setPaused(bool val) public onlyOwner {
          _paused = val;
      }


 function withdraw() public onlyOwner  {
          address _owner = owner();
          uint256 amount = address(this).balance;
          (bool sent, ) =  _owner.call{value: amount}("");
          require(sent, "Failed to send Ether");
      }


// Function to receive Ether. msg.data must be empty
      receive() external payable {}

      // Fallback function is called when msg.data is not empty
      fallback() external payable {}
       
}
