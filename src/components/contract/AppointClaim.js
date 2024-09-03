import React from 'react'
import { useState ,useEffect} from 'react';
import { ethers } from 'ethers';
export default function AppointClaim() {

const [issuerAddress, setIssuerAddress] = useState('');
const [contractAddress, setContractAddress] = useState('');
const [message, setMessage] = useState('');
const [metaMaskAddress, setMetaMaskAddress] = useState('');
const [isMetaMaskConnected, setIsMetaMaskConnected] = useState(false);
const [networkName, setNetworkName] = useState('');
 
     const celo = {
         celoChainId: '0xaef3',
         celoName: "Celo Alfajores Testnet"
     }
 
     const  handleMetaMaskConnect = async () => {
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
 

  const handleSubmit = async (e) => {
    e.preventDefault();

    // Handle database submission here
    console.log("DB -> Addresses Table: ", issuerAddress, contractAddress);

    // Handle interaction with MetaMask for trustedIssuersRegistry here
    console.log("MetaMask -> trustedIssuersRegistry: ", issuerAddress, contractAddress);

    // Clear the form
    setIssuerAddress('');
    setContractAddress('');
  }
  return (
    <>
    
    {!metaMaskAddress ? (
                <div className="connect-metamask-container">
                    <p>Please connect MetaMask to see your address</p>
                    <button onClick={handleMetaMaskConnect}>Connect MetaMask</button>
                </div>
            ):(<>
     <p className='address'>Network: {networkName}</p>
     <p className='address'>Address: {metaMaskAddress}</p>
    <div className="form-container">
    <form onSubmit={handleSubmit}>
      <div className="form-group">
        <label>Claim Issuer Address:</label>
        <input 
          type="text" 
          value={issuerAddress} 
          onChange={(e) => setIssuerAddress(e.target.value)} 
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
  )
}
