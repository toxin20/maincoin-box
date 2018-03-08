var MainCoin = artifacts.require("MainCoin");

module.exports = function(deployer) {
  deployer.deploy(MainCoin);
};
