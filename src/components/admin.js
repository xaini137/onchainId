import React, { useState, useEffect } from 'react';
import { ref, set, push, onValue } from "firebase/database";
import { database } from '../firebase';
import './css/admin.css';
import { ethers } from 'ethers';

export default function Admin() {
  const [topics, setTopics] = useState([]);
  const [topic, setTopic] = useState('');
  const [hexcode, setHexcode] = useState('');
  const [provider, setProvider] = useState(null);
  const [signer, setSigner] = useState(null);
  const [contract, setContract] = useState(null);
  const [whitelistAddress, setWhitelistAddress] = useState("");
  const [whitelistStatus, setWhitelistStatus] = useState("Inactive");
  const [whitelistData, setWhitelistData] = useState("");
  const [status, setStatus] = useState("");
  const [adminEmail, setAdminEmail] = useState('');
  const [admins, setAdmins] = useState([]);

  const contractABI = [
    {
      "constant": false,
      "inputs": [
        {
          "name": "account",
          "type": "address"
        }
      ],
      "name": "addWhitelister",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "name": "to",
          "type": "address"
        },
        {
          "name": "status",
          "type": "bool"
        },
        {
          "name": "data",
          "type": "string"
        }
      ],
      "name": "setWhitelist",
      "outputs": [
        {
          "name": "",
          "type": "bool"
        }
      ],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
    },
  ];

  const contractAddress = "0x2acB1f8495653DB637987cC96001E09Bc6085D00";

  useEffect(() => {
    const initialize = async () => {
      if (window.ethereum) {
        const prov = new ethers.BrowserProvider(window.ethereum);
        setProvider(prov);

        const signer = await prov.getSigner();
        setSigner(signer);

        const contractInstance = new ethers.Contract(
          contractAddress,
          contractABI,
          signer
        );
        setContract(contractInstance);
      } else {
        setStatus("MetaMask is not installed");
      }
    };

    initialize();
  }, []);

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
      setStatus(`Error: ${error.message}`);
    }
  };

  const handleSetWhitelist = async () => {
    if (!contract) {
      setStatus("Contract is not loaded");
      return;
    }

    try {
      const statusBool = whitelistStatus === "Active";
      const tx = await contract.setWhitelist(whitelistAddress, statusBool, whitelistData);
      await tx.wait();
      setStatus("Whitelist status updated successfully");
    } catch (error) {
      setStatus(`Error: ${error.message}`);
    }
  };

  useEffect(() => {
    const adminsRef = ref(database, 'admins');
    onValue(adminsRef, (snapshot) => {
      const data = snapshot.val();
      if (data) {
        setAdmins(Object.entries(data).map(([key, value]) => ({ key, value })));
      }
    });
  }, []);

  const handleTopicInputChange = (e) => {
    setTopic(e.target.value);
  };

  const handleHexcodeInputChange = (e) => {
    setHexcode(e.target.value);
  };

  const handleAdminInputChange = (e) => {
    setAdminEmail(e.target.value);
  };

  const saveTopicToFirebase = () => {
    const topicsRef = ref(database, 'topics');
    const newTopicRef = push(topicsRef);
    const topicData = {
      topic: topic,
      hexcode: hexcode
    };
    set(newTopicRef, topicData)
      .then(() => {
        alert('Topic saved successfully');
        setTopic('');
        setHexcode('');
      })
      .catch((error) => {
        alert('Failed to save topic: ' + error.message);
      });
  };

  const addAdminToFirebase = () => {
    const adminsRef = ref(database, 'admins');
    const newAdminRef = push(adminsRef);
    set(newAdminRef, adminEmail).then(() => {
      alert('Admin added successfully');
      setAdminEmail('');
    }).catch((error) => {
      alert('Failed to add admin: ' + error.message);
    });
  };

  return (
    <>
      <div className="admin-container">
        <div className="admin-content">
          <div className="admin-list">
            <h2>Admin List</h2>
            <ul>
              {admins.map((admin) => (
                <li key={admin.key}>{admin.value}</li>
              ))}
            </ul>
          </div>
          <div className="vertical-line"></div>
          <div className="admin-inputs">
            <div className="input-group">
              <label className="label">Add New Admin</label>
              <div className="note-container">
                <p>NOTE:</p>
                <ul>
                  <li>For adding new admin</li>
                  <li>Only this email can access admin routes</li>
                </ul>
              </div>
              <input
                type="email"
                name="adminEmail"
                placeholder="Enter email"
                value={adminEmail}
                onChange={handleAdminInputChange}
              />
              <button onClick={addAdminToFirebase}>Add Admin</button>
            </div>
          </div>
        </div>
      </div>

      <div className="erc1404-container">
        <h3>ERC-1404 :Compliance</h3>
        <div className="whitelist-box-container">
          <div className="whitelist-box">
            <div className="whitelist-section">
            <h3 className='header'>STEP-1</h3>
              <h4>Whitelist an Address</h4>
              <input 
                type="text"
                placeholder="Enter address"
                value={whitelistAddress}
                onChange={(e) => setWhitelistAddress(e.target.value)}
              />
              <button onClick={handleAddWhitelist}>Add to Whitelist</button>
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
                onChange={(e) => setWhitelistAddress(e.target.value)}
              />
              <select
                value={whitelistStatus}
                onChange={(e) => setWhitelistStatus(e.target.value)}
              >
                <option value="Active">True</option>
                <option value="Inactive">False</option>
              </select>
              <input
                type="text"
                placeholder="Enter data"
                value={whitelistData}
                onChange={(e) => setWhitelistData(e.target.value)}
              />
              <button onClick={handleSetWhitelist}>Set Whitelist</button>
              <p>{status}</p>
              <p className='note'> NOTE: First whitelist user before adding rules...</p>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
