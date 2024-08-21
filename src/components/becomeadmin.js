import React, { useState } from 'react';
import { ref, push, set } from "firebase/database";
import { database } from '../firebase';

export default function BecomeAdmin() {
  const [email, setEmail] = useState('');

  const handleInputChange = (e) => {
    setEmail(e.target.value);
  };

  const registerAdmin = () => {
    const adminsRef = ref(database, 'admins');
    const newAdminRef = push(adminsRef);
    set(newAdminRef, email).then(() => {
      alert('You have been registered as an admin');
      setEmail('');
    }).catch((error) => {
      alert('Failed to register: ' + error.message);
    });
  };

  return (
    <div cl
    assName="become-admin-container">
      <h2>Become an Admin</h2>
      <div className="input-group">
        <label className="label">Your Email</label>
        <input
          type="email"
          name="email"
          placeholder="Enter your email"
          value={email}
          onChange={handleInputChange}
        />
        <button onClick={registerAdmin}>Register as Admin</button>
      </div>
    </div>
  );
}
