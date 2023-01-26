const main = async () => {
    const UHURUNFT = await ethers.getContractFactory("NFTMint");

    const [deployer] = await ethers.getSigners();
    const NFTInstance = await UHURUNFT.deploy();

    console.log(`Contract Deployed by Account %s`, deployer.address);
    console.log(`Contract Address`, NFTInstance.address);
};

main()
    .then(() => process.exit(0))
    .catch((error) => console.log(error));