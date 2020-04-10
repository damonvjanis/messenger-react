import React from 'react';
import { Router, Redirect } from '@reach/router';
import Cookies from 'js-cookie';

const AuthCheck = ({ component: Component, path, ...rest }) => {
  const token = Cookies.get('token');

  if (token) {
    return (
      <Router>
        <Component path={path} {...rest} />
      </Router>
    );
  }

  return <Redirect to='/login' noThrow />;
};

export default AuthCheck;
