const TicketMachine = artifacts.require("TicketMachine");

module.exports = function (deployer) {
  deployer.deploy(TicketMachine);
};
