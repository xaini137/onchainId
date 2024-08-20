const express = require('express');
const { ethers } = require('ethers');
const cors = require("cors");
// Load environment variables from a .env file
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors()); 

// Set up your Ethereum provider and contract
const provider = new ethers.JsonRpcProvider(process.env.PROVIDER_URL);
const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

const factoryABI = [
    {
        "inputs": [
            { "internalType": "address", "name": "_wallet", "type": "address" },
            { "internalType": "string", "name": "_salt", "type": "string" }
        ],
        "name": "createIdentity",
        "outputs": [
            { "internalType": "address", "name": "", "type": "address" }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            { "internalType": "address", "name": "_wallet", "type": "address" }
        ],
        "name": "getIdentity",
        "outputs": [
            { "internalType": "address", "name": "identity", "type": "address" }
        ],
        "stateMutability": "view",
        "type": "function"
    }
];

const factoryAddress = process.env.FACTORY_ADDR;
const factoryContract = new ethers.Contract(factoryAddress, factoryABI, signer);


app.post('/get_identity', async (req, res) => {
    try {
        const { userAddress } = req.body;
console.log(userAddress , typeof userAddress );

        // Check if all required fields are provided
        if (!userAddress) {
            return res.status(400).json({ success: false, message: "Missing required fields: userAddress and salt are required." });
        }
        const identityCheck = await factoryContract.getIdentity(userAddress);
console.log(identityCheck);
if (identityCheck === '0x0000000000000000000000000000000000000000') {
    return res.status(200).json({ success: false });
}

// If identity exists and is not the zero address, return it
return res.status(200).json({ success: true, message: "Identity already exists.", identity: identityCheck });
} catch (error) {
        console.error('Error creating identity:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

app.post('/create', async (req, res) => {
    try {
        const { userAddress, salt } = req.body;
console.log(userAddress , typeof userAddress );

        // Check if all required fields are provided
        if (!userAddress || !salt) {
            return res.status(400).json({ success: false, message: "Missing required fields: userAddress and salt are required." });
        }

        // Check if identity already exists
        const identityCheck = await factoryContract.getIdentity(userAddress);
console.log(identityCheck);

        if (identityCheck === "0x0000000000000000000000000000000000000000") {
            // Create new identity
            const tx = await factoryContract.createIdentity(userAddress, salt);
            await tx.wait();
            const identity = await factoryContract.getIdentity(userAddress);
            return res.json({ success: true, identity });
        } else {
            // Identity already exists
            return res.status(400).json({ success: false, message: "Identity already exists.", identity: identityCheck });
        }
    } catch (error) {
        console.error('Error creating identity:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

app.get('/get', async (req, res) => {
    try {
        res.status(200).json({ success: true, message: 'Endpoint is working!' });
    } catch (error) {
        console.error('Error handling /get request:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
