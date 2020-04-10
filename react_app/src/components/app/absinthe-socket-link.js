import * as AbsintheSocket from '@absinthe/socket';
import { createAbsintheSocketLink } from '@absinthe/socket-apollo-link';
import { Socket as PhoenixSocket } from 'phoenix';
import Cookies from 'js-cookie';

const socket_url = process.env.REACT_APP_URL ?
  `ws://${process.env.REACT_APP_URL}/socket` :
  'ws://localhost:4000/socket';

export default createAbsintheSocketLink(
  AbsintheSocket.create(
    new PhoenixSocket(socket_url, {
      params: () => {
        if (Cookies.get('token')) {
          return { token: Cookies.get('token') };
        } else {
          return {};
        }
      }
    })
  )
);
