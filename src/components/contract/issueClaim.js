import React, { useState } from 'react';
import "../css/IssueClaim.css"
import { ethers } from 'ethers';

export default function IssueClaim() {
  const [uniqueId, setUniqueId] = useState('');
  const [data, setData] = useState('');
  const [contractAddress, setContractAddress] = useState('');
  const [topic, setTopic] = useState('');
  const [identityAddress, setIdentityAddress] = useState('');
  const [signature, setSignature] = useState('');
  const [metaMaskAddress, setMetaMaskAddress] = useState('');
  const [isMetaMaskConnected, setIsMetaMaskConnected] = useState(false);
  const [networkName, setNetworkName] = useState('');
  const [message, setMessage] = useState('');

  const celo = {
    celoChainId: '0xaef3',
    celoName: "Celo Alfajores Testnet"
}
  const handleMetaMaskSign = async () => {
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
    // MetaMask signing logic here
    console.log("MetaMask Sign -> ", { uniqueId, data, identityAddress });
    setSignature('signed-data-placeholder'); // Placeholder for signature
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    // Handle database submission here
    console.log("DB -> Investors Table: ", { data, signature, identityAddress });

    // Clear the form
    setUniqueId('');
    setData('');
    setContractAddress('');
    setTopic('');
    setIdentityAddress('');
    setSignature('');
  };

  return (
    <>
       {!metaMaskAddress ? (
                <div className="connect-metamask-container">
                    <p>Please connect MetaMask to see your address</p>
                    <button onClick={handleMetaMaskSign}>Connect MetaMask</button>
                </div>
            ):(<>
  
    <div className="form-container">
      <form onSubmit={handleSubmit}>
        <h3>Issue Claim</h3>
        <p>Only trusted claim issuer</p>
        <p>Metamask connect required</p>
        
        <div className="form-group">
          <label>Unique Identification Number:</label>
          <input 
            type="text" 
            value={uniqueId} 
            onChange={(e) => setUniqueId(e.target.value)} 
            required 
          />
        </div>

        <div className="form-group">
          <label>Data:</label>
          <input 
            type="text" 
            value={data} 
            onChange={(e) => setData(e.target.value)} 
            required 
          />
        </div>

        <div className="form-group">
          <label>Claim Issuer Contract Address:</label>
          <input 
            type="text" 
            value={contractAddress} 
            onChange={(e) => setContractAddress(e.target.value)} 
            required 
          />
        </div>

        <div className="form-group">
          <label>Topic:</label>
          <select 
            value={topic} 
            onChange={(e) => setTopic(e.target.value)} 
            required
          >
            <option value="">Select Topic</option>
            <option value="Topic1">Topic 1</option>
            <option value="Topic2">Topic 2</option>
            <option value="Topic3">Topic 3</option>
          </select>
        </div>

        <div className="form-group">
          <label>Identity (Address):</label>
          <input 
            type="text" 
            value={identityAddress} 
            onChange={(e) => setIdentityAddress(e.target.value)} 
            required 
          />
        </div>

        <div className="form-group">
          <button 
            type="button" 
            className="submit-button" 
            onClick={handleMetaMaskSign}
          >
            Sign with MetaMask
          </button>
        </div>

        <button 
          type="submit" 
          className="submit-button"
        >
          Submit
        </button>
      </form>
    </div>
    </>)}
    </>
  );
}
