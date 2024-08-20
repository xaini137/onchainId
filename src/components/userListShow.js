import React, { useState, useEffect } from 'react';
import { ref as databaseRef, get, update } from "firebase/database";
import { database } from '../firebase';
import './css/userListShow.css';
import axios from 'axios';

const UserTable = () => {
    const [users, setUsers] = useState([]);
    const [selectedUser, setSelectedUser] = useState(null);
    const [showRejectPopup, setShowRejectPopup] = useState(false);
    const [showErrorPopup, setShowErrorPopup] = useState(false);
    const [errorMessage, setErrorMessage] = useState('');
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        const fetchUsers = async () => {
            try {
                const usersRef = databaseRef(database, 'investors');
                const snapshot = await get(usersRef);
                if (snapshot.exists()) {
                    const usersData = Object.entries(snapshot.val()).map(([id, user]) => ({
                        id,
                        ...user,
                        onchsinid: user.onchsinid || null, // Ensure onchsinid is present
                    }));
                    console.log(usersData);
                    setUsers(usersData);
                    // Fetch identities
                    for (const user of usersData) {
                        if (!user.onchsinid) {
                            const identity = await checkOnchainId(user.metaMaskAddress);
                            await updateUserIdentity(user.id, identity);
                        }
                    }
                } else {
                    console.log("No data available");
                }
            } catch (error) {
                console.error("Error fetching users:", error);
            }
        };

        fetchUsers();
    }, []);

    const checkOnchainId = async (userAddress) => {
        try {
            const response = await axios.post('http://127.0.0.1:8080/get_identity', {
                userAddress: userAddress,
            });
        
            if (response.status === 200 && response.data.identity) {
                console.log("log here ", response.data.identity);
                return response.data.identity; // Return the fetched identity
            } else {
                return null; // Return null if no identity is found
            }
        } catch (error) {
            console.error("Error fetching onchain ID:", error);
            return null;
        }
    };

    const updateUserIdentity = async (userId, identity) => {
        try {
            const userRef = databaseRef(database, `investors/${userId}`);
            await update(userRef, { onchsinid: identity });
            // Refresh user list after updating
            const usersRef = databaseRef(database, 'investors');
            const snapshot = await get(usersRef);
            if (snapshot.exists()) {
                const usersData = Object.entries(snapshot.val()).map(([id, user]) => ({
                    id,
                    ...user
                }));
                setUsers(usersData);
            }
        } catch (error) {
            console.error("Error updating user identity:", error);
        }
    };

    const handleStatusChange = async (userId, status) => {
        setLoading(true); // Start loader
        try {
            const userRef = databaseRef(database, `investors/${userId}`);
            const userSnapshot = await get(userRef);

            if (userSnapshot.exists()) {
                const user = userSnapshot.val();
                const userAddress = user.metaMaskAddress;
                const salt = userAddress;

                await update(userRef, { status });

                if (status === 1) {
                    const response = await axios.post('https://onchainid-3.onrender.com/create', {
                        userAddress: userAddress,
                        salt: salt,
                    });

                    if (response.status === 200 && response.data.success) {
                        const { identity } = response.data;
                        await update(userRef, { onchsinid: identity });
                    } else {
                        setErrorMessage(response.data.message || 'An error occurred.');
                        setShowErrorPopup(true);
                    }
                }

                const usersRef = databaseRef(database, 'investors');
                const snapshot = await get(usersRef);
                if (snapshot.exists()) {
                    const usersData = Object.entries(snapshot.val()).map(([id, user]) => ({
                        id,
                        ...user
                    }));
                    setUsers(usersData);
                }
                setShowRejectPopup(false);
            } else {
                console.log("User data not found");
            }
        } catch (error) {
            console.error("Error updating status:", error);
            setErrorMessage('Failed to update status.');
            setShowErrorPopup(true);
        } finally {
            setLoading(false); // Stop loader
        }
    };

    const handleRejectClick = (user) => {
        setSelectedUser(user);
        setShowRejectPopup(true);
    };

    const handlePopupClose = () => {
        setShowRejectPopup(false);
        setSelectedUser(null);
    };

    const handleErrorPopupClose = () => {
        setShowErrorPopup(false);
        setErrorMessage('');
    };

    return (
        <div className={`user-table-container ${loading ? 'blurred-content' : ''}`}>
            <h2>All Investor</h2>
            <table className="user-table">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>MetaMask Address</th>
                        <th>onchain ID</th>
                        <th>Document Detail</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    {users.map((user) => (
                        <tr key={user.id}>
                            <td>{user.name}</td>
                            <td>{user.email}</td>
                            <td>{user.metaMaskAddress}</td>
                            <td>{user.onchsinid || "N/A"}</td>
                            <td>{user.documentDetail}</td>
                            <td>
                                <div className="action-buttons">
                                    {user.status === 1 ? (
                                        <span className="created">Accepted</span>
                                    ) : user.status === 2 ? (
                                        <span className="rejected">Rejected</span>
                                    ) : (
                                        <>
                                            <button
                                                className="accept-button"
                                                onClick={() => handleStatusChange(user.id, 1)}
                                            >
                                                Accept
                                            </button>
                                            <button
                                                className="reject-button"
                                                onClick={() => handleRejectClick(user)}
                                            >
                                                Reject
                                            </button>
                                        </>
                                    )}
                                </div>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>

            {loading && (
                <div className="loader-container">
                    <div className="loader"></div>
                    <p>Loading...</p>
                </div>
            )}

            {showRejectPopup && selectedUser && (
                <div className="popup-overlay">
                    <div className="popup-content">
                        <h3>Reject User</h3>
                        <p>Email: {selectedUser.email}</p>
                        <p>Are you sure you want to reject this user?</p>
                        <button
                            className="confirm-button"
                            onClick={() => handleStatusChange(selectedUser.id, 2)}
                        >
                            Confirm
                        </button>
                        <button
                            className="cancel-button"
                            onClick={handlePopupClose}
                        >
                            Cancel
                        </button>
                    </div>
                </div>
            )}

            {showErrorPopup && (
                <div className="popup-overlay">
                    <div className="popup-content">
                        <h3>Error</h3>
                        <p>{errorMessage}</p>
                        <button
                            className="close-button"
                            onClick={handleErrorPopupClose}
                        >
                            Close
                        </button>
                    </div>
                </div>
            )}
        </div>
    );
};

export default UserTable;
