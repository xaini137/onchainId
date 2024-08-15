// const ethers = require('ethers'); // v5._._
// const cron = require("node-cron");
// const {
//     PRIVATE_KEY,
//     PROVIDER,
//     Contract,
//     FACTORY_ADDR,
//     FACTORY_ABI
// } = require('./essentials')

// const { Wallet, Contract } = ethers;

// const signer = new Wallet(PRIVATE_KEY, PROVIDER);

// const factory = new Contract(FACTORY_ADDR, FACTORY_ABI, signer);
// const userAddress = ''; // get from input field
// const salt = undefined; // if told, then will look into 

// const tx = await factory.createIdentity(userAddress, salt ?? userAddress);
// await tx.wait();

// const userIdentityAddress = await factory.getIdentity(userAddress); // store this DB for respective user

// console.log(`Deployed a new identity at ${userIdentityAddress} as a proxy using factory ${FACTORY_ADDR} . tx: ${tx.hash}`);


const ethers = require('ethers');  
const cron = require('node-cron');
const {
    PRIVATE_KEY,
    PROVIDER,
    FACTORY_ADDR,
    FACTORY_ABI
} = require('./essentials');

const { Wallet, Contract } = ethers;

const signer = new Wallet(PRIVATE_KEY, PROVIDER);
const factory = new Contract(FACTORY_ADDR, FACTORY_ABI, signer);

async function createIdentity(userAddress, salt) {
    try {
        // const tx = await factory.createIdentity(userAddress, salt ?? userAddress);
        // await tx.wait();
        // console.log(`Deployed a new identity at ${userIdentityAddress} as a proxy using factory ${FACTORY_ADDR}. tx: ${tx.hash}`);
        const userIdentityAddress = await factory.getIdentity(userAddress);                    
       console.log("here",userIdentityAddress);
       
        // console.log(`Deployed a new identity at ${userIdentityAddress} as a proxy using factory ${FACTORY_ADDR}. tx: ${tx.hash}`);
    } catch (error) {
        console.error('Error creating identity:', error);
    }
}

// cron.schedule('*/5 * * * * *', () => {
    const userAddress = '0x9f11bcb53e39d6d130ba51a8c8a786a3a9395add'; 
    const salt = undefined; 

    createIdentity(userAddress, salt);
// });

