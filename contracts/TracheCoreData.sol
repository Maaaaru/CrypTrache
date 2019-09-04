contract TracheCoreData is AccsessControl {

    event Birth(address owner, uint256 tracheId, uint256 matherId, uint256 fatherId uint256 genes);
    event Transfer(address from, address to, tokenId);


    struct Trache {
        //遺伝子
        uint256 genes;
        
        //生成せれたTracheのブロックタイムスタンプ
        uint64 birthTime;

        //母方のtokenId
        uint32 matherId;

        //父方のtokenId
        uint32 fatherId;

        //Tracheの番号　gen0のTracehは0
        uint16 generation;

        //ブリーディング成功後から次回のブリーディングまでどれくらいか
        uint64 cooldown;

        //cooldownarrayのindex
        uint16 cooldownIndex;

        //交配中の父方のId 交配していない場合は0
        uint32 MatingWithId;
    }

    uint32[14] public cooldowns = [
        uint32(1 minutes),
        uint32(2 minutes),
        uint32(5 minutes),
        uint32(10 minutes),
        uint32(30 minutes),
        uint32(1 hours),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(16 hours),
        uint32(1 days),
        uint32(2 days),
        uint32(4 days),
        uint32(7 days)
    ];

    uint256 public secondPerBlock = 15;

    Trache[] traches;

    mapping (uint256 => address) public tracheIndexToOwner;

    mapping (address => uint256) ownershipTokenCount;

    mapping (uint256 => address) public tracheIndexToApproved;

    mapping (uint256 => address) public fatherAllowedToAddress;

    saleClockAuction public saleAuction;

    SiringClockAuction public siringAuction;

    function transfer(address _from, address _to, uint256 _tokenId) internal {
        ownershipTokenCount[_to]++;
        tracheIndexToOwner[_tokenId] = _to;
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            delete fatherAllowedToAddress[_tokenId];
            delete tracheIndexToApproved[_tokenId];
        }

        Transfer(_from, _to, _tokenId);

    }

    function makeTrache(
        uint256 _genes,
        uint256 _matherId,
        uint256 _fatherId,
        uint256 _generation,
        address _owner
    )

        internal
        returns (uint)

    {
        require(_matherId == uint256(uint32(_matherId)));
        require(_fatherId == uint256(uint32(_fatherId)));
        require(_generation == uint256(uint16(_generation)));

        uint16 cooldownIndex = uint16(_generation / 2);
        
        if (cooldownIndex > 13 ){
            cooldownIndex = 13;
        }

        Trache memory _traches = Trache({
            genes: _genes,
            birthTime: uint64(now),
            matherId: _matherId,
            fatherId: _fatherId,
            cooldwon: 0,
            cooldownIndex: cooldownIndex,
            generation: uint256(_generation) 
        });

        uint256 newTracheId = traches.push(_traches) - 1;

        require(newTracheId == uint256(uint32(newTracheId)));

        Birth(
            _owner,
            newTracheId,
            uint256(_traches.matherId),
            uint256(_traches.fatherId),
            _traches.genes
        )

        transfer(0, _owner, newTracheId);

        returns newTracheId;
    }

    function setSecondsPerBlock(uint256 newSeconds) external onlyManager {
        require(newSeconds < cooldowns[0])
        secondPerBlock = newSeconds;
    }










}