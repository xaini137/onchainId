import React, { useState, useEffect } from 'react';
import { ref, set, push, onValue } from "firebase/database";
import { database } from '../firebase';
import './css/admin.css';
export default function Admin() {
  const [topic, setTopic] = useState('');
  const [topics, setTopics] = useState([]);
  const [adminEmail, setAdminEmail] = useState('');
  const [admins, setAdmins] = useState([]);
  
  useEffect(() => {
    // Load topics
    const topicsRef = ref(database, 'topics');
    onValue(topicsRef, (snapshot) => {
      const data = snapshot.val();
      if (data) {
        setTopics(Object.entries(data).map(([key, value]) => ({ key, value })));
      }
    });
    
    // Load admins
    const adminsRef = ref(database, 'admins');
    onValue(adminsRef, (snapshot) => {
      const data = snapshot.val();
      if (data) {
        setAdmins(Object.entries(data).map(([key, value]) => ({ key, value })));
      }
    });
  }, []);
  
  // const handleTopicInputChange = (e) => {
  //   setTopic(e.target.value);
  // };
  
  const handleAdminInputChange = (e) => {
    setAdminEmail(e.target.value);
  };
  
  // const saveTopicToFirebase = () => {
  //   const topicsRef = ref(database, 'topics');
  //   const newTopicRef = push(topicsRef);
  //   set(newTopicRef, topic).then(() => {
  //     alert('Topic saved successfully');
  //     setTopic('');
  //   }).catch((error) => {
  //     alert('Failed to save topic: ' + error.message);
  //   });
  // };
  
  const addAdminToFirebase = () => {
    // Ensure adminEmail is valid and unique logic here
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
    <div>
      <h1>Admin</h1>
      
      {/* <div>
        <h2>Manage Topics</h2>
        <label className="label">Add Topic</label>
        <input
          type="text"
          name="topic"
          placeholder="Enter a topic"
          value={topic}
          onChange={handleTopicInputChange}
        />
        <button onClick={saveTopicToFirebase}>Save Topic</button>
      </div> */}
      
      {/* <div>
        <label className="label">Select Topic</label>
        <select>
          <option value="">Select a topic</option>
          {topics.map((topic) => (
            <option key={topic.key} value={topic.value}>{topic.value}</option>
          ))}
        </select>
      </div> */}
      
      <div>
        <h2>Manage Admins</h2>
        <label className="label">Add Admin (Email)</label>
        <input
          type="email"
          name="adminEmail"
          placeholder="Enter admin email"
          value={adminEmail}
          onChange={handleAdminInputChange}
        />
        <button onClick={addAdminToFirebase}>Add Admin</button>
      </div>
      
      <div>
        <label className="label">Admin List</label>
        <ul>
          {admins.map((admin) => (
            <li key={admin.key}>{admin.value}</li>
          ))}
        </ul>
      </div>
    </div>
  );
}
