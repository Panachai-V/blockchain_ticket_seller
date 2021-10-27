const TicketGen = artifacts.require("TicketCtrl");

module.exports = function (deployer) {
  deployer.deploy(TicketGen);
};
