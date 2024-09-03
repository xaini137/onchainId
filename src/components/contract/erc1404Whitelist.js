import { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import '../css/erc1404.css'; // Importing the CSS file for styling

const ClaimTopicsRegistry = () => {
    const [status, setStatus] = useState("");
    const [contract, setContract] = useState(null);
    const [contractAddress] = useState('0x1BC420db53CEc0801BAb6DA747c93F64f82B4EA6');
    const [metaMaskAddress, setMetaMaskAddress] = useState('');
    const [isMetaMaskConnected, setIsMetaMaskConnected] = useState(false);
    const [networkName, setNetworkName] = useState('');
    const [totalSupply, setTotalSupply] = useState(0);
    const [balance, setBalance] = useState(0);
    const [whitelistAddress, setWhitelistAddress] = useState("");
    const [whitelistStatus, setWhitelistStatus] = useState("Inactive");
    const [whitelistData, setWhitelistData] = useState(""); // Changed to empty string
    const [pause, setPause] = useState(false);
    const [whitelistCheckStatus, setWhitelistCheckStatus] = useState("");
    const [mintAmount, setMintAmount] = useState("");
    const [userAddress, setUserAddress] = useState("")
    const bscTestnet = {
        chainId: '0x61', // BSC Testnet chain ID in hexadecimal
        chainName: "Binance Smart Chain Testnet",
        nativeCurrency: {
            name: 'Binance Coin',
            symbol: 'BNB',
            decimals: 18,
        },
        rpcUrls: ['https://data-seed-prebsc-1-s1.binance.org:8545'],
        blockExplorerUrls: ['https://testnet.bscscan.com/'],
    };

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

            if (network.chainId !== parseInt(bscTestnet.chainId, 16)) {
                try {
                    await window.ethereum.request({
                        method: 'wallet_switchEthereumChain',
                        params: [{ chainId: bscTestnet.chainId }],
                    });
                } catch (switchError) {
                    if (switchError.code === 4902) {
                        try {
                            await window.ethereum.request({
                                method: 'wallet_addEthereumChain',
                                params: [bscTestnet],
                            });
                            setNetworkName('BSC Testnet network added and switched successfully.');
                        } catch (addError) {
                            console.error('Failed to add the BSC Testnet network:', addError);
                        }
                    } else {
                        console.error('Failed to switch network:', switchError);
                    }
                }
            } else {
                setNetworkName(bscTestnet.chainName);
            }

            setIsMetaMaskConnected(true);
        } catch (error) {
            console.error("MetaMask connection error:", error);
            alert('Failed to connect MetaMask: ' + error.message);
        }
    };

    const fetchContractData = async () => {
        if (!metaMaskAddress) {
            console.warn("MetaMask address is not set.");
            return;
        }

        try {
            const provider = new ethers.BrowserProvider(window.ethereum);
            const signer = await provider.getSigner();
            const abi = [
                'function totalSupply() external view returns (uint256)',
                'function paused() external view returns (bool)',
                'function balanceOf(address) external view returns (uint256)',
                'function addWhitelister(address) external',
                'function setWhitelist(address, bool, string) external',
                'function Mint(address, uint256) external',
                'function addPauser(address) external',
                'function addRevoker(address) external',  // Added
                'function addTimelocker(address) external',  // Added
                'function isWhitelister(address account) public view returns (bool)',
            ];

            const contract = new ethers.Contract(contractAddress, abi, signer);
            setContract(contract);
            const [supply, balance, pause, isWhitelister] = await Promise.all([
                contract.totalSupply(),
                contract.balanceOf(metaMaskAddress),
                contract.paused(),
                contract.isWhitelister(metaMaskAddress),
            ]);
            setPause(pause);
            setTotalSupply(ethers.formatUnits(supply, 18));
            setBalance(ethers.formatUnits(balance, 18));
            setWhitelistStatus(isWhitelister ? "Active" : "Inactive");
        } catch (error) {
            console.error('Error fetching contract data:', error);
        }
    };

    const handleAddWhitelist = async () => {
        if (!contract) {
            setStatus("Contract is not loaded");
            return;
        }

        try {
            const tx = await contract.addWhitelister(whitelistAddress);
            await tx.wait();
            setStatus("Address added to whitelist successfully");
        } catch (error) {
            setStatus(`Error adding to whitelist: ${error.message}`);
        }
    };

    const handleSetWhitelist = async () => {
        if (!contract) {
            setStatus("Contract is not loaded");
            return;
        }

        try {
            const statusBool = whitelistStatus === "Active";
            const dataToSend = whitelistData || ""; // Ensure this is a string
            console.log("Data to send:", dataToSend);
            const tx = await contract.setWhitelist(whitelistAddress, "true", "dataToSend");
            await tx.wait();
            setStatus("Whitelist status updated successfully");
        } catch (error) {
            setStatus(`Error setting whitelist: ${error.message}`);
        }
    };

    const handleWhitelistAddressChange = async (e) => {
        const address = e.target.value;
        setWhitelistAddress(address);
        if (address && ethers.isAddress(address)) {
            try {
                const isWhitelister = await contract.isWhitelister(address);
                setWhitelistCheckStatus(isWhitelister ? "Address is already whitelisted" : "Address is not whitelisted");
            } catch (error) {
                setWhitelistCheckStatus(`Error checking whitelist status: ${error.message}`);
            }
        } else {
            setWhitelistCheckStatus("Invalid address");
        }
    };

    const handleMint = async () => {
        if (!contract) {
            setStatus("Contract is not loaded");
            return;
        }
        try {
            const tx = await contract.Mint(whitelistAddress, ethers.parseUnits(mintAmount, 18));
            await tx.wait();
            setStatus("Tokens minted successfully");
        } catch (error) {
            setStatus(`Error minting tokens: ${error.message}`);
        }
    };


    const handleAddPauser = async () => {
        if (!contract) {
            setStatus("Contract is not loaded");
            return;
        }
        try {
            const tx = await contract.addPauser(userAddress);
            await tx.wait();
            setStatus("Pauser Role successfully");
        } catch (error) {
            setStatus(`Error minting tokens: ${error.message}`);
        }
    };

    const handleAddRevoker = async () => {
        if (!contract) {
            setStatus("Contract is not loaded");
            return;
        }
        try {
            const tx = await contract.addRevoker(userAddress);
            await tx.wait();
            setStatus("Revoker role added successfully");
        } catch (error) {
            setStatus(`Error adding Revoker role: ${error.message}`);
        }
    };

    const handleAddTimelocker = async () => {
        if (!contract) {
            setStatus("Contract is not loaded");
            return;
        }
        try {
            const tx = await contract.addTimelocker(userAddress);
            await tx.wait();
            setStatus("Timelocker role added successfully");
        } catch (error) {
            setStatus(`Error adding Timelocker role: ${error.message}`);
        }
    };
    useEffect(() => {
        handleMetaMaskConnect();
    }, []);
    useEffect(() => {
        if (isMetaMaskConnected) {
            fetchContractData();
        }
    }, [isMetaMaskConnected]);

    return (
        <>
            <p className='address'>Network: {networkName}</p>
            <p className='address'>Your Address: {metaMaskAddress}</p>
            <div className="form-container">
                <div className="form-group-horizontal">
                    <div className="form-item">
                        <label>Total Supply:</label>
                        <p className='output'>{totalSupply}</p>
                    </div>
                    <div className="form-item">
                        <label>Balance :</label>
                        <p className='output'>{balance}</p>
                    </div>
                    <div className="form-item">
                        <label>Token Status:</label>
                        <p>{pause ? 'Paused' : 'Active'}</p>
                    </div>
                    <div className="form-item">
                        <label>Whitelist Status:</label>
                        <p>{whitelistStatus}</p>
                    </div>
                </div>
            </div>
            <div className="erc1404-container">
                <h3>USER WHITELISTING</h3>
                <div className="whitelist-box-container">
                    <div className="whitelist-box">
                        <div className="whitelist-section">
                            <h3 className='header'>STEP-1</h3>
                            <h4>Whitelist an Address</h4>
                            <input
                                type="text"
                                placeholder="Enter address"
                                value={whitelistAddress}
                                onChange={handleWhitelistAddressChange}
                            />
                            <button onClick={handleAddWhitelist}>Add to Whitelist</button>
                            <p className='note'>{whitelistCheckStatus}</p>
                            <p>{status}</p>
                        </div>
                    </div>
                    <div className="whitelist-box">
                        <div className="whitelist-section">
                            <h3 className='header'>STEP-2</h3>
                            <h4>Set Whitelist Status</h4>
                            <input
                                type="text"
                                placeholder="Enter address"
                                value={whitelistAddress}
                                onChange={handleWhitelistAddressChange}
                            />
                            <input
                                type="text"
                                placeholder="Enter data"
                                value={whitelistData}
                                onChange={(e) => setWhitelistData(e.target.value)}
                            />
                            <select
                                value={whitelistStatus}
                                onChange={(e) => setWhitelistStatus(e.target.value)}
                            >
                                <option value="Inactive">Inactive</option>
                                <option value="Active">Active</option>
                            </select>
                            <button onClick={handleSetWhitelist}>Set Whitelist Status</button>
                            <p>{status}</p>
                        </div>
                    </div>
                    <div className="whitelist-box">
                        <div className="whitelist-section">
                            <h3 className='header'>STEP-3</h3>
                            <h4>Mint Tokens</h4>
                            <input
                                type="text"
                                placeholder="Enter address"
                                value={whitelistAddress}
                                onChange={(e) => setWhitelistAddress(e.target.value)}
                            />
                            <input
                                type="number"
                                placeholder="Enter mint amount"
                                value={mintAmount}
                                onChange={(e) => setMintAmount(e.target.value)}
                            />
                            <button onClick={handleMint}>Mint</button>
                            <p>{status}</p>
                        </div>
                    </div>

                </div>
                <div className="erc1404-container">
                    <h3>ADMIN FUNCTION</h3>
                    <div className="Admin-box">
                        <div className="whitelist-section">
                            <h4>Add Pauser</h4>
                            <div className="inline-container">
                                <input
                                    type="text"
                                    placeholder="Enter address"
                                    value={userAddress}
                                    onChange={(e) => setUserAddress(e.target.value)}
                                />
                                <button className="in-same-line" onClick={handleAddPauser}>Add Pauser</button>
                            </div>
                            <h4>Add Revoker</h4> {/* New Section for Add Revoker */}
                            <div className="inline-container">
                                <input
                                    type="text"
                                    placeholder="Enter address"
                                    value={userAddress}
                                    onChange={(e) => setUserAddress(e.target.value)}
                                />
                                <button className="in-same-line" onClick={handleAddRevoker}>Add Revoker</button>
                            </div>
                            <h4>Add Timelocker</h4> {/* New Section for Add Timelocker */}
                            <div className="inline-container">
                                <input
                                    type="text"
                                    placeholder="Enter address"
                                    value={userAddress}
                                    onChange={(e) => setUserAddress(e.target.value)}
                                />
                                <button className="in-same-line" onClick={handleAddTimelocker}>Add Timelocker</button>
                            </div>
                            <p>{status}</p>
                        </div>
                    </div>

                </div>


            </div>
        </>
    );
};

export default ClaimTopicsRegistry;
