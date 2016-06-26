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

`npm install --save rn-firebase-bridge`

## iOS

In your Firebase console follow the instructions for adding iOS to your project.

Your Podfile should have at least:

```
pod 'Firebase'
pod 'Firebase/Database'
pod 'Firebase/Auth'
```

Open the Xcode project, right click on `Libraries` and click `Add Files to
"MyApp"`. Navigate to `node_modules/rn-firebase-bridge` and click the `ios`
directory. You may wish to rename it to something more obvious (ie. `FirebaseBridge`).

You will also need to create a Swift bridging header

```
#import "RCTBridge.h"
#import "../node_modules/rn-firebase-bridge/ios/FirebaseBridge.h"
```

Also make sure your `Other linker flags` setting under `Build Settings` includes
`$(inherited)`.

## Android

In your firebase console follow the instructions for adding Android to your project.

Run `react-native link`.

# API

## Types

### EventType

One of 'value', 'child_added', 'child_removed', 'child_changed', 'child_moved'

### Priority

string | number | null

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

### signInAnonymously() : Promise<User>

```
import { signInAnonymously } from 'rn-firebase-bridge/auth';

signInAnonymously().then(
    user => console.log(user),
    error => console.log(error)
);
```

Error code will match one of the values described [here](https://firebase.google.com/docs/reference/js/firebase.auth.Auth#signInAnonymously)

### addAuthStateDidChangeListener(callback:({user:User}) -> void)

```
import { addAuthStateDidChangeListener } from 'rn-firebase-bridge/auth';

addAuthStateDidChangeListener(payload => {
    console.log(payload.user);
});
```

## Database

### Query

#### endAt(value:number|string|boolean|null, key:?string) : Query
#### equalTo(value:number|string|boolean|null, key:?string) : Query
#### limitToFirst(limit:number) : Query
#### limitToLast(limit:number) : Query
#### on(eventType:EventType, cb:((snapshot:DataSnapshot) => Promise)) : () => void

Listen for a change event. Returns a function to remove the listener.

Because fetching a snapshot is asynchronous and then any further actions on that
snapshot are also asynchronous (including fetching it's children, which are
also snapshots) we have to cache the snapshots on the native side to allow further
queries. We don't want to cache them forever, just until the consumer is done with it
but without relying on manual release. The callback must return a promise which,
when it resolves or rejects, causes the snapshot to be released on the native side.
Because of async/await this isn't too onerous:

```
ref.on('value', async (snapshot) => {
    await snapshot.forEach(async (child) => {
        console.log('Child value:', async child.val());
    })
    console.log('Value is': await snapshot.val());
});
```

#### once(eventType:EventType, cb:((snapshot:DataSnapshot) => Promise)) : () => void
#### orderByChild(path:string) : Query
#### orderByKey() : Query
#### orderByPriority() : Query
#### orderByValue() : Query
#### startAt(value:number|string|boolean|null, key:?string) : Query
#### toString() : Promise<string>
Resolves to full URL for this location.

### DatabaseReference

Extends `Query`.

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

#### setValue(value:any) : Promise
Set value and return a promise that resolves when complete. Will reject on failure.
#### setValueWithPriority(value:any, priority:Priority) : Promise
As above but set value with priority.
#### remove() : Promise
Remove value with a promise that resolves on completion.
#### setPriority(priority:Priority) : Promise
Set priority and return a promise that resolves when complete. Will reject on failure.

### DataSnapshot

Whenever a listener is called for a data event a `DataSnapshot` is passed.

#### child(path: string) : DataSnapshot
#### exists() : Promise<boolean>
#### exportVal() : Promise<any>
#### hasChild(path:string) : Promise<boolean>
#### hasChildren() : Promise<boolean>
#### numChildren() : Promise<number>
#### val() : Promise<any>
#### forEach(cb:(snapshot:DataSnapshot) => Promise) : Promise

As with `DatabaseReference.on` the callback should return a promise to indicate
the snapshot is no longer needed. If your promise returns true then no further
iteration will occur.

```
snapshot.forEach(async (child) => {
    const value = await child.val();
    if (value === "abc") {
        // Cancel enumeration
        return true;
    }
});
```
#### getPriority() : Promise<Priority>
