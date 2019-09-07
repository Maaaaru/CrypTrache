contract TracheBreeding is TracheOwnership {
    
    event Breeding(address owner, uint256 matherId, uint256 fatherId, uint256 cooldown);

    uint256 public breedingFee = 2 finney;

    uint256 public pregnanTraches;
    
    GeneInterface public geneInterface;

    function setMixGeneAddress(address _address) external onlyManager {
        GeneInterface candidateContract = GeneInterface(_address);

        require(candidateContract.isGeneScience());

        geneInterface = candidateContract;
    }

    function _readyToBreed(Trache _trac) internal view returns (bool) {
        return trac.MaitingWithId == 0 && (_trac.cooldownIndex <= uint64(block.number));
    }

    function _isFatherpermitted(uint256 _fatherId, uint256 _matherId) internal view returns (bool) {
        address matherOwner = tracheIndextoOwner[_matherId];
        address fatherOwner = tracheIndextoOwner[_fatherId];

        return (matherOwner == fatherOwner || fatherAllowedToAddress[_fatherId] == matherOwner);

    }

    function _triggerCooldown(Trache storage _trache) internal {
        _trache.cooldown = uint64((cooldowns[_trache.cooldownIndex] / secondsPerBlock) + block.number);

        if (_trache.cooldownIndex < 13) {
            _trache.cooldownindex  += 1;
        }
    }

    function approveFather(address _addr, uint256 _fatherId) external whenNotPaused {
        require(_confirmOwner(_addr, _fatherId));

        fatherAllowdedtoaddress[_fatherId] = _addr;
    }

    function setBirthFee(uint256 price) external onlyManager {
        BirthFee = price;
    }

    function _readyBirth(Trache _mather) private view returns (bool) {
        return (_mather.MaitingWithId != 0) && (_mather.cooldown <= uint64(block.number));
    }

    function readyToBreed(uint256 _tracheId) public view returns (bool) {
        require(_tracheId > 0);
        Trache storage tra = traches[_tracheId];
        return _readyToBreed(_tracheId);
    }

    function breedablePair(Trache storage _mather, uint256 _matherId, Trache storage _father, uint256 _fatherId) private view returns (bool) {
        if (_matherId == _fatherId ) {
            return false;
        }

        if (_mather.matherId == _fatherId || _mather.father == _fatherId) {
            return false;
        }

        if (_father.fatherId == _matherId || _father.fatherId == _matherId) {
            return false;
        }  

        if (_father.fatherId == 0 || _mather.matherId == 0) {
            return true;
        }

        if (_father.matherId == _mather.matherId || _father.matherId == _mather.fatherId) {
            return false;
        }

        if (_father.fatherId == _mather.matherId || _father.fatherId == _mather.matherId) {
            return false;
        }

        return true;
    }

    function canBreedViaAction(uint256 _matherId, uint256 _fatherId) internal view returns (bool) {
        Trache storage mather = traches[_matherId];
        Trache storage father = traches[_fatherId];
        return breedablePair(mather, _matherId, father, _fatherId);
    }

    function  canBreed(uint256 _matherId, uint256 _fatherId) external view returns (bool) {
        require(_matherId > 0);
        require(_fatherId > 0);
        Trache storage mather = traches[_matherId];
        Trache storage father = traches[_fatherId];
        return beedablePair(mather, _matherId, father, _fatherId) && _isFatherpermitted(_fatherId, _matherId);
    }

    function _breedWith(uint256 _matherId, uint256 _fatherId) internal {
        Trache storage mather = traches[_matherId];
        Trache storage father = traches[_fatherId];
        mather.MaitingWithId = uint32(_fatherId);

        _triggerCooldown(father);
        _triggerCooldown(mather);

        delete fatherAllowdedToaddress[_matherId];
        delete fatherAllowedToAddress[_fatherId];

        pregnanTraches ++;

        Breeding(tracheIndexToOwner[__matherId], _matherId, _fatherId, mather.cooldown);
    }

    function breedAuto(uint256 _matherId, uint256 _fatherId) external payable whenNotPaused {
        require(msg.value >= setBirthFee);
        require(_confirmOwner(msg.sender, _matherId));
        require(_isFatherpermitted(_fatherId, _matherId));
        
        Trache storage mather = traches[_matherId];

        require(readyToBreed(mather));

        Trache storage father = traches[_fatherId];

        require(readyToBreed(father));
        require(breedablePair(mather, _matherId, father, _fatherId));

        _breedWith(_matherId, fatherId);
    }

    function giveBirth(uint256 _matherId) external whenNotPaused returns (uint256) {
        Trache storage mather = traches[_matherId];

        require(mather.birthTime != 0);
        require(_readyBirth(mather);

        uint256 fatherId = mather.MaitingWithId;
        Trache storage father = traches[fatherId];

        uint16 parentGen = mather.generation;
        if(father.generation > mather.generation) {
            parentGen = father.generation;
        }

        uint256 childGenes = GeneInterface.mixGenes(mather.genes, father.genes, mather.cooldownEndBlock -1);

        address owner = tracheIndexToOwner[_matherId];
        uint256 tracheId = makeTrache(childGenes, _matherId, _fatherId, parentGen + 1, owner);

        delete mather.MaitingWithId;

        pregnanTraches --;

        msg.sender.send(breedingFee);

        return tracheId;
    }





    
}