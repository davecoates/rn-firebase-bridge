 // @flow
import { NativeModules, NativeAppEventEmitter } from 'react-native';
import invariant from 'invariant';
import type {
    EventType,
    DataSnapshotDescriptor,
    DatabaseReference as DatabaseReferenceType,
} from './types';

const NativeFirebaseBridgeDatabase = NativeModules.FirebaseBridgeDatabase;

export class DataSnapshot {

    data:DataSnapshotDescriptor;
    ref:DatabaseReferenceType;

    constructor(data:DataSnapshotDescriptor) {
        this.data = data;
        this.ref = new DatabaseReference(Promise.resolve(this.data.ref)); // eslint-disable-line
    }

    child(path:string) : Promise<DataSnapshot> {
        return NativeFirebaseBridgeDatabase.snapshotChild(this.data.uuid, path).then(data =>
            new DataSnapshot(data)
        );
    }

    hasChild(path:string) : Promise<boolean> {
        return NativeFirebaseBridgeDatabase.snapshotHasChild(this.data.uuid, path);
    }

    val() : Promise<any> {
        return NativeFirebaseBridgeDatabase.snapshotValue(this.data.uuid);
    }

    exportVal() : Promise<any> {
        return NativeFirebaseBridgeDatabase.snapshotExportValue(this.data.uuid);
    }

}

export class DatabaseReference {

    parentPromise: Promise;
    keyPromise: Promise;

    constructor(parentPromise:?Promise = null) {
        this.parentPromise = (parentPromise || Promise.resolve({}));
        this.keyPromise = this.parentPromise.then(({ key }) => key);
    }

    key() {
        return this.keyPromise;
    }

    child(pathString:string) {
        const promise = this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.child(locationUrl, pathString));
        return new DatabaseReference(promise);
    }

    push() {
        const promise = this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.push(locationUrl));
        return new DatabaseReference(promise);
    }

    setValue(value:any) {
        // We wrap value in array for easier handling on Android.
        // See FirebridgeDatabase.java setValue()
        return this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.setValue(locationUrl, [value]));
    }

    remove() : Promise {
        return this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.removeValue(locationUrl));
    }

    on(eventType:EventType, cb:((snapshot:DataSnapshot) => void)) {
        const p = this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.on(locationUrl, eventType))
            .then(handleUUID => {
                const subscription = NativeAppEventEmitter.addListener(handleUUID, data => {
                    const snapshot = new DataSnapshot(data);
                    const promise = cb(snapshot);
                    invariant(promise && typeof promise.then == 'function',
                        'DatabaseReference listeners should return a promise so we know when ' +
                        'you are done with snapshots. This is necessary as all interaction ' +
                        'with the native modules is async so we cache snapshots and manually ' +
                        'release them.'
                    );
                    const release = () => NativeFirebaseBridgeDatabase.releaseSnapshot(data.uuid);
                    if (promise && promise.then) {
                        promise.then(release, e => {
                            release();
                            throw e;
                        });
                    }
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

export default {
    ref() {
        return new DatabaseReference();
    },
};
