import { useState, useEffect } from "react";
// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAuth, createUserWithEmailAndPassword, onAuthStateChanged, signOut, signInWithEmailAndPassword } from "firebase/auth";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyCwjEBRWww6kh-rXT9LPLFR1DHpNm5hrpU",
  authDomain: "conimal-47728.firebaseapp.com",
  projectId: "conimal-47728",
  storageBucket: "conimal-47728.appspot.com",
  messagingSenderId: "687583269450",
  appId: "1:687583269450:web:0a3671a8f637dffd638cb3"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth();

export function signup(email, password) {
  return createUserWithEmailAndPassword(auth, email, password);
}

export function login(email, password) {
  return signInWithEmailAndPassword(auth, email, password);
}   

export function logout() {
  return signOut(auth);
}

// Custom Hook 
export function useAuth() {
  const [ currentUser, setCurrentUser ] = useState();

  useEffect(() => {
    const unsub = onAuthStateChanged(auth, user => setCurrentUser(user));
    return unsub;
  }, [])

  return currentUser;
}

export { auth }