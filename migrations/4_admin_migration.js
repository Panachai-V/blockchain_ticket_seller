const AdminCheck= artifacts.require("AdminCheck");

module.exports = function (deployer) {
  deployer.deploy(AdminCheck);
};
