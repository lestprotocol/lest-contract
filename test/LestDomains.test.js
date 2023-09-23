// test/LestDomains.test.js

const { ethers, waffle } = require('hardhat');
const { expect } = require('chai');
const { parseEther } = ethers.utils;

const TLD = 'mnt';

describe('LestDomains', function () {
  let LestDomains;
  let contract;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    LestDomains = await ethers.getContractFactory('LestDomains');
    contract = await LestDomains.deploy(TLD);
    await contract.deployed();
  });

  it('Should register a valid domain', async function () {
    const name = 'tobi';
    const price = parseEther('1.5'); // 1.5 ETH
    await contract.connect(addr1).register(name, TLD, 31536000, { value: price });
    const domain = await contract.getDomain(name);
    expect(domain.owner).to.equal(addr1.address);
    expect(domain.name).to.equal(`${name}.${TLD}`);
    expect(domain.expiry).to.be.above(0);
  });

  it('Should not register an invalid domain', async function () {
    const invalidName = 'inv@lid';
    const price = parseEther('1.5'); // 1.5 ETH
    await expect(contract.connect(addr1).register(invalidName, TLD, 31536000, { value: price })).to.be.revertedWith(
      'InvalidName'
    );
  });

  it('Should transfer domain ownership', async function () {
    const name = 'mydomain';
    const price = parseEther('1.5'); // 1.5 ETH
    await contract.connect(addr1).register(name, TLD, 31536000, { value: price });
    await contract.connect(addr1).transferDomain(name, addr2.address);
    const domain = await contract.getDomain(name);
    expect(domain.owner).to.equal(addr2.address);
  });
});
