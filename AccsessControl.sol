//this contract controls access control for CryptoWine

contract AccessControl {

    event ContractUpGrade(address newContract);

    address public ManagerAddress;
    
    bool public paused = false;

    modifier onlyManager() {
        require(msg.sender == ManagerAddress);
        _;
    }

    function setManager(address _newManager) external onlyManager {
        require(_newManager != address(0));

        ManagerAddress = _newManager;
    }

    
    //For emergency purposes,this bool type, when set to true, stops all transaction in the platform.
    modifier WhenNotPaused() {
        require(!paused);
        _;
    }

    modifier WhenPaused() {
        require(paused);
        _;
    }
    
    //bug or exploit is detecteed, need to limit damage. 
    function pause() external onlyManager whenNotPause {
        paused = true;
    }


    //if contract was upgrade, can't unpause
    function notpause() public onlyManager WhenPaused {
        paused = false;
    } 






}