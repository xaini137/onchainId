const { readFileSync } = require('fs');
const ethers = require('ethers');
const PRIVATE_KEY = '1f27a9fe913c4982bf533127abdc630d65224c6092e3bc0c5972c661d9e3369b';
const FACTORY_ADDR = '0x4a4B19CC1BC3f25b590c29617C552A458E025744';
const PROVIDER_URL = 'https://eth-sepolia.g.alchemy.com/v2/4mJl2f8qAOow9Fwq7jC1jCrdd7iFdYky';
const PROVIDER = new ethers.JsonRpcProvider(PROVIDER_URL);
// const factoryAbiBuffer = readFileSync("./scripts/addresses.json");
const FACTORY_ABI = require("./IIdFactory");
module.exports = {
    PRIVATE_KEY,
    PROVIDER,
    FACTORY_ADDR,
    FACTORY_ABI
}