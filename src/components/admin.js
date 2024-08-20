import React, { useState, useEffect } from 'react';
import { ref, set, push, onValue } from "firebase/database";
import { database } from '../firebase';
import './css/admin.css';

export default function Admin() {

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


  const handleAdminInputChange = (e) => {
    setAdminEmail(e.target.value);
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
    
        </div> 
      </div>
    </div>
  );
}
