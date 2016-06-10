# React Native Firebase Bridge

A bridge to the native SDK's for iOS and (eventually) Android. 

iOS and Android SDK support offline mode's which the node / web SDK does not.
There's also some other issues at the time of writing web SDK with React
Native.

Very much a WIP. API aiming to match what makes most sense between the iOS and
nodejs Firebase interfaces. Promises are returned where callbacks might
otherwise be used. For the time being exposed API will change without warning.

# Installation

# API

## Types

## Auth

### createUserWithEmail(email:string, password:string) : Promise<User>

```
import { createuserWithEmail } from 'rn-firebase-bridge/auth';

createUserWithEmail('test@example.com', 'pass1234').then(user => {
    console.log(user.email, user.uuid);
});
```

### signInWithEmail(email:string, password:string) : Promise<User>

```
import { createuserWithEmail } from 'rn-firebase-bridge/auth';

signInWithEmail('test@example.com', 'pass1234').then(
    user => console.log(user),
    error => console.log(error)
);
```

### addAuthStateDidChangeListener(callback:({user:User}) -> void)

```
import { addAuthStateDidChangeListener } from 'rn-firebase-bridge/auth';

addAuthStateDidChangeListener(payload => {
    console.log(payload.user);
});
```

## Database

### DatabaseReference


```
import Database from 'rn-firebase-bridge/database';

const ref = Database.reference();

// or

import { DatabaseReference } from 'rn-firebase-bridge/database';

const ref = new DatabaseReference();

```

#### child(path:string) : DatabaseReference

Create a child at specified path.

```
import Database from 'rn-firebase-bridge/database';

const item = Database.reference().child('shop').child('packages').childByAutoId().child('items').childByAutoId();
```

#### childByAutoId() : DatabaseReference

#### on(eventType:DataEventTypes, cb:(snapshot:DataSnapshot) -> void) : Function

Listen for a change event. Returns a function to remove listener.
