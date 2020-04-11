// Implement subscriptions for message status
// Implement subscriptions for new message
// Infinite scroll on conversation list
// Infinite scroll on messages list

import React, { useState, useEffect } from 'react';
import { gql, useQuery, useLazyQuery, useMutation } from '@apollo/client';
import { AsYouType, parsePhoneNumberFromString } from 'libphonenumber-js';

const GET_CONVERSATIONS = gql`
  query getConversationsOrdered($search: String, $cursor: String) {
    getConversationsOrdered(search: $search, cursor: $cursor) {
      cursor,
      conversations {
        id
        name
        number
        mostRecentMessage {
          id
          body
          type
          direction
          status
          insertedAt
          attachmentUrl
        }
        messages {
          id
          body
          type
          direction
          status
          insertedAt
          attachmentUrl
        }
      }
    }
  }
`;

const GET_CONVERSATION_BY_NUMBER = gql`
  query getConversationByNumber($number: String!) {
    getConversationByNumber(number: $number) {
      id
      name
      number
      messages {
        id
        body
        type
        direction
        status
        insertedAt
        attachmentUrl
      }
    }
  }
`;

const GET_CLOUDINARY_URL = gql`
  query getCloudinaryUrl {
    getCloudinaryUrl {
      url
    }
  }
`;

const UPDATE_CONVERSATION_NAME = gql`
  mutation updateConversationName($id: ID!, $name: String!) {
    updateConversationName(id: $id, name: $name) {
      id
      name
    }
  }
`;

const CONVERSATION_READ = gql`
  mutation conversationRead($id: ID!) {
    conversationRead(id: $id) {
      id
    }
  }
`;

const CREATE_CONVERSATION_AND_MESSAGE = gql`
  mutation createConversationAndMessage(
    $number: String!
    $body: String
    $attachmentUrl: String
    $urlType: String
  ) {
    createConversationAndMessage(
      number: $number
      body: $body
      attachmentUrl: $attachmentUrl
      urlType: $urlType
    ) {
      id
      __typename
      name
      number
      mostRecentMessage {
        id
        body
        type
        direction
        status
        insertedAt
        attachmentUrl
      }
      messages {
        id
        body
        type
        direction
        status
        insertedAt
        attachmentUrl
      }
    }
  }
`;

const CREATE_MESSAGE = gql`
  mutation createMessage(
    $conversationId: ID!
    $body: String
    $attachmentUrl: String
    $urlType: String
  ) {
    createMessage(
      conversationId: $conversationId
      body: $body
      attachmentUrl: $attachmentUrl
      urlType: $urlType
    ) {
      id
      body
      type
      direction
      status
      insertedAt
      attachmentUrl
    }
  }
`;

const MESSAGE_ADDED_SUBSCRIPTION = gql`
  subscription messageAdded {
    messageAdded {
      id
      body
      type
      direction
      status
      insertedAt
      attachmentUrl
      conversation {
        id
      }
    }
  }
`;

const MESSAGE_UPDATED_SUBSCRIPTION = gql`
  subscription messageUpdated {
    messageUpdated {
      id
      body
      type
      direction
      status
      insertedAt
      attachmentUrl
      conversation {
        id
      }
    }
  }
`;

const CONVERSATION_UPDATED_SUBSCRIPTION = gql`
  subscription conversationUpdated {
    conversationUpdated {
      id
      name
    }
  }
`;

const Conversation = ({ conversation, setCurrentConversation, clickAction }) => {
  return (
    <div
      className='conversation'
      onClick={() => {
        setCurrentConversation(conversation)
        clickAction(conversation.id)
      }}
    >
      <div className='name'>{conversation.name || conversation.number}</div>
      <div className='last-message'>
        {conversation.mostRecentMessage
          ? conversation.mostRecentMessage.body || 'Attachment'
          : 'No Messages'}
      </div>
    </div>
  );
};

const ConversationList = ({ conversations, setCurrentConversation, onLoadMore }) => {
  const [conversationRead] = useMutation(CONVERSATION_READ);

  const scrollCheck = e => {
    const list = document.getElementById('conversation-list');

    if (list.scrollHeight - e.target.scrollTop === list.clientHeight) {
      onLoadMore();
    }
  };

  const clickAction = id => {
    conversationRead({ variables: { id: id } });
  }

  return (
    <div
      id='conversation-list'
      className='conversation-list'
      onScroll={(e) => scrollCheck(e)}
    >
      <div
        className='conversation'
        onClick={() => setCurrentConversation('new')}
      >
        <div>
          <b>+ </b>New Conversation
        </div>
      </div>

      {conversations.map(conversation => (
        <Conversation
          conversation={conversation}
          setCurrentConversation={setCurrentConversation}
          key={conversation.number}
          clickAction={clickAction}
        ></Conversation>
      ))}
    </div>
  );
};

const ConversationSearch = ({ refetchConversations }) => {
  const handleChange = searchTerm => {
    refetchConversations({ search: searchTerm });
  };

  return (
    <div className='conversation-search'>
      <input
        className='conversation-search-input'
        type='text'
        placeholder='Search'
        onChange={e => handleChange(e.target.value)}
      />
    </div>
  );
};

const ConversationSelector = ({
  conversations,
  setCurrentConversation,
  onLoadMore,
  refetchConversations,
  subscribeToAddedMessages,
  subscribeToUpdatedMessages,
  subscribeToUpdatedConversation
}) => {
  useEffect(() => {
    subscribeToAddedMessages();
    subscribeToUpdatedMessages();
    subscribeToUpdatedConversation();
  });

  return (
    <div className='conversation-selector'>
      <ConversationSearch
        refetchConversations={refetchConversations}
      ></ConversationSearch>

      <ConversationList
        conversations={conversations}
        setCurrentConversation={setCurrentConversation}
        onLoadMore={onLoadMore}
      ></ConversationList>
    </div>
  );
};

const NewConversationContactInfo = ({
  newNumber,
  setNewNumber,
  setNewConversationReadyToSend,
  getConversationByNumber
}) => {
  const formatNumber = newNumber => {
    const sanitized = newNumber.replace(/\D/g, '');

    const formattedNumber = new AsYouType('US').input(sanitized);

    setNewNumber(formattedNumber);
    const parsed = parsePhoneNumberFromString(formattedNumber, 'US');

    if (parsed && parsed.isValid()) {
      getConversationByNumber({ variables: { number: parsed.number } });
      setNewConversationReadyToSend(true);
    } else {
      setNewConversationReadyToSend(false);
    }
  };

  return (
    <div className='contact-info'>
      <input
        className='phone-number-input'
        type='text'
        placeholder={'Please Enter a Phone Number'}
        value={newNumber}
        onChange={e => formatNumber(e.target.value)}
      />
    </div>
  );
};

const ContactInfo = ({ currentConversationId, client }) => {
  const conversation = client.readFragment(
    {
      id: `Conversation:${currentConversationId}`,
      fragment: gql`
        fragment currentConversationContactInfo on Conversation {
          id
          name
          number
        }
      `
    },
    true
  );

  const [updateName] = useMutation(UPDATE_CONVERSATION_NAME);

  const handleChange = event => {
    updateName({
      variables: { id: currentConversationId, name: event.target.value }
    });
  };

  if (!conversation)
    return (
      <div className='contact-info'>
        <input
          className='contact-name-input'
          type='text'
          placeholder={'No Name'}
          value={''}
          onChange={e => handleChange(e)}
        />
        <div className='number'></div>
      </div>
    );

  return (
    <div className='contact-info'>
      <input
        className='contact-name-input'
        type='text'
        placeholder={'No Name'}
        value={conversation.name || ''}
        onChange={e => handleChange(e)}
      />
      <div className='number'>{conversation.number}</div>
    </div>
  );
};

const EmptyState = () => (
  <div className='current-conversation-empty-state-wrapper'>
    Welcome to Messenger
  </div>
);

