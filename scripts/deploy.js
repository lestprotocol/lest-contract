const main = async () => {
  const domainContractFactory = await hre.ethers.getContractFactory('LestDomains');
  const domainContract = await domainContractFactory.deploy("hela");
  await domainContract.deployed();

  console.log("Contract deployed to:", domainContract.address);

  const balance = await hre.ethers.provider.getBalance(domainContract.address);
  console.log("Contract balance:", hre.ethers.utils.formatEther(balance));
}

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();