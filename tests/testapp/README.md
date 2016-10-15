# Test App

Use this to test existing functionality. Not automated, requires some manual interaction.

Add your Firebase config to iOS and Android as per Firebase instructions:

```
./android/app/google-services.json
./ios/GoogleService-Info.plist
```

You can also add a file `app2-credentials.json` in the root testapp directory to be
used to configure an extra app:

```
{
  "APIKey":"<apikey>",
  "googleAppID":"<appid>",
  "databaseURL":"https://<yourapp>.firebaseio.com",
  "clientID":"<clientid>",
  "bundleID":"com.testapp",
  "GCMSenderID":"<GCMSenderID>",
  "storageBucket":"<yourapp>.appspot.com"
}
```

You can also provide a `testingState.json` file to prepopulate some data in the tests:

```
{
    "email": "email@example.com",
    "password": "password"
}
```