const MessageList = ({ currentConversationId, client }) => {
  const conversation = client.readFragment(
    {
      id: `Conversation:${currentConversationId}`,
      fragment: gql`
        fragment currentConversationMessageList on Conversation {
          messages {
            id
            body
            type
            direction
            status
            insertedAt
            attachmentUrl
          }
        }
      `
    },
    true
  );

  const messageDirectionClass = direction =>
    direction === 'inbound' ? 'message inbound' : 'message';

  const messageStatusClass = status =>
    status === 'failed' ? 'message-body failed' : 'message-body';

  const formatTimestamp = timestamp => {
    const moment = require('moment-timezone');

    return moment
      .tz(timestamp, 'Etc/UTC')
      .tz(moment.tz.guess())
      .format('ddd, MMM Do, h:mm a');
  };

  const messageBody = message => {
    if (message.type === 'text')
      return (
        <div className={messageStatusClass(message.status)}>{message.body}</div>
      );

    if (message.type === 'image')
      return (
        <a
          href={message.attachmentUrl}
          className='message-attachment-container'
          target='_blank'
          rel='noopener noreferrer'
        >
          <img
            className='message-attachment-image'
            src={message.attachmentUrl}
            alt='attachment'
          />
        </a>
      );

    return (
      <div className={messageStatusClass(message.status)}>
        <a href={message.attachmentUrl}>Link to File</a>
      </div>
    );
  };

  const messageTimestamp = message => {
    if (message.status === 'sending')
      return <div className='timestamp'>Sending...</div>;

    if (message.status === 'failed')
      return <div className='timestamp'>Message not Delivered</div>;

    return (
      <div className='timestamp'>{formatTimestamp(message.insertedAt)}</div>
    );
  };

  const buildMessages = messages =>
    messages.map(message => (
      <div className='message-container' key={message.id}>
        <div className={messageDirectionClass(message.direction)}>
          {messageBody(message)}
          {messageTimestamp(message)}
        </div>
      </div>
    ));

  const messages = (conversation && conversation.messages) || [];

  if (messages.length === 0) return <div className='message-list'></div>;

  return <div className='message-list'>{buildMessages(messages)}</div>;
};

