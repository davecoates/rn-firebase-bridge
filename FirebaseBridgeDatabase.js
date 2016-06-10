import { FirebaseBridgeDatabase as NativeFirebaseBridgeDatabase } from 'NativeModules';

import { NativeAppEventEmitter } from 'react-native';

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

    on(eventType, cb) {
        const p = this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.on(locationUrl, eventType))
                .then(handleUUID => {
                    console.log('handle!', handleUUID);
                    const subscription = NativeAppEventEmitter.addListener(handleUUID, data => {
                        const snapshot = new DataSnapshot(data);
                        cb(snapshot);
                    });
                    return () => {
                        subscription.remove();
                        NativeFirebaseBridgeDatabase.off(handleUUID);
                    };
                });
        return () => {
            p.then(unsubscribe => unsubscribe());
        };
    }
}

class DataSnapshot {

    constructor(snapshot) {
        this.snapshot = snapshot;
        this._ref = new DatabaseReference(Promise.resolve(this.snapshot.ref));
    }

    childSnapshotForPath(path) {
        console.log(this.snapshot.uuid);
        return NativeFirebaseBridgeDatabase.childSnapshotForPath(this.snapshot.uuid, path);
    }

    ref() {
        return this._ref;
    }
}


var subscription = NativeAppEventEmitter.addListener(
  'onDatabaseEvent',
  (data) => {
      console.log(data);
      const snapshot = new DataSnapshot(data);
      snapshot.childSnapshotForPath('children').then(console.log.bind(console, 'hah!')).catch(console.error.bind(console))
      snapshot.ref().key().then(console.log.bind(console, 'key: '));
  }
);

const { DataEventTypes } = NativeFirebaseBridgeDatabase;

export {
    DataEventTypes,
}

export default {
    reference() {
        return new DatabaseReference();
    },
}
