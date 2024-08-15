import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getDatabase } from "firebase/database";
import { getStorage } from "firebase/storage";

const firebaseConfig = {
    apiKey: "AIzaSyDOhS-3dCzjlKS3WKrUI5OwQWgoIlD4M7A",
    authDomain: "onchainid.firebaseapp.com",
    databaseURL: "https://onchainid-default-rtdb.firebaseio.com",
    projectId: "onchainid",
    storageBucket: "onchainid.appspot.com",
    messagingSenderId: "1055162437827",
    appId: "1:1055162437827:web:81dc91a985dde07bdf5276",
    measurementId: "G-QJJ9QEW882"
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const database = getDatabase(app);
const storage = getStorage(app);

export { app, auth, database, storage };
