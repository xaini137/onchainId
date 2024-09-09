import './App.css';
import React, { useState, useEffect } from 'react';
import { getAuth, onAuthStateChanged } from "firebase/auth";
import { ref as databaseRef, set } from "firebase/database";
import { ref as storageRef, uploadBytes, getDownloadURL } from "firebase/storage";
import { auth, database, storage } from './firebase';
import Loginpage from './components/Loginpage';
import Signuppage from './components/SingUppage';
import { BrowserRouter as Router, Switch, Route, useHistory } from "react-router-dom";
import Admin from './components/admin';
import Navbar from './components/Navbar';
import { checkIfAdmin } from './utils/adminCheck';
import UserTable from './components/userListShow'; // Import the UserTable component
import BecomeAdmin from './components/becomeadmin';
import Topic from './components/topic';
import ERC1404 from './components/contract/erc1404Whitelist';
import AddTopic from './components/contract/addTopic';
import Auction from './components/contract/auction';
import AppointClaim from './components/contract/AppointClaim';
import IssueClaim from './components/contract/issueClaim';
function App() {
  const [user, setUser] = useState(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [loading, setLoading] = useState(true);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [documentDetail, setDocumentDetail] = useState('');
  const [metaMaskAddress, setMetaMaskAddress] = useState('');
  const [isMetaMaskConnected, setIsMetaMaskConnected] = useState(false);
  const [file, setFile] = useState(null);
  const [progress, setProgress] = useState(0);
  const [url, setUrl] = useState('');
  const history = useHistory();

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        setUser(user);
        const adminStatus = await checkIfAdmin(user);
        setIsAdmin(adminStatus);
      } else {
        setUser(null);
        setIsAdmin(false);
        // history.push('/signup'); // Using history.push in v5
      }
      setLoading(false);
    });
  
    return () => unsubscribe();
  }, [history]);
  

  const handleInputChange = (e) => {
    const { name, value, files } = e.target;
    if (name === 'name') setName(value);
    if (name === 'email') setEmail(value);
    if (name === 'metaMaskAddress') setMetaMaskAddress(value);
    if (name === 'documentDetail') setDocumentDetail(value);
    if (name === 'document') {
      if (files && files.length > 0) setFile(files[0]);
    }
  };

  const handleMetaMaskConnect = async () => {
    if (!window.ethereum) {
      alert('MetaMask is not installed. Please install it to use this feature.');
      return;
    }

    try {
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      const account = accounts[0]; // Get the first account
      // setMetaMaskAddress(account); // Set the MetaMask address state
      setIsMetaMaskConnected(true);
    } catch (error) {
      console.error("MetaMask connection error:", error);
      alert('Failed to connect MetaMask: ' + error.message);
    }
  };

  const handleUpload = async () => {
    if (!file) return '';

    const storageReference = storageRef(storage, `uploads/${file.name}`);

    try {
      const snapshot = await uploadBytes(storageReference, file);
      const progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
      setProgress(progress);
      const downloadURL = await getDownloadURL(storageReference);
      return downloadURL;
    } catch (error) {
      console.error('Error uploading file:', error);
      throw error; // Rethrow to handle in saveDataToFirebase
    }
  };

  const saveDataToFirebase = async () => {
    if (!user) {
      alert("No authenticated user");
      return;
    }

    let downloadURL = '';
    if (file) {
      try {
        downloadURL = await handleUpload();
      } catch (error) {
        alert('Failed to upload file: ' + error.message);
        return;
      }
    }

    const userRef = databaseRef(database, 'investors/' + user.uid);
    set(userRef, {
      name: name,
      email: email,
      metaMaskAddress: metaMaskAddress,
      documentDetail: documentDetail,
      documentURL: downloadURL
    }).then(() => {
      alert('Data saved successfully');
    }).catch((error) => {
      alert('Failed to save data: ' + error.message);
    });
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <Router>
      <Navbar user={user} />
      <Switch>
        <Route path="/signup">
          <Signuppage />
        </Route>
        <Route path="/savetopic">
          <Topic />
        </Route>
        <Route path="/becomeAdmin">
          <BecomeAdmin />
        </Route>
        <Route path="/admin">
          {user ? (isAdmin ? <Admin /> : <div>Access Denied</div>) : <Loginpage />}
        </Route>
        <Route path="/user-list">
          <UserTable />
        </Route>
        <Route path="/issueClaim">
          <IssueClaim />
        </Route>
        <Route path="/appoint-claim">
          <AppointClaim />
        </Route>
        <Route path="/topic">
          <Topic />
        </Route>
        <Route path="/erc1404">
          <ERC1404 />
        </Route>
        <Route path="/contract">
          <AddTopic />
        </Route>
        <Route path="/auction">
          <Auction />
        </Route>
        <Route path="/">
          {user ? (
            <div className="App">
              <h1>{user.displayName}</h1>
              <h4>Email: {user.email}</h4>
              {!isMetaMaskConnected ? (
                <button onClick={handleMetaMaskConnect}>Connect MetaMask</button>
              ) : (
                <div>
                  <div>
                    <label className="label">NAME</label>
                    <input
                      type="text"
                      name="name"
                      placeholder="Enter your name"
                      value={name}
                      onChange={handleInputChange}
                    />
                  </div>
                  <div>
                    <label className="label">EMAIL</label>
                    <input 
                      type="email"
                      name="email"
                      placeholder="Enter your email"
                      value={email}
                      onChange={handleInputChange}
                    />
                  </div>
                  <div>
                    <label className="label">DOCUMENT DETAIL</label>
                    <label className="label-1">Upload Document : </label>  
                    <input
                      type="file"
                      name="document"
                      onChange={handleInputChange}
                    />
                  </div>
                  <div>
                    <label className="label-1">Enter Unique Id :</label> 
                    <input
                      type="text"
                      name="documentDetail"
                      placeholder="Enter your unique ID"
                      value={documentDetail}
                      onChange={handleInputChange}
                    />
                  </div>

                  <div>
  <label className="label">MetaMask Address</label>
  <input
    type="text"
    name="metaMaskAddress"
    placeholder="MetaMask address"
    value={metaMaskAddress}
    onChange={handleInputChange} // Allow the address to be edited
  />
</div>
                  <br />
                  <button onClick={saveDataToFirebase}>Submit</button>
                </div>
              )}
            </div>
          ) : (
            <Loginpage />
          )}
        </Route>
      </Switch>
    </Router>
  );
}

export default App;
