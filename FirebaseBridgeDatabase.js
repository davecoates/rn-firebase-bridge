import { FirebaseBridgeDatabase as NativeFirebaseBridgeDatabase } from 'NativeModules';

import { NativeAppEventEmitter } from 'react-native';

var subscription = NativeAppEventEmitter.addListener(
  'onDatabaseEvent',
  (data) => {
      console.log(data);
  }
);


const { DataEventTypes } = NativeFirebaseBridgeDatabase;

console.log(DataEventTypes);

class DatabaseReference {

    parentPromise: Promise;

    constructor(parentPromise = null) {
        if (!parentPromise) {
            parentPromise = Promise.resolve({});
        }
        this.parentPromise = parentPromise;
        this.keyPromise = parentPromise.then(({ key }) => key);
    }

    key() {
        return this.keyPromise;
    }

    child(pathString:string) {
        const promise = this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.child(locationUrl, pathString))
        return new DatabaseReference(promise);
    }

    push() {
        const promise = this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.childByAutoId(locationUrl));
        return new DatabaseReference(promise);
    }

    childByAutoId() {
        return this.push();
    }

    setValue(value) {
        return this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.setValue(locationUrl, value));
    }

    on(eventType) {
        return this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.on(locationUrl, eventType));
    }
}

export {
    DataEventTypes,
}

export default {
    reference() {
        return new DatabaseReference();
    },
}
