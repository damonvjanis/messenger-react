## Messenger React

This is a fully-baked but lightly-featured two-way text messaging app.

It allows anyone with the login code (password) to send and receive texts and attachments through a single Telnyx phone number, and view updates in real time as other logged-in users send and receive messages.

This could be useful in a very small business, where a few employees are logged in and interacting with customers throughout the day through a single phone number while always having the context of conversation history as employees are in and out of availability.

The app is expected to work, but (as per the license) does not come with any warantee or expectation of maintenance. And once it's on Heroku, it runs on your own copy of source code so any changes to this code base won't automatically apply to what you've got running.

### Features
* Two way SMS (text messages) and MMS (pictures, videos, attachments)
* Unread message notifications via email if new message hasn't been viewed in a few minutes
* One click deploy to Heroku
* Fully autonomous deploy - you own the code and hosting

### Limitations
* The software/deployment/hosting is free, but your phone number through Telnynx is roughly $1 per month and text messages are a fraction of a cent each. It doesn't add up very fast 👏
* The free Heroku database has a limit of 10,000 rows, and each new conversation and each text message is a row, so you can do a lot of messaging before it runs out. The paid database is about $10/month if you run out of space.
* There might be bugs - if so let me know in the issue tracker on here 🙏

## Instructions

Before you click the "Deploy to Heroku" button at the bottom of the page, you'll need to set up a phone number in Telnyx.

At the time of writing, Telnyx offers a free $2 credit to get started, so your first month and couple hundred text messages will be free! You won't even have to enter a credit card 🙌

### Step 1: Create an API key

Create an account at https://telnyx.com and log in.

Click 'Auth' in the left navigation menu

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/auth.png)

Click 'Create API Key' and confirm.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/create_api_key.png)
 
Click the 'Copy' button and then paste / save it somewhere you'll remember. You'll need it when you click the "Deploy to Heroku" button later.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/copy.png)

### Step 2: Create a phone number

While logged in at https://telnyx.com, click 'Numbers' in the left navigation menu.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/numbers.png)

Enter your city in the search field, and hit 'Search'.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/search.png)

Click 'Add to Cart' next to one of the numbers in the search results.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/add_to_cart.png)

Check out and complete the order.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/cart.png)

Click on 'numbers' on the left side again, and on the right side of your number click on the gear icon.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/gear.png)

Click the 'Routing' tab and click 'Select Messaging Profile' -> 'Create new Messaging Profile'.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/create_new_messaging_profile.png)

Enter any name (example: 'Messenger') and click 'Create Profile'.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/create_profile.png)

***
### Important Note
You need to pick a name for your app that will be part of the website address where you log in. In the next step and after you hit the button at the bottom of the page, you will need to enter the name the same way in a few places.

Your website address will look like "<APP_NAME>.herokuapp.com", and it has to be unique on heroku, so do something like "my-example-biz-messenger" that's not likely to be taken yet.

If Heroku tells you the name has been taken already, make sure to come back to this step and update your Messaging Profile with the new name 🙏
***

Click on the 'Inbound' tab and in the 'Webhook URL' field enter 'https://<APP_NAME>.herokuapp.com/telnyx/inbound' (replacing APP_NAME with your app's name).

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/webhook_url.png)

Save changes, and then select the messaging profile you just created from the dropdown and save changes and accept.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/select_messaging_profile.png)

Make a note of the phone number you bought. You'll need to enter it in the format "+18885552222" (No Dashes!) after you click the button.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/number.png)

***
At this point, you should have the following things:

* A Telnyx API key that looks like this: `KEY0171B35698E39333BB93681456E5C0BA_4xPVwJGnqlfdyiyCOz1iRf`
* A purchased Telnyx phone number, formatted like this: `+13853830503`
* An app name picked out, like `my-example-biz-messenger`

You're done with the Telnyx setup and ready to launch!! 🎉🚀
***

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)