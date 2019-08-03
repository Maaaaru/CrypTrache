contract ERC721MetaData{
    ///Given a token ID, returns a byte arry that is supposed to be converted into string.

    function getMetaData(uint256 _tokenId, string) public view returns (bytes32[4] buffer, uint256 count) {
        if (_tokenId == 1) {
            buffer[0] = "Hellow World! :D";
            count = 15;
        }else if (_tokenId == 2) {
            buffer[0] = "I would definitely choose a medi";
            buffer[1] = "um length string.";
            count = 49;
        }else if (_tokenId == 3) {
            buffer[0] = "Lorem ipsu dolor sit amet, mi e";
            buffer[1] = "st accumsan dapibus augue lorem,";
            buffer[2] = "tristique vestibulum id, libero";
            buffer[3] = "suscipt varius sapien aliquam.";
            count = 128;
        }
    } 
}
