const MusicToken = artifacts.require("Escrow");

module.exports = function(deployer) {
  deployer.deploy(Escrow, "0x3066d22b7cbD9ad5A4C9D577412904Ca81195433", "0xb3406BB1Bc2C21C56c6807856405018Ee55fed0e");
}
