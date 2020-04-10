import React from 'react';
import { ApolloProvider } from '@apollo/client';
import { Router } from '@reach/router';
import Login from '../login';
import Messenger from '../messenger';
import AuthCheck from '../auth-check';
import { InMemoryCache, createHttpLink, ApolloClient, split } from '@apollo/client';
import { getMainDefinition } from '@apollo/client/utilities';
import absintheSocketLink from "./absinthe-socket-link";
import { setContext } from 'apollo-link-context';
import Cookies from 'js-cookie';

const uri = process.env.REACT_APP_URL ?
  `https://${process.env.REACT_APP_URL}/api` :
  'http://localhost:4000/api';

const httpLink = createHttpLink({ uri });

const authLink = setContext((_, { headers }) => {
  const token = Cookies.get('token');

  return {
    headers: {
      ...headers,
      authorization: token ? `Bearer ${token}` : "",
    }
  }
});

const splitLink = split(
  ({ query }) => {
    const definition = getMainDefinition(query);
    return (
      definition.kind === 'OperationDefinition' &&
      definition.operation === 'subscription'
    );
  },
  absintheSocketLink,
  authLink.concat(httpLink),
);

const client = new ApolloClient({
  cache: new InMemoryCache({}),
  link: splitLink,
});

const App = () => (
  <ApolloProvider client={client}>
    <Router>
      <Login path='/login' />
      <AuthCheck path='/' component={Messenger} client={client} />
    </Router>
  </ApolloProvider>
);

export default App;
