import React, { useState, useEffect } from "react";
import { ethers } from "ethers";
import "../css/protonAuction.css"; // Ensure this import is correct

// const tokenAddress = "0x1BC420db53CEc0801BAb6DA747c93F64f82B4EA6";
const tokenAddress = "0xaAD2d6dcc292EC80B319F725601D7884DFa52379";
const usdtBalance = "0x951f9a11d97bE0630801bafdb304Fd2a047729C7";
const tokenAbi = [
  "function totalSupply() external view returns (uint256)",
  "function paused() external view returns (bool)",
  "function balanceOf(address) external view returns (uint256)",
  "function addWhitelister(address) external",
  "function setWhitelist(address, bool, bytes) external",
  "function isWhitelister(address account) public view returns (bool)",
  "function allowance(address owner, address spender) external view returns (uint256)",
  "function approve(address spender, uint256 amount) external returns (bool)",
  "function getLockedAmount(address ) public view returns (uint256)",
  "function checkLockup( address ) public view returns (uint256[] memory, uint256[] memory)",
  "function getUserType( address ) public view returns (string )",
];

// const contractAddress = "0x4Ce4F22AFE556101F9AA41379975eF9dc94742b0";
const contractAddress = "0x00AD35dB57cF630d26D99CE7EA956D7dbae02c49";
const abi = [
  "function buyTokens(uint256 _amount) external",
  "function tokenPrice() external view returns (uint256)",
  "function getDailyAuction(uint256 _currentDay) external view returns (uint256, uint256, uint256)",
  "function getCurrentDay() external view returns (uint256)",
  "function AuctionTime() external view returns (uint256, uint256)",
  "function calculateTokenAmount(uint256 _usdtAmount) external view returns (uint256)",
  "function getWhitelistData(address) public view returns (string memory)",
];

