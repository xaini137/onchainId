import * as admin from 'firebase-admin';

// Initialize Firebase Admin SDK with your service account credentials

const serviceAccount = {
    apiKey: "AIzaSyDOhS-3dCzjlKS3WKrUI5OwQWgoIlD4M7A",
    authDomain: "onchainid.firebaseapp.com",
    databaseURL: "https://onchainid-default-rtdb.firebaseio.com",
    projectId: "onchainid",
    storageBucket: "onchainid.appspot.com",
    messagingSenderId: "1055162437827",
    appId: "1:1055162437827:web:81dc91a985dde07bdf5276",
    measurementId: "G-QJJ9QEW882"
};
if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL: "https://onchainid-default-rtdb.firebaseio.com" // Replace with your database URL
    });
}

const db = admin.database();
const auth = admin.auth();
const storage = admin.storage().bucket();

export { db, auth, storage };
