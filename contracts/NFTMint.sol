// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMint is ERC721Enumerable, ERC2981, Ownable {
    // Using Strings library for uint256
    using Strings for uint256;

    // Declare private variable for default royalty info
    RoyaltyInfo private _defaultRoyaltyInfo;

    // Declare private mapping for token royalty info
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    // Declare public variable for mint price
    uint256 public mintPrice = 0.08 ether;

    // Declare public variable for whitelist price
    uint256 public whitelistPrice = 0.04 ether;

    // Declare public variable for max supply
    uint256 public maxSupply;

    // Declare private variable for current base URI
    string private currentBaseURI;

    // Declare public variable for max mint amount
    uint256 public maxMintAmount = 1;

    // Declare public variable to check if minting is enabled
    bool public isMintEnabled;

    // Declare public variable to check if NFTs are revealed
    bool public revealNFT;

    // Declare private variable for contract URI
    string private contractURI;

    // Declare private variable for base extension
    string public baseExtension = ".json";
    mapping(address => uint256) public mintedWallets;
    mapping(address => bool) public whitelisted;

    // The constructor function sets the initial values for the contract and calls the ERC721 constructor to create the token with name "UHURUTEST MINT" and symbol "UHURUTEST"
    constructor(
        string memory _initBaseURI
    ) payable ERC721("UHURUTEST MINT", "UHURUTEST") {
        maxSupply = 2;
        setBaseURI(_initBaseURI);
    }

    // _baseURI() function is used to set the base URI for the smart contract. This is where the contract's information will be stored on the blockchain. This function is usually called during the contract's deployment and should only be called once
    function _baseURI() internal view virtual override returns (string memory) {
        return currentBaseURI;
    }

    // The setMintCost function allows the contract owner to set the cost of minting new tokens
    function setMintCost(uint256 _newCost) public onlyOwner {
        mintPrice = _newCost;
    }

    // The setWhiteListCost function allows the contract owner to set the cost of whitelisting users
    function setWhiteListCost(uint256 _newCost) public onlyOwner {
        whitelistPrice = _newCost;
    }

    // The setBaseURI function allows the contract owner to set the base URI for the token metadata
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        currentBaseURI = _newBaseURI;
    }

    // The setBaseExtension function allows the contract owner to set the file extension for the token metadata
    function setBaseExtension(
        string memory _newBaseExtension
    ) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    // Function to toggle the state of minting on the contract
    function toggleIsMintEnabled() external onlyOwner {
        isMintEnabled = !isMintEnabled;
    }

    // Function to set the maximum supply of tokens that can be minted
    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        maxSupply = _maxSupply;
    }

    // Function to set the maximum amount of tokens that can be minted by a single wallet
    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    // Function to check if a specific interface is supported by the contract
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC2981, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // Function to toggle whether or not the tokenURI function reveals the tokenId in the URI
    function setRevealNFT(bool reveal) public onlyOwner {
        revealNFT = reveal;
    }

    // Function to generate a unique token URI for a specific tokenId
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory BaseURI = _baseURI();

        if (revealNFT) {
            return
                bytes(currentBaseURI).length > 0
                    ? string(
                        abi.encodePacked(
                            BaseURI,
                            tokenId.toString(),
                            baseExtension
                        )
                    )
                    : "";
        } else {
            return
                bytes(currentBaseURI).length > 0
                    ? string(abi.encodePacked(BaseURI, "hidden.json"))
                    : "";
        }
    }

    function walletOfOwner(
        address _owner
    ) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    // Function to set contract URI
    function setContractURI(string calldata _contractURI) public onlyOwner {
        contractURI = _contractURI;
    }

    // mintSupply function allows the owner or whitelisted users to mint a certain amount of tokens, as long as the max supply has not been reached and minting is enabled
    // msg.sender must also provide the correct value according to the mintPrice or whitelistPrice set
    // Additionally, it keeps track of the total amount of tokens minted by a specific address and ensures that it does not exceed the maxMintAmount set
    // _safeMint function is called to mint the tokens
    function mintSupply(uint256 _mintAmount) external payable {
        require(isMintEnabled, "Minting Not Enabled");
        require(maxSupply > totalSupply(), "Sold Out");

        uint256 tokenId = totalSupply();

        if (msg.sender != owner()) {
            require(
                (mintedWallets[msg.sender] + _mintAmount) < maxMintAmount,
                "Exceeds Max Per Wallet"
            );
            if (whitelisted[msg.sender] != true) {
                require(
                    msg.value == mintPrice * _mintAmount,
                    "Wrong Value Entered"
                );
            } else {
                require(
                    msg.value == whitelistPrice * _mintAmount,
                    "Wrong Value Entered"
                );
            }
        }

        for (uint256 i = 1; i <= _mintAmount; i++) {
            mintedWallets[msg.sender]++;
            _safeMint(msg.sender, tokenId + i);
        }
    }

    // whitelistUser() function allows the owner to whitelist a user. A whitelisted user can mint tokens at a different price than a non-whitelisted user
    function whitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = true;
    }

    // removeWhitelistUser() function allows the owner to remove a whitelisted user
    function removeWhitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = false;
    }

    // withdraw() function allows the owner to withdraw the contract's balance.
    function withdraw() public payable onlyOwner {
        require(address(this).balance > 0, "Balance is 0");
        payable(owner()).transfer(address(this).balance);
    }

    // resetDefaultRoyalty() function allows the owner to reset the default royalty information for the contract
    function resetDefaultRoyalty(
        address receiver,
        uint96 feeNumerator
    ) public onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    //setTokenRokyalty function is used to set the token royalty for the creator of the token.
    function setTokenRokyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) public onlyOwner {
        _setTokenRoyalty(tokenId, receiver, feeNumerator);
    }

    // Function to reset royalties for a specific token
    function resetTokenRoyalty(uint256 tokenId) public onlyOwner {
        _resetTokenRoyalty(tokenId);
    }
}
