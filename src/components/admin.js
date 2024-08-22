import React, { useState, useEffect } from 'react';
import { ref, set, push, onValue } from "firebase/database";
import { database } from '../firebase';
import './css/admin.css';

export default function Admin() {
  const [topics, setTopics] = useState([]);
  const [topic, setTopic] = useState('');
  const [hexcode, setHexcode] = useState('');

  const [adminEmail, setAdminEmail] = useState('');
  const [admins, setAdmins] = useState([]);

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

      <div className="input-group-1">
        <label className="label">Add Topic</label>
        <div className="note-container-1">
          <p>NOTE:</p>
          <ul>
            <li>For adding topic to database</li>
            <li>Creating a mapping of string to uint for smart contract</li>
          </ul>
        </div>
        <input
          type="text"
          placeholder="Enter a topic"
          value={topic}
          onChange={handleTopicInputChange}
        />
        <input
          type="text"
          placeholder="Enter hex code"
          value={hexcode}
          onChange={handleHexcodeInputChange}
        />
        <button onClick={saveTopicToFirebase}>Save Topic</button>
      </div>
    </>
  );
}
