import { database } from '../../firebase';
import { ref, set, push, onValue } from "firebase/database";
import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import '../css/ClaimTopicsRegistry.css'; // Importing the CSS file for styling

const ClaimTopicsRegistry = () => {
    // const [contractAddress, setContractAddress] = useState('');
    const [claimTopic, setClaimTopic] = useState('');
    const [selectedTopicKey, setSelectedTopicKey] = useState(''); // New state for selected topic key
    const [message, setMessage] = useState('');
    const [metaMaskAddress, setMetaMaskAddress] = useState('');
    const [isMetaMaskConnected, setIsMetaMaskConnected] = useState(false);
    const [topics, setTopics] = useState([]);
    const [networkName, setNetworkName] = useState('');

    const celo = {
        celoChainId: '0xaef3',
        celoName: "Celo Alfajores Testnet"
    }

    const handleMetaMaskConnect = async () => {
        if (!window.ethereum) {
            alert('MetaMask is not installed. Please install it to use this feature.');
            return;
        }
        try {
            const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
            const account = accounts[0];
            setMetaMaskAddress(account);
            const provider = new ethers.BrowserProvider(window.ethereum);
            const network = await provider.getNetwork();
            setNetworkName(celo.celoName);

            if (network.chainId !== parseInt(celo.celoChainId, 16)) {
                try {
                    await window.ethereum.request({
                        method: 'wallet_switchEthereumChain',
                        params: [{ chainId: celo.celoChainId }],
                    });
                } catch (switchError) {
                    if (switchError.code === 4902) {
                        try {
                            await window.ethereum.request({
                                method: 'wallet_addEthereumChain',
                                params: [
                                    {
                                        chainId: celo.celoChainId,
                                        chainName: celo.celoName,
                                        nativeCurrency: {
                                            name: 'Celo',
                                            symbol: 'CELO',
                                            decimals: 18,
                                        },
                                        rpcUrls: ['https://alfajores-forno.celo-testnet.org'],
                                        blockExplorerUrls: ['https://alfajores.celoscan.io/'],
                                    },
                                ],
                            });
                            setMessage('Celo network added and switched successfully.');
                        } catch (addError) {
                            console.error('Failed to add the Celo network:', addError);
                            setMessage(`Error: ${addError.message}`);
                        }
                    } else {
                        console.error('Failed to switch network:', switchError);
                        setMessage(`Error: ${switchError.message}`);
                    }
                }
            } else {
                setMessage('Connected to the Celo network.');
            }

            setIsMetaMaskConnected(true);
        } catch (error) {
            console.error("MetaMask connection error:", error);
            alert('Failed to connect MetaMask: ' + error.message);
        }
    };

    useEffect(() => {
        handleMetaMaskConnect();
    }, []);

    useEffect(() => {
        const topicsRef = ref(database, 'topics');
        onValue(topicsRef, (snapshot) => {
            const data = snapshot.val();
            if (data) {
                setTopics(Object.entries(data).map(([key, value]) => ({ key, value })));
            }
        });
    }, []);

    const addClaimTopic = async () => {
        try {
            if (!window.ethereum) {
                throw new Error('MetaMask is not installed');
            }
    
            if (!selectedTopicKey) {
                throw new Error('Please select a topic.');
            }
    
            // Fetch the hex code from Firebase
            const hexCode = await fetchHexCode(selectedTopicKey);
    console.log("hexcode" ,selectedTopicKey,'=>', hexCode);
    
            await window.ethereum.request({ method: 'eth_requestAccounts' });
            const provider = new ethers.BrowserProvider(window.ethereum);
            const signer = await provider.getSigner();
            const abi = [
                'function addClaimTopic(uint256 _claimTopic) external',
            ];
            const contract = new ethers.Contract("0xE1D92867B0DDE5ecE2c20Ca14b879331532cDF8f", abi, signer); //topic registy 
    
            // Convert hex code to a number
            const topic = parseInt(hexCode, 16);
            const tx = await contract.addClaimTopic(topic);
            await tx.wait();
    
            setMessage('Claim topic added successfully!');
        } catch (error) {
            console.error('Error:', error);
            setMessage(`Error: ${error.message}`);
        }
    };
    

    const fetchHexCode = async (topicKey) => {
        return new Promise((resolve, reject) => {
            const topicRef = ref(database, `topics/${topicKey}/hexcode`);
            onValue(topicRef, (snapshot) => {
                const hexCode = snapshot.val();
                if (hexCode) {
                    resolve(hexCode);
                } else {
                    reject(new Error('Hex code not found for the selected topic.'));
                }
            });
        });
    };
    


    const removeClaimTopic = async () => {
        try {
            if (!window.ethereum) {
                throw new Error('MetaMask is not installed');
            }
            await window.ethereum.request({ method: 'eth_requestAccounts' });
            const provider = new ethers.BrowserProvider(window.ethereum);
            const signer = await provider.getSigner();
            const abi = [
                'function removeClaimTopic(uint256 _claimTopic) external',
            ];
            const contract = new ethers.Contract("0xE1D92867B0DDE5ecE2c20Ca14b879331532cDF8f", abi, signer); // topic registry 
            const topic = parseInt(claimTopic, 10);
            
            const tx = await contract.removeClaimTopic(topic);

            await tx.wait();
            setMessage('Claim topic removed successfully!');
        } catch (error) {
            console.error('Error:', error);
            setMessage(`Error: ${error.message}`);
        }
    };

    return (
        <>
          
                <>
                    <p className='address'>Network: {networkName}</p>
                    <p className='address'>Address: {metaMaskAddress}</p>
                    <div className="form-container">
                        {/* <div className="form-group">
                            <label>Contract Address:</label>
                            <input
                                type="text"
                                value={contractAddress}
                                onChange={(e) => setContractAddress(e.target.value)}
                                placeholder="Enter contract address"
                                required
                            />
                        </div> */}
                        <hr className="styled-hr" />
                        <div className="form-group">
                            <label>Add Claim Topic:</label>
                            <p>NOTE : To add a topic to the smart contract, retrieve the data from the database and send a transaction using ERC3643.</p>
                            <div className="input-group">
                                <label className="label">Select Topic</label>
                                <select
                                    onChange={(e) => setSelectedTopicKey(e.target.value)} // Update selected topic key
                                >
                                    <option value="">Select a topic</option>
                                    {topics.map((topic) => (
                                        <option key={topic.key} value={topic.key}> {/* Set the value to the key */}
                                            {topic.value.topic}
                                        </option>
                                    ))}
                                </select>
                            </div>
                            <button
                                type="button"
                                onClick={addClaimTopic}
                                className="submit-button"
                            >
                                Add Topic
                            </button>
                        </div>
                        <div className="form-group">
                            <label>Remove Claim Topic:</label>
                            <input
                                type="number"
                                value={claimTopic}
                                onChange={(e) => setClaimTopic(e.target.value)}
                                placeholder="Enter topic to remove"
                                required
                            />
                            <button
                                type="button"
                                onClick={removeClaimTopic}
                                className="submit-button"
                            >
                                Remove Topic
                            </button>
                        </div>
                        {message && <p>{message}</p>}
                    </div>
                </>
            
        </>
    );
};

export default ClaimTopicsRegistry;
