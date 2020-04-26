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

### Step 2: Set up a messaging profile

Click 'Messaging' in the left navigation menu.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/messaging.png)

Click the 'Create your first profile' button.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/create_your_first_profile.png)

Give the profile a name (like 'Messenger') and make sure it's set to 'API v2'

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/profile_name.png)
***

### Important Note
You need to pick a name for your app that will be part of the website address where you log in. In the next step and after you hit the button at the bottom of the page, you will need to enter the name the same way in a few places.

Your website address will look like '<APP_NAME>.herokuapp.com', and it has to be unique on heroku, so do something like 'my-example-biz-messenger' that's not likely to be taken yet.

If Heroku tells you the name has been taken already, make sure to come back to this step and update your Messaging Profile with the new name 🙏
***

Scroll down to the 'Inbound Settings' section and in the 'URL' field enter: 'https://<APP_NAME>.herokuapp.com/telnyx/inbound' (replacing APP_NAME with your app's name) like this:

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/webhook_url.png)

Click 'Save' at the bottom of the page.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/save.png)

### Step 3: Create a phone number

Click 'Numbers' in the left navigation menu.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/numbers.png)

Enter your city in the search field, and hit 'Search'.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/search.png)

Click 'Add to Cart' next to one of the numbers in the search results.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/add_to_cart.png)

Check out and complete the order.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/cart.png)

Click on 'numbers' on the left side again.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/numbers.png)

For the number you just purchased, click the dropdown 'Select Messaging Profile' and select the profile you created in Step 2.

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/select_messaging_profile.png)

Make a note of the phone number you bought. You'll need to enter it in the format "+18885552222" (No Dashes!) after you click the button. If you click the little icon next to the number, it will copy the number for you in the correct format 👍

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/number.png)

***
At this point, you should have the following things:

* A Telnyx API key that looks like this: `KEY0171B35698E39333BB93681456E5C0BA_4xPVwJGnqlfdyiyCOz1iRf`
* A purchased Telnyx phone number, formatted like this: `+13853830503`
* An app name picked out, like `my-example-biz-messenger`

You're done with the Telnyx setup and ready to launch!! 🎉🚀
***

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

***
## Post-Launch instructions for email notifications:

If someone sends a text message to your Telnyx phone number, responding to a message you sent, you will get an email notification after 10 minutes if you haven't read it by then.

When you create the app, following the instructions in the README, you will be promted to enter an email address that will receive unread notifications.

This email address could be a personal email address, or it could also be a shared email address so that multiple people will see the email and be able to respond to the unread message.

## Action item:

After you've launched the app, you'll need to whitelist the email address you submitted for notifications. To do that, follow these instructions:

Log into your Heroku account at https://heroku.com.

Go to the dashboard for your messenger app.

Click on the word 'Mailgun'

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/mailgun.png)

You'll be taken to your Mailgun account. On the left, expand the 'Sending' tab and click 'Overview'

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/overview.png)

On the right, enter your notification email address in the field and click 'Save Recipient'

![](https://github.com/damonvjanis/messenger-react/raw/images-for-readme/authorized_recipients.png)

Email notifications should work now!