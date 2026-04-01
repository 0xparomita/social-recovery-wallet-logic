const hre = require("hardhat");

async function main() {
  const [owner, g1, g2, g3] = await hre.ethers.getSigners();
  const guardians = [g1.address, g2.address, g3.address];
  const threshold = 2;

  const Wallet = await hre.ethers.getContractFactory("SocialRecoveryWallet");
  const wallet = await Wallet.deploy(owner.address, guardians, threshold);

  await wallet.waitForDeployment();
  console.log("Social Recovery Wallet deployed to:", await wallet.getAddress());
  console.log("Guardians set:", guardians.join(", "));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
