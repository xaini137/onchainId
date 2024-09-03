// src/hooks/useMetaMask.js
import { useState, useEffect } from 'react';
import { ethers } from 'ethers';

export function useMetaMask() {
    const [account, setAccount] = useState(null);
    const [provider, setProvider] = useState(null);
    const [networkName, setNetworkName] = useState('');
    const [isMetaMaskConnected, setIsMetaMaskConnected] = useState(false);
    const [message, setMessage] = useState('');

    const celo = {
        celoChainId: '0xaef3', // Celo Alfajores Testnet chain ID
        celoName: 'Celo Alfajores Testnet',
    };

    const handleMetaMaskConnect = async () => {
        if (!window.ethereum) {
            alert('MetaMask is not installed. Please install it to use this feature.');
            return;
        }
        try {
            const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
            const account = accounts[0];
            setAccount(account);

            const provider = new ethers.BrowserProvider(window.ethereum);
            setProvider(provider);
            console.log("provider", provider);

            const network = await provider.getNetwork();
            console.log("network", network);

            // Set the network name (capitalize the first letter)
            setNetworkName(celo.celoName);

            // Check if the current network is not Celo
            if (network.chainId !== parseInt(celo.celoChainId, 16)) {
                try {
                    await window.ethereum.request({
                        method: 'wallet_switchEthereumChain',
                        params: [{ chainId: celo.celoChainId }],
                    });
                } catch (switchError) {
                    // This error code indicates that the chain has not been added to MetaMask.
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
        if (window.ethereum) {
            window.ethereum.on('accountsChanged', (accounts) => {
                setAccount(accounts[0]);
            });
        }
    }, []);

    return {
        account,
        provider,
        networkName,
        isMetaMaskConnected,
        message,
        handleMetaMaskConnect,
    };
}