const MessageInput = ({
  currentConversationId,
  sendMessage,
  newConversationReadyToSend,
  messageInputText,
  messageInputURL,
  setMessageInputTextByConversation,
  setMessageInputURLByConversation
}) => {
  const { data } = useQuery(GET_CLOUDINARY_URL);

  const handleSubmit = event => {
    event.preventDefault();
    sendMessage();
  };

  // Uploads to Cloudinary to get url
  const fileUpload = e => {
    e.preventDefault();

    const file = e.target.files[0];

    if (file.size > 1000000) {
      alert('File size too big, limit is 1MB');
      return;
    }

    // Optimistic response
    setMessageInputURLByConversation(currentConversationId, 'optimisticUrl');

    const url = data ? data.getCloudinaryUrl.url : '';
    const xhr = new XMLHttpRequest();
    const fd = new FormData();
    xhr.open('POST', url, true);
    xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');

    xhr.onreadystatechange = function (e) {
      if (xhr.readyState === 4 && xhr.status === 200) {
        const response = JSON.parse(xhr.responseText);
        setMessageInputURLByConversation(currentConversationId, response);
      }
    };

    fd.append('upload_preset', 'attachments');
    fd.append('file', file);
    xhr.send(fd);

    // Reset file element
    e.target.value = null;
  };

  const submitOnEnter = e => {
    if (e.keyCode === 13 && e.shiftKey === false) {
      e.preventDefault();
      sendMessage();
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <div className='message-input'>
        <textarea
          className='message-input-textarea'
          rows='2'
          placeholder='Write your message here'
          disabled={!newConversationReadyToSend}
          onChange={e =>
            setMessageInputTextByConversation(
              currentConversationId,
              e.target.value
            )
          }
          onKeyDown={submitOnEnter}
          value={messageInputText[currentConversationId] || ''}
        ></textarea>

        <div className='message-buttons'>
          <button
            className='message-submit'
            type='submit'
            disabled={!newConversationReadyToSend}
          >
            Send
          </button>
          {newConversationReadyToSend ? (
            <label className='file-picker-label' htmlFor='attachment'>
              {messageInputURL[currentConversationId]
                ? 'File Selected'
                : 'Add Attachment'}
            </label>
          ) : (
              <label className='file-picker-label-disabled'>Add Attachment</label>
            )}
          <input
            className='file-picker'
            type='file'
            id='attachment'
            name='file'
            onChange={fileUpload}
          />
        </div>
      </div>
    </form>
  );
};

const CurrentConversation = ({
  currentConversation,
  setCurrentConversation,
  newConversationReadyToSend,
  setNewConversationReadyToSend,
  client
}) => {
  const [messageInputText, setMessageInputText] = useState({});
  const [messageInputURL, setMessageInputURL] = useState({});
  const [newNumber, setNewNumber] = useState('');
  const [getConversationByNumber, { loading, data, error }] = useLazyQuery(
    GET_CONVERSATION_BY_NUMBER
  );
  const [createConversationAndMessage] = useMutation(
    CREATE_CONVERSATION_AND_MESSAGE
  );

  const [createMessage] = useMutation(CREATE_MESSAGE);

  const setMessageInputTextByConversation = (conversationId, text) => {
    setMessageInputText({ ...messageInputText, [conversationId]: text });
  };

  const setMessageInputURLByConversation = (conversationId, response) => {
    setMessageInputURL({ ...messageInputURL, [conversationId]: response });
  };

  if (
    data &&
    data.getConversationByNumber &&
    newNumber !== '' &&
    newConversationReadyToSend
  ) {
    setCurrentConversation(data.getConversationByNumber);
    setNewNumber('');
  }

  const attachmentType = ({ format }) => {
    if (['png', 'jpg', 'jpeg', 'gif'].includes(format)) return 'image';

    return 'file';
  };

  const buildOptimisticMessages = (text, attachmentResponse) => {
    let textItem;
    let attachmentItem;

    const currentDate = () => {
      const moment = require('moment-timezone');
      return moment.tz('Etc/UTC');
    };

    if (text && text !== '')
      textItem = {
        __typename: 'Message',
        id: -1,
        body: text,
        direction: 'outbound',
        status: 'sending',
        type: 'text',
        insertedAt: currentDate(),
        attachmentUrl: null
      };

    if (attachmentResponse) {
      attachmentItem = {
        __typename: 'Message',
        id: -2,
        body: null,
        direction: 'outbound',
        status: 'sending',
        type: attachmentType(attachmentResponse),
        insertedAt: currentDate(),
        attachmentUrl: attachmentResponse.secure_url
      };
    }

    if (textItem && attachmentItem) return [textItem, attachmentItem];
    if (textItem) return [textItem];
    if (attachmentItem) return [attachmentItem];
  };

  const sendMessage = () => {
    if (
      messageInputText[currentConversation.id] === '' &&
      !messageInputURL[currentConversation.id]
    )
      return;

    if (messageInputURL[currentConversation.id] === 'optimisticUrl') {
      alert('Attachment still loading, please try again');
      return;
    }

    if (currentConversation === 'new') {
      createConversationAndMessage({
        variables: {
          number: newNumber,
          body: messageInputText['new'],
          attachmentUrl: messageInputURL['new']
            ? messageInputURL['new'].secure_url
            : null,
          urlType: messageInputURL['new']
            ? attachmentType(messageInputURL['new'])
            : null
        },
        optimisticResponse: {
          __typename: 'Mutation',
          createConversationAndMessage: {
            id: '0',
            __typename: 'Conversation',
            number: newNumber,
            name: null,
            mostRecentMessage: {
              __typename: 'Message',
              body: messageInputText['new'],
              direction: 'outbound',
              type: 'text',
              insertedAt: '2019-12-02T22:26:08'
            },
            messages: buildOptimisticMessages(messageInputText['new'], messageInputURL['new']
              ? messageInputURL[currentConversation.id]
              : null)
          }
        },
        update: (
          client,
          { data: { createConversationAndMessage: newConversation } }
        ) => {
          const { getConversationsOrdered: { conversations } } = client.readQuery({
            query: GET_CONVERSATIONS
          });

          client.writeQuery({
            query: GET_CONVERSATIONS,
            data: {
              getConversationsOrdered: [
                newConversation,
                ...(conversations || [])
              ]
            }
          });

          setCurrentConversation(newConversation);
        }
      });
      setMessageInputTextByConversation('new', '');
    } else {
      createMessage({
        variables: {
          conversationId: currentConversation.id,
          direction: 'outbound',
          body: messageInputText[currentConversation.id],
          attachmentUrl: messageInputURL[currentConversation.id]
            ? messageInputURL[currentConversation.id].secure_url
            : null,
          urlType: messageInputURL[currentConversation.id]
            ? attachmentType(messageInputURL[currentConversation.id])
            : null
        },
        optimisticResponse: {
          createMessage: buildOptimisticMessages(
            messageInputText[currentConversation.id],
            messageInputURL[currentConversation.id]
              ? messageInputURL[currentConversation.id]
              : null
          )
        },
        update: (client, { data: { createMessage: newMessages } }) => {
          const { getConversationsOrdered: { conversations } } = client.readQuery({
            query: GET_CONVERSATIONS
          });

          const conversation = conversations.find(
            conversation => conversation.id === currentConversation.id
          );

          const updatedConversation = {
            ...conversation,
            messages: [...newMessages, ...(conversation.messages || [])],
            mostRecentMessage: newMessages[0] || conversation.mostRecentMessage
          };

          const otherConversations = conversations.filter(
            conversation => conversation.id !== currentConversation.id
          );

          client.writeQuery({
            query: GET_CONVERSATIONS,
            data: {
              getConversationsOrdered: {
                conversations: [
                  updatedConversation,
                  ...otherConversations
                ]
              }
            }
          });

          // Reset scroll in message list so new message shows
          document
            .getElementsByClassName('message-list')[0]
            .children[0].scrollIntoView({ behavior: 'smooth' });
        }
      });

      setMessageInputText({
        ...messageInputText,
        [currentConversation.id]: ''
      });

      setMessageInputURL({
        ...messageInputURL,
        [currentConversation.id]: null
      });
    }
  };

  if (!currentConversation)
    return (
      <div className='current-conversation'>
        <EmptyState />
        <MessageList currentConversationId={null} client={client} />
      </div>
    );

  if (currentConversation === 'new')
    return (
      <div className='current-conversation'>
        <NewConversationContactInfo
          newNumber={newNumber}
          setNewNumber={setNewNumber}
          setNewConversationReadyToSend={setNewConversationReadyToSend}
          getConversationByNumber={getConversationByNumber}
        />
        <MessageList currentConversationId={null} client={client} />
        <MessageInput
          currentConversationId={'new'}
          sendMessage={sendMessage}
          newConversationReadyToSend={
            newConversationReadyToSend && !loading && !error
          }
          messageInputText={messageInputText}
          messageInputURL={messageInputURL}
          setMessageInputTextByConversation={setMessageInputTextByConversation}
          setMessageInputURLByConversation={setMessageInputURLByConversation}
        />
      </div>
    );

  return (
    <div className='current-conversation'>
      <ContactInfo
        currentConversationId={currentConversation.id}
        client={client}
      />
      <MessageList
        currentConversationId={currentConversation.id}
        client={client}
      />
      <MessageInput
        currentConversationId={currentConversation.id}
        sendMessage={sendMessage}
        messageInputText={messageInputText}
        messageInputURL={messageInputURL}
        newConversationReadyToSend={true}
        setMessageInputTextByConversation={setMessageInputTextByConversation}
        setMessageInputURLByConversation={setMessageInputURLByConversation}
      />
    </div>
  );
};

const Messenger = ({ client }) => {
  const { loading, error, data, refetch, subscribeToMore, fetchMore } = useQuery(
    GET_CONVERSATIONS
  );

  const conversations = loading ? [] : data.getConversationsOrdered.conversations;
  const cursor = loading ? '' : data.getConversationsOrdered.cursor;

  const [currentConversation, setCurrentConversation] = useState();
  const [newConversationReadyToSend, setNewConversationReadyToSend] = useState(
    false
  );

  const onLoadMore = () => {
    fetchMore({
      query: GET_CONVERSATIONS,
      variables: { cursor: cursor },
      updateQuery: (previousResult, { fetchMoreResult }) => {
        const previousEntry = previousResult.getConversationsOrdered;
        const newConversations = fetchMoreResult.getConversationsOrdered.conversations;
        const newCursor = fetchMoreResult.getConversationsOrdered.cursor;

        return {
          getConversationsOrdered: {
            cursor: newCursor,
            conversations: [...previousEntry.conversations, ...newConversations],
            __typename: previousEntry.__typename
          }
        };
      }
    })
  }

  if (error) return `Error fetching data, please refresh the page`;

  return (
    <div className='wrapper'>
      <div className='messenger-wrapper'>
        <ConversationSelector
          conversations={conversations}
          setCurrentConversation={setCurrentConversation}
          onLoadMore={onLoadMore}
          refetchConversations={refetch}
          subscribeToAddedMessages={() =>
            subscribeToMore({
              document: MESSAGE_ADDED_SUBSCRIPTION,
              updateQuery: () => {
                refetch();
              }
            })
          }
          subscribeToUpdatedMessages={() =>
            subscribeToMore({
              document: MESSAGE_UPDATED_SUBSCRIPTION,
              updateQuery: () => {
                refetch();
              }
            })
          }
          subscribeToUpdatedConversation={() =>
            subscribeToMore({
              document: CONVERSATION_UPDATED_SUBSCRIPTION,
              updateQuery: () => {
                refetch();
              }
            })
          }
        ></ConversationSelector>

        <CurrentConversation
          currentConversation={currentConversation}
          newConversationReadyToSend={newConversationReadyToSend}
          setNewConversationReadyToSend={setNewConversationReadyToSend}
          setCurrentConversation={setCurrentConversation}
          client={client}
        ></CurrentConversation>
      </div>
    </div>
  );
};

export default Messenger;
