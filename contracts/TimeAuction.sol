contract TimeAuction is Pausable, CoreTimeAuction {
    byte4 constant InterfaceSighnature_ERC721 = byte4(0x9a20483d);

    constructor(address _nftAddress, uint256 _cut) public {
        require(_cut <= 10000);
        ownerCut = _cut;

        ERC721 candidateContract = ERC721(_nftAddress);
        require(candidateContract.supportsInterface(InterfaceSighnature_ERC721));
        nonFungibleContract = candidateContract;
    }

    function withdrawBalance() external {
        address nftAddress = address(nonFungibleContract);

        require(msg.sender == owner || msg.sender == nftAddress);

        bool res = nftAddress.send(this.balance);
    }

    function createAuction(uint256 _tokenId, uint256 _startPrice, uint256 _endPrice, uint256 _duration address _seller) external whenNotPaused  {
        require(_startPrice == uint256(uint128(_startPrice)));
        require(_endPrice == uint256(uint128(_endPrice)));
        require(_duration == uint256(uint64(_duration)));
        require(_owns(msg.sender, _tokenId));
        
        _escrow(msg.sender, _tokenId);
        Auction memory auction = Auction(_seller, uint128(startPrice), uint128(endPrice), uint64(duration), uint64(now));
        _addAuction(_tokenId, auction);
    }

    function bid(uint256 _tokenId) external payable whenNotPaused {
        _bid(_tokenId, msg.sender);
        _transfer(msg.sender, _tokenId);
    }

    function cancelAuction(uint256 _tokenId) external {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_confirmStartAuction(auction)); 
        address seller = auction.seller;
        require(msg.sender == seller);
        _canselAuction(_tokenId, seller);
    } 

    function canselAuctionWhenPaused(uint256 _tokenId) external onlyOwner whenPaused {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_confirmStartAuction(auction));
        _canselAuction(_tokenId, auction.seller);
    }

    function getAuctionInformation(uint256 _tokenId) 
        external 
        view 
        returns
    (
        address seller,
        uint256 startPrice,
        uint256 endPrice,
        uint256 duration,
        uint256 startedAt 
    ) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_confirmStartAuction(auction));
        return(auction.seller,auction.startPrice,auction.endPrice,auction.duration,auction.startedAt);

    }

    function getCurrentPrice(uint256 _tokenId) external view returns (uint256) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_confirmStartAuction(auction));
        return _currentPrice(auction);
    }


}