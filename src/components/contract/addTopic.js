import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import '../css/ClaimTopicsRegistry.css'; // Importing the CSS file for styling

const ClaimTopicsRegistry = () => {
    const [contractAddress, setContractAddress] = useState('');
    const [claimTopic, setClaimTopic] = useState('');
    const [message, setMessage] = useState('');
    const [metaMaskAddress, setMetaMaskAddress] = useState('');
    const [isMetaMaskConnected, setIsMetaMaskConnected] = useState(false);

    const handleMetaMaskConnect = async () => {
        if (!window.ethereum) {
            alert('MetaMask is not installed. Please install it to use this feature.');
            return;
        }
        try {
            const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
            const account = accounts[0];
            setMetaMaskAddress(account);
            setIsMetaMaskConnected(true);
        } catch (error) {
            console.error("MetaMask connection error:", error);
            alert('Failed to connect MetaMask: ' + error.message);
        }
    };

    useEffect(() => {
        handleMetaMaskConnect();
    }, []);

    const addClaimTopic = async () => {
        try {
            if (!window.ethereum) {
                throw new Error('MetaMask is not installed');
            }
            await window.ethereum.request({ method: 'eth_requestAccounts' });
            const provider = new ethers.BrowserProvider(window.ethereum);
            const signer = await provider.getSigner();
            const abi = [
                'function addClaimTopic(uint256 _claimTopic) external',
            ];
            const contract = new ethers.Contract(contractAddress, abi, signer);
            const topic = parseInt(claimTopic);
            const tx = await contract.addClaimTopic(topic);
            await tx.wait();
            setMessage('Claim topic added successfully!');
        } catch (error) {
            console.error('Error:', error);
            setMessage(`Error: ${error.message}`);
        }
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
            const contract = new ethers.Contract(contractAddress, abi, signer);
            const topic = parseInt(claimTopic);
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
            {!metaMaskAddress ? (
                 <div className="connect-metamask-container">
                    <p>Please connect MetaMask to see your address</p>
                    <button  onClick={handleMetaMaskConnect}>Connect MetaMask</button>
                </div>
            ) : (
                <>
                    <p className='address'>Address: {metaMaskAddress}</p>
                    <div className="form-container">
                        <div className="form-group">
                            <label>Contract Address:</label>
                            <input
                                type="text"
                                value={contractAddress}
                                onChange={(e) => setContractAddress(e.target.value)}
                                placeholder="Enter contract address"
                                required
                            />
                        </div>
                        <div className="form-group">
                            <label>Add Claim Topic:</label>
                            <input
                                type="number"
                                value={claimTopic}
                                onChange={(e) => setClaimTopic(e.target.value)}
                                placeholder="Enter topic to add"
                                required
                            />
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
            )}
        </>
    );
};

export default ClaimTopicsRegistry;
