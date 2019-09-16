contract Pausable is Owner {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() onlyOwner whenNotPaused returns (bool) {
        paused = true;
        Pause();
        return true;
    } 

    function unPause() onlyOwner whenPaused returns (bool) {
        paused = false;
        Unpause();
        return false;
    }
}