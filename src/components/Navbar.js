import React, { useState, useEffect } from 'react';
import { signOut, onAuthStateChanged } from "firebase/auth";
import { auth } from '../firebase';
import { checkIfAdmin } from '../utils/adminCheck';
import { Link, useHistory } from 'react-router-dom';

export default function Navbar() {
  const [user, setUser] = useState(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [loading, setLoading] = useState(true);
  const history = useHistory();

  const handleSignOut = () => {
    signOut(auth).then(() => {
      history.push('/signup'); // Redirect to signup page after sign out
    }).catch((error) => {
      console.error("Error signing out:", error);
    });
  };

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        setUser(user);
        const adminStatus = await checkIfAdmin(user);
        setIsAdmin(adminStatus);
      } else {
        setUser(null);
        setIsAdmin(false);
        history.push('/signup');
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, [history]);

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <nav className="navbar navbar-expand-lg navbar-dark bg-dark">
      <div className="container-fluid">
        <Link className="navbar-brand" to="#">IDENTITY CREATOR</Link>
        <button
          className="navbar-toggler"
          type="button"
          data-bs-toggle="collapse"
          data-bs-target="#navbarSupportedContent"
          aria-controls="navbarSupportedContent"
          aria-expanded="false"
          aria-label="Toggle navigation"
        >
          <span className="navbar-toggler-icon"></span>
        </button>
        <div className="collapse navbar-collapse" id="navbarSupportedContent">
          <ul className="navbar-nav me-auto mb-2 mb-lg-0">
            {user && (
              <li className="nav-item">
                <Link className="nav-link" to="/">HOME</Link>
              </li>
            )}
            {user && isAdmin && (
              <li className="nav-item">
                <Link className="nav-link" to="/admin">ADMIN</Link>
              </li>
            )}
            {user && isAdmin && (
              <li className="nav-item">
                <Link className="nav-link" to="/user-list">USER LIST</Link>
              </li>
            )}
          </ul>
          {user && (
            <ul className="navbar-nav ms-auto mb-2 mb-lg-0">
              <li className="nav-item">
                <span className="nav-link" style={{ cursor: 'pointer' }} onClick={handleSignOut}>SIGN OUT</span>
              </li>
            </ul>
          )}
        </div>
      </div>
    </nav>
  );
}
