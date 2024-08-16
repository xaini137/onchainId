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
    const topicsRef = ref(database, 'topics');
    onValue(topicsRef, (snapshot) => {
      const data = snapshot.val();
      if (data) {
        setTopics(Object.entries(data).map(([key, value]) => ({ key, value })));
      }
    });

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

  const handleAdminInputChange = (e) => {
    setAdminEmail(e.target.value);
  };

  const saveTopicToFirebase = () => {
    const topicsRef = ref(database, 'topics');
    const newTopicRef = push(topicsRef);
    set(newTopicRef, topic).then(() => {
      alert('Topic saved successfully');
      setTopic('');
    }).catch((error) => {
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
            <input
              type="email"
              name="adminEmail"
              placeholder="Enter email"
              value={adminEmail}
              onChange={handleAdminInputChange}
            />
            <button onClick={addAdminToFirebase}>Add Admin</button>
          </div>
          <div className="input-group">
            <label className="label">Add Topic</label>
         
              <input
                type="text"
                name="topic"
                placeholder="Enter a topic"
                value={topic}
                onChange={handleTopicInputChange}
              />
              <button onClick={saveTopicToFirebase}>Save Topic</button>
        
          </div>
          {/* <div className="input-group">
            <label className="label">Select Topic</label>
            <select>
              <option value="">Select a topic</option>
              {topics.map((topic) => (
                <option key={topic.key} value={topic.value}>{topic.value}</option>
              ))}
            </select>
          </div> */}

        </div>
      </div>
    </div>
  );
}
