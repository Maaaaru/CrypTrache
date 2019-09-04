contract TracheOwnership is TracheCoreData, ERC721 {

    string public constant name = "CrypTrache";
    string public constant symbol = "CT";

    ERC721MetaData public erc721Metadata;

    bytes4 constant InterfaceSignature_ERC165 = bytes4(keccak256('supportsInterface(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 = 
        bytes4(keccak256('name')) ^
        bytes4(keccak256('symbol'))^
        bytes4(keccak256('totalSupply'))^
        bytes4(keccak256('balanceOf'))^
        bytes4(keccak256('ownerOf(uint256)'))^
        bytes4(keccak256('approve(address, uint256)'))^
        bytes4(keccak256('transfer(address, uint256)'))^
        bytes4(keccak256('transferFrom(address, address, uint256)'))^
        bytes4(keccak256('tokensOfOwner(address)'))^
        bytes4(keccak256('tokenMetadata(uint256, string)'));

    function supportsInterface(bytes4 _interfaceId) external view returns (bool) {
        returns _interfaceId ==InterfaceSignature_ERC165 || _interfaceId == InterfaceSignature_ERC721;

    }

    function setMetaDataAddress(address _contractAddress) public onlyManager {
        erc721Metadata = ERC721MetaData(_contractAddress);
    }

    function _confirmOwner(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return tracheIndexToOwner[_tokenId] == _claimant;
    } 

    function _confirmApproved(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return tracheIndexToApproved[_tokenId] == _claimant;
    }
    
    function _approve(address _approvedOwner, uint256 _tokenId) internal {
        tracheIndexToApproved[_tokenId] = _approvedOwner;
    }

    function blanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    function transfer(address _to, uint256 _tokenId) external WhenNotPaused {
        require(_to != address(0));
        require(_to != address(this));
        require(_to != address(saleAuction));
        require(_to != address(siringAuction));
        require(_confirmOwner(msg.sender,_tokenId));

        _transfer(msg.sender, _to, _tokenId);
    }

    function approve(address _to, uint256 _tokenId) exteranl WhenNotPaused {
        require(_confirmOwner(msg.sender, _tokenId));

        _approve(_to, _tokenId);

        Approval(msg.sender, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external WhenNotPaused {
        require(_to != address(0));
        require(_to != address(this));
        require(_confirmApproved(msg.sender, _tokenId));
        require(_confirmOwner(_from, _tokenId));

        _transfer(_from, _to, _tokenId);
    }

    function totalSupply() public view returns(uint) {
        return traches.length - 1;
    }

    function ownerOf(uint256 _tokenId) external view returns (address owner) {
        owner = tracheIndexToOwner[_tokenId];
        require(owner != address(0));
    }

    function tokensOfOwner(address _owner) external view returns (uint256[] tokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            return new uint256[](0);
        }else {
            uint256[] memory variable = new uint256[](tokenCount);
            uint256 totalTraches = totalSupply();
            uint256 variableIndex = 0;
            uint256 tracheId;

            for (tracheId = 1; tracheId <= totalTraches; tracheId++) {
                if (tracheIndexToOwner[tracheId] == _owner) {
                    variable[variableIndex] = tracheId;
                    variableIndex++;
                }
            }

            return variable;


        }
    }

    function _memcpy(uint _dest, uint src, uint _len) private view {
        for(; _len >= 32; _len -= 32) {
            assembly {
                mstore(_dest, mload(_src))
            }

            _dest += 32;
            _src -= 32;
        }

        uint256 mask = 256 ** (32 - _len) -1;
        assembly {
            let srcpart := and(mload(_src), not(mask))
            let destpart := and(mload(_dest), mask)
            mstore(_dest, or(destpart,srcpart))


        }
    }

    function _toString(bytes32[4] _rawBytes, uint256 _stringLength) private view returns (string) {
        var outputString = new stirng(_stringLength);
        uint256 outputPtr;
        uint256 bytesPtr;

        assembly {
            outputPtr := add(outputString, 32)
            bytesPtr := _rawBytes
        }

        _memcpy(outputPtr, bytesPtr, _stringLength);

        return outputString;
    }

    function tokenMetaData(uint256 _tokenId, string _preferredTrasport) external view returns(string infoUrl){
        require(erc721Metadata != address(0));
        bytes32[4] memory buffer;
        uint256 count;
        (buffer, count) = erc721Metadata.getMetaData(_tokenId, _preferredTrasport);

        return _toString(buffer, count);
    }










}