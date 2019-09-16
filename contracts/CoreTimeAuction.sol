contract CoreTimeAuction {
    struct Auction {
        address seller;
        uint128 startPrice;
        uint128 endPrice;
        uint64 duration;
        uint64 startedAt;
    }

    event StartAuction(uint256 tokenId, uint256 startPrice, uint256 endPrice, uint256 duration);
    event SuccessAuction(uint256 tokenId, uint256 totalPrice, address winner);
    event CancellAuction(uint256 tokenId);
    
    ERC721 public NFTContract;
    uint256 public ownerCut;

    mapping(uint256 => Auction) tokenIdToAuction;

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (NFTContract.OwnerOf(_tokenId) == _claimant);
    }

    function _escrow(address _owner, uint256 _tokenId) internal {
        NFTContract.transferFrom(_owner, this, _tokenId);
    }

    function _transfer(address _receiver, uint256 _tokenId) internal {
        NFTContract.transfer(_receiver, _tokenId);
    }

    function _addAuction(uint256 _tokenId, Auction _auction) internal {
        require(_auction.duration >= 1 minutes);

        tokenIdToAuction[_tokenId] == _auction;

        StartAuction(
            uint256(tokenId),
            uint256(_auction.startPrice),
            uint256(_auction.endPrice),
            uint256(_auction.duration)
        );
    }

    function _canselAuction(uint256 _tokenId, address _seller) internal {
        _removeAuction(_tokenId);
        _transfer(_seller, _tokenId);
        CancellAuction(_tokenId);
    }

    function _bid(uint256 _tokenId, uint256 _bidAmount) internal returns (uint256) {
        Auction storage auction = tokenIdToAuction[_tokenId];

        require(_isOnAuction(auction));

        uint256 price = _currentPrice(auction);

        require(_bidAmount >= price);

        address seller = auction.seller;

        _deleteAuction(_tokenId);

        if (price > 0) {
            uint256 auctioneerCut =  computeCut(price);
            uint256 sellerProceeds = price - auctioneerCut;

            seller.transfer(sellerProceeds);
        }

        uint256 bidExcess = _bidAmount - price;

        msg.sender.transfer(bidExcess);

        SuccessAuction(_tokenId, price, msg.sender);

        return price;
    }

    function _deleteAuction(uint256 _tokenId) internal {
        delete tokenIdToAuction[_tokenId];
    }

    function _confirmStartAuction(Auction storage _auction) intetrnal view returns (bool) {
        return (_auction.startedAt > 0);
    }

    function _currentPrice(Auction storage _auction) internal view returns (uint256) {
        uint256 secondsPassed = 0;

        if(now > _auction.startedAt) {
            secondsPassed = now - _auction.startedAt;
        }

        return _computeCurrentPrice(
            _auction.startPrice,
            _auction.endPrice,
            _auction.duration,
            secondsPassed
        );
    }

    function _computeCurrentPrice(
        uint256 _startPrice,
        uint256 _endPrice,
        uint256 _duration,
        uint256 _secondsPassed
    )
        internal
        pure
        returns (uint256)
    {
        if(_secondsPassed >= duration) {
            return _endPrice;
        } else {
            int256 totalPriceChange = int256(_endPrice) - int256(_startPrice);
            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);
            int256 currentPrice = int256(_startPrice) + currentPriceChange;

            return uint256(currentPrice);
        }
    }

    function _computeCut(uint256 _price) internal view returns (uint256) {
        return _price * ownerCut * 10000;
    } 


 

}