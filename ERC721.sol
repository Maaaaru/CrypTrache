contract ERC721 {
    //function
    function totalSupply() public view returns (uint256 total);
    function balancesOf(address _owner) public view returns (uint256 balance);
    function ownerof(uint256 _tokenId) external view returns(address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferfrom(address _from, address _to, uint tokenId) external;

    //Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    function supportsInterface(bytes4 _interfaceID) external view returns(bool);  
}
