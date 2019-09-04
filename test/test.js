var Metacoin = artifacts.require("./Metacoin.sol");

contract('Metacoin', function(accounts)) {
    it("should put 10000 Metacoin in the first account", function() {
        return Metacoin.deployed().then(funtion(instance)) {
            return instance.getBalance.call(accounts[0]);
        }).then(function(balance)) {
            
        }
    })
}