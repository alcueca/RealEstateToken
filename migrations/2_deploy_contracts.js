const RealEstateTokenFactory = artifacts.require('./RealEstateTokenFactory.sol');

module.exports = async (deployer) => {
    await deployer.deploy(RealEstateTokenFactory);
    let instance = await RealEstateTokenFactory.deployed();
    await instance.createRealEstateToken(1000);
};
