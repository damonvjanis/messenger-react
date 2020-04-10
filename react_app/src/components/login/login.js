import React, { useState } from 'react';
import { gql, useMutation } from '@apollo/client';
import { navigate } from '@reach/router';
import Cookies from 'js-cookie';

const LOGIN = gql`
  mutation loginMutation($code: String!) {
    login(code: $code) {
      token
    }
  }
`;

const Login = () => {
  const [code, setCode] = useState('');
  const [logIn] = useMutation(LOGIN, {
    onCompleted: ({ login: { token } }) => {
      token
        ? Cookies.set("token", token, { expires: 1 })
        : alert("Invalid code, please try again")

      navigate('../');
      window.location.reload();
    },
    update: (cache, { data: { login: { token } } }) => {
      cache.writeData({
        data: { isLoggedIn: { isLoggedIn: token ? true : false } }
      });
    }
  });

  const handleSubmit = event => {
    event.preventDefault();
    logIn({ variables: { code: code } });
  };

  return (
    <div className='wrapper'>
      <div className='login-wrapper'>
        <h2>Log in to Messenger</h2>
        <form onSubmit={handleSubmit}>
          <input
            className='login-input'
            type='text'
            placeholder='Enter code here'
            value={code}
            onChange={event => setCode(event.target.value)}
          />
          <button className='login-submit' type='submit'>
            Submit
          </button>
        </form>
      </div>
    </div>
  );
};

export default Login;
