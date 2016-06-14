# React Native Firebase Bridge

A bridge to the native SDK's for iOS and Android.

iOS and Android SDK support offline mode's which the node / web SDK does not.
There's also some other issues at the time of writing with the web SDK when
used in React Native.

Very much a WIP. API aims to match the Firebase Web API. Due to the fact that
all communication between native and JS is async most functions return promises.

For the time being exposed API will change without warning while main
functionality is implemented.

# Installation

# API

## Types

### EventType

One of 'value', 'child_added', 'child_removed', 'child_changed', 'child_moved'

### User

```
{
    uid: string;
    email: ?string;
    displayName: ?string;
    photoUrl: ?string;
    anonymous: boolean;
}
```

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

Error code will match one of the values described [here](https://firebase.google.com/docs/reference/js/firebase.auth.Auth#signInWithEmailAndPassword)

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

const ref = Database.ref();
```

#### child(path:string) : DatabaseReference

Create a child at specified path. Can be chained.

```
import Database from 'rn-firebase-bridge/database';

const item = Database.reference().child('shop').child('packages').push().child('items').push();
```

#### push() : DatabaseReference

Push a new item onto a list.

#### on(eventType:DataEventTypes, cb:(snapshot:DataSnapshot) => void) : Function

Listen for a change event. Returns a function to remove the listener.

### DataSnapshot

Whenever a listener is called for a data event a `DataSnapshot` is passed.

### child(path: string) : DataSnapshot;
### exists() : Promise<boolean>;
### exportVal() : Promise<any>;
### hasChild(path:string) : Promise<boolean>;
### hasChildren() : Promise<boolean>;
### numChildren() : Promise<number>;
### val() : Promise<any>;