const ProtonAuction = () => {
  const [whitelistAddress, setWhitelistAddress] = useState("");
  const [provider, setProvider] = useState(null);
  const [signer, setSigner] = useState(null);
  const [contract, setContract] = useState(null);
  const [tokenContract, setTokenContract] = useState(null);
  const [usdtContract, setUsdtContract] = useState(null);
  const [currentPrice, setCurrentPrice] = useState(0);
  const [currentDay, setCurrentDay] = useState(0);
  const [auctionDetails, setAuctionDetails] = useState({});
  const [auctionTime, setAuctionTime] = useState({});
  const [usdtAmount, setUsdtAmount] = useState("0");
  const [tokenAmount, setTokenAmount] = useState("0");
  const [metaMaskAddress, setMetaMaskAddress] = useState("");
  const [isWhitelister, setIsWhitelister] = useState(false);
  const [balance, setBalance] = useState("");
  const [usdtBal, setUsdtBal] = useState("");
  const [allowance, setAllowance] = useState(0);
  const [approving, setApproving] = useState(false);
  const [userType, setUserType] = useState("");
  const [lockedAmounts, setAllLockAmount] = useState([]);
  const [releaseTimes, setReleaseTimes] = useState([]);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const [totallock, seTtotallock] = useState("");
  useEffect(() => {
    const init = async () => {
      try {
        if (!window.ethereum) {
          throw new Error("MetaMask is not installed");
        }
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();
        const account = accounts[0];
        setMetaMaskAddress(account);

        const contract = new ethers.Contract(contractAddress, abi, signer);
        setContract(contract);

        const tokenContract = new ethers.Contract(
          tokenAddress,
          tokenAbi,
          signer
        );
        setTokenContract(tokenContract);

        const usdtContract = new ethers.Contract(usdtBalance, tokenAbi, signer);
        setUsdtContract(usdtContract);
        console.log(account);
        const [
          price,
          day,
          [start, end],
          [tokensDaily, tokensSold, bonusMultiplier],
          isWhitelister,
          getTotalLock,
          alllockdetail,
          getUserTypes,
        ] = await Promise.all([
          contract.tokenPrice(),
          contract.getCurrentDay(),
          contract.AuctionTime(),
          contract.getDailyAuction(contract.getCurrentDay()),
          tokenContract.balanceOf(account),
          tokenContract.isWhitelister(account),
         
          tokenContract.checkLockup(account),
        
        ]);
        console.log(account);
        
        setIsWhitelister(await tokenContract.isWhitelister(account));
        const bal = await tokenContract.balanceOf(account);
        const usdtBal = await usdtContract.balanceOf(account);
        const allowedAmount = await usdtContract.allowance(
          account,
          contractAddress
        );

        setAllowance(Number(ethers.formatEther(allowedAmount)));
        setBalance(ethers.formatEther(bal));
        setUsdtBal(ethers.formatEther(usdtBal));
        setCurrentPrice(Number(ethers.formatEther(price)));
        setCurrentDay(Number(day));
        setAuctionTime({
          start: new Date(Number(start) * 1000),
          end: new Date(Number(end) * 1000),
        });

        setAuctionDetails({
          tokensDaily: Number(ethers.formatEther(tokensDaily)),
          tokensSold: Number(ethers.formatEther(tokensSold)),
          bonusMultiplier: Number(bonusMultiplier),
        });
        setUserType(await   tokenContract.getUserType(account));
        let lock =await   tokenContract.getLockedAmount(account)
        seTtotallock(ethers.formatEther(lock))
        console.log(totallock);
      } catch (error) {
        console.error("Error fetching contract data:", error);
      }
    };

    init();
  }, []);

  const calculateTokenAmount = async (amountInUSDT) => {
    if (contract && amountInUSDT) {
      try {
        const amountInWei = ethers.parseEther(amountInUSDT.toString());
        const tokens = await contract.calculateTokenAmount(amountInWei);
        setTokenAmount(Number(ethers.formatEther(tokens)));
      } catch (error) {
        console.error("Error calculating token amount:", error);
      }
    }
  };

  const handleAmountChange = (e) => {
    const amount = e.target.value;
    setUsdtAmount(amount);
    calculateTokenAmount(amount);
  };

  const handleBuyTokens = async () => {
    if (contract && usdtAmount) {
      try {
        const tx = await contract.buyTokens(ethers.parseEther(usdtAmount));
        await tx.wait();
        alert("Tokens purchased successfully!");
      } catch (error) {
        console.error("Error buying tokens:", error);
      }
    }
  };

  const handleCheckLockup = async () => {
    try {
      if (tokenContract && metaMaskAddress) {
        // Fetch the locked amounts and release times from the contract
        const [lockedAmounts, releaseTimes] = await tokenContract.checkLockup(metaMaskAddress);
        
        // Convert BigInt values to readable format
        const formattedLockAmounts = lockedAmounts.map(amount => Number(ethers.formatEther(amount)));
        const formattedReleaseTimes = releaseTimes.map(time => new Date(Number(time) * 1000).toLocaleString());
  
        console.log("Lockup Amounts: ", formattedLockAmounts);
        console.log("Release Times: ", formattedReleaseTimes);
        
        // You can now display these in a popup or set them in the state for rendering
        setAllLockAmount({ formattedLockAmounts, formattedReleaseTimes });
  
      } else {
        throw new Error("Token contract or MetaMask address not available");
      }
    } catch (error) {
      console.error("Error fetching lockup details:", error);
    }
  };
  

  const closeModal = () => {
    setIsModalOpen(false); // Close the modal
  };

  const handleApprove = async () => {
    if (usdtContract && metaMaskAddress) {
      try {
        setApproving(true);
        const amount = ethers.parseEther("1000000"); // Set a large amount for approval
        const tx = await usdtContract.approve(contractAddress, amount);
        await tx.wait();
        setApproving(false);
        alert("USDT approved successfully!");
        const allowedAmount = await usdtContract.allowance(
          metaMaskAddress,
          contractAddress
        );
        setAllowance(Number(ethers.formatEther(allowedAmount)));
      } catch (error) {
        setApproving(false);
        console.error("Error approving USDT:", error);
      }
    }
  };

  return (
    <div className="auction-container">
      <p>
        <span className="bold-text">MetaMask Address:</span> {metaMaskAddress}
      </p>
      <p>
        <span className="bold-text">Whitelister Status:</span> {" "}
        {isWhitelister ? "Whitelisted" : "Not Whitelisted"} 
        <span className="bold-text">User Type:</span>{" "}
        {userType ?userType  : "NotAssign"}
      </p>
      <div className="form-container">
        <div className="form-group-horizontal">
          <div className="form-item">
            <label>Proton Price:</label>
            <p className="output">{currentPrice} USDT</p>
          </div>
          <div className="form-item">
            <label>Current Day:</label>
            <p className="output">DAY {currentDay}</p>
          </div>
          <div className="form-item">
            <label>Auction Start Time:</label>
            <p className="output">{auctionTime.start?.toLocaleString()}</p>
          </div>
          <div className="form-item">
            <label>Auction End Time:</label>
            <p className="output">{auctionTime.end?.toLocaleString()}</p>
          </div>
          <div className="form-item">
            <label>Tokens Daily:</label>
            <p className="output">{auctionDetails.tokensDaily || "0"}</p>
          </div>
          <div className="form-item">
            <label>Tokens Sold:</label>
            <p className="output">{auctionDetails.tokensSold || "0"}</p>
          </div>
          <div className="form-item">
            <label>Bonus Multiplier:</label>
            <p className="output">{auctionDetails.bonusMultiplier || "0"}</p>
          </div>
          <div className="form-item">
            <label>Total Lock:</label>
            <p className="output">{totallock || "0"}</p>
          </div>
        </div>
      </div>

      <div className="buy-token">
        <h3>Buy Proton Tokens</h3>
        <span>
          <p>USDT Balance: {usdtBal}</p>
        </span>

        <input
          type="number"
          inputMode="numeric"
          placeholder="Amount in USDT"
          value={usdtAmount}
          onChange={handleAmountChange}
        />

        <input
          type="number"
          inputMode="numeric"
          readOnly
          value={tokenAmount}
          placeholder="Calculated PROTON"
        />
        <span>
          <p> Allowance: {allowance}</p>
        </span>
        {allowance < usdtAmount && (
          <button onClick={handleApprove} disabled={approving}>
            {approving ? "Approving..." : "Approve"}
          </button>
        )}

        {allowance >= usdtAmount && (
          <button onClick={handleBuyTokens}>Buy</button>
         
        )}
          <p className= "checklockup" onClick={handleCheckLockup}>View Lockup Details</p>
          {isModalOpen && (
          <div className="modal">
            <div className="modal-content">
              <h3>Lockup Details</h3>
              <ul>
                {lockedAmounts.map((amount, index) => (
                  <li key={index}>
                    Amount: {amount} PROTON, Release Time: {releaseTimes[index]}
                  </li>
                ))}
              </ul>
              <button onClick={closeModal}>Close</button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default ProtonAuction;
