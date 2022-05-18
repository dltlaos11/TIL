import { async } from "@firebase/util";
import { useRef, useState } from "react";

import { signup, login, useAuth, logout, auth } from './firebase';
import { useAuthState } from 'react-firebase-hooks/auth';

export default function App() {
  const [user, loading, error] = useAuthState(auth);

  const [ loading1, setLoading ] = useState(false);
  const currentUser = useAuth();

  const emailRef = useRef();
  const passwordRef = useRef();

  async function handleLogin() {

    setLoading(true);
    try{
    await login(emailRef.current.value, passwordRef.current.value);
    }
    catch{
      alert("Error !");
    }
    setLoading(false);

  } // createUserWithEmailAndPassword return 값 

  async function handleSignup() {

    setLoading(true);
    // try{
    await signup(emailRef.current.value, passwordRef.current.value);
    // }
    // catch{
      // alert("Error !");
    // }
    setLoading(false);

  }

  async function handleLogout() {
    setLoading(true);
    try {
      await logout();
    } catch {
      alert("Error !");
    }
    setLoading(false);
  }

  return (
    <div id="main">

      <div>Currently logged in as : { currentUser?.email }</div>

      <div id="fields">
        <input ref = {emailRef} placeholder='Email' />
        <input ref={passwordRef} placeholder='Password' type="Password" />
      </div>

      <button disabled = { loading1 || currentUser } onClick={handleSignup}>Sign up</button>
      <button disabled = { loading1 || currentUser } onClick={handleLogin}>Log In</button>

      <button disabled = { loading1 || !currentUser } onClick={handleLogout}>Log out</button>
      

    </div>
  )
}