const main = async () => {
    const [owner, randomPerson] = await hre.ethers.getSigners();
    const domainContractFactory = await hre.ethers.getContractFactory('LestDomains');
    const domainContract = await domainContractFactory.deploy(["zeta"]);
    await domainContract.deployed();
  
    console.log("Contract deployed to:", domainContract.address);
    console.log("Contract deployed by:", owner.address);
  
    // We're passing in a second variable - value. This is the moneyyyyyyyyyy
    let txn = await domainContract.register("tobi", "zeta",  {value: hre.ethers.utils.parseEther('0.4')});
    await txn.wait();
  
    const address = await domainContract.getAddress("tobi");
    console.log("Owner of domain tobi:", address);
    const domain = await domainContract.getDomain("tobi","zeta");
    console.log("Owner of domain tobi:", domain);
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