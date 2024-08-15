import React from 'react'
import { getAuth,signInWithEmailAndPassword,GoogleAuthProvider,signInWithPopup} from "firebase/auth"
import { app } from '../firebase';
import { useState } from 'react';
import { Link } from 'react-router-dom';
import SignupPage from './SingUppage';
const auth=getAuth(app);
const googleProvide= new GoogleAuthProvider();

export default function Loginpage() {
const[email,setEmail]=useState("");
const [password, setpassword] = useState("");
const singInUser=()=>{
    signInWithEmailAndPassword(auth,email,password).then((value)=>{
      alert("Success",value).catch((err)=>{console.log(err)});
    })
   }
const singupwithGoogle=()=>{
  signInWithPopup(auth,googleProvide)
  console.log("auth",auth);
  console.log("googleProvide..............................",googleProvide);
}
  
  return (
    <>
 <form>
<h1 className='my-3'>Login Page</h1>
<div className="form-outline mb-4 my-4 w-25">
 <input onChange={e=>setEmail(e.target.value)} value={email} type="email" id="form2Example1" className="form-control" />
 <label className="form-label" htmlFor="form2Example1">Email address</label>
</div>

<div className="form-outline mb-4 w-25">
 <input onChange={e=>setpassword(e.target.value)} value={password} type="password" id="form2Example2" className="form-control" />
 <label className="form-label" htmlFor="form2Example2">Password</label>
</div>

<div className="row mb-4">
 <div className="col d-flex justify-content-center">
   
  
 </div>

 <div className="col">
   {/* <a href="#!">Forgot password?</a> */}
 </div>
</div>

<button type="button" onClick={singInUser} className="btn btn-primary btn-block mb-4">Sign In</button>
<button type="button" onClick={singupwithGoogle}className="btn btn-danger btn-block mb-4 ml-3 ">Sigin with Google</button>

<div className="text-center">
 <p>Not a member? <Link to="/signup">Register</Link></p>
 {/* <p>or sign up with:</p>
 <button type="button" className="btn btn-link btn-floating mx-1">
   <i className="fab fa-facebook-f"></i>
 </button>

 <button type="button" className="btn btn-link btn-floating mx-1">
   <i className="fab fa-google"></i>
 </button>

 <button type="button" className="btn btn-link btn-floating mx-1">
   <i className="fab fa-twitter"></i>
 </button> */}

 {/* <button type="button" className="btn btn-link btn-floating mx-1">
   <i className="fab fa-github"></i>
 </button> */}
</div>
</form>
    
    </>
  )
}
