// var ConvertLib = artifacts.require("./ConvertLib.sol");
var Aggregator = artifacts.require("./Aggregator.sol");
var accts = [web3.eth.accounts[0],web3.eth.accounts[1],web3.eth.accounts[2]]
console.log(accts)

module.exports = function(deployer) {
  deployer.deploy(Aggregator, accts);
};
