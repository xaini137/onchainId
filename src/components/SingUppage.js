import React, { useState } from 'react';
import { getAuth, createUserWithEmailAndPassword } from "firebase/auth";
import { app } from '../firebase';
import { Link } from 'react-router-dom';
const auth = getAuth(app);
export default function SignUppage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const createUser = () => {
    createUserWithEmailAndPassword(auth, email, password)
      .then((userCredential) => {
        console.log("Success:", userCredential);
        alert("Sign up successful!");
      })
      .catch((error) => {
        console.error("Error:", error);
        alert("Sign up failed: " + error.message);
      });
  };
  return (
    <>
      <form>
        <h1 className='my-3'>Sign Up Page</h1>
        <div className="form-outline mb-4 my-4 w-25">
          <input 
            onChange={e => setEmail(e.target.value)} 
            value={email} 
            type="email" 
            id="form2Example1" 
            className="form-control" 
            placeholder="Enter your email"
          />
          <label className="form-label" htmlFor="form2Example1">Email address</label>
        </div>
        <div className="form-outline mb-4 w-25">
          <input 
            onChange={e => setPassword(e.target.value)} 
            value={password} 
            type="password" 
            id="form2Example2" 
            className="form-control" 
            placeholder="Enter your password"
          />
          <label className="form-label" htmlFor="form2Example2">Password</label>
        </div>
        <button 
          type="button" 
          onClick={createUser} 
          className="btn btn-primary btn-block mb-4"
        >
          Sign Up
        </button>

        <div className="text-center">
          <p>Already a member? <Link to="/">Login</Link></p>
        </div>
      </form>
    </>
  );
}
