 // @flow
import { NativeModules, NativeAppEventEmitter } from 'react-native';
import invariant from 'invariant';
import type {
    EventType,
    DataSnapshotDescriptor,
    DataSnapshot as DataSnapshotType,
    DatabaseReference as DatabaseReferenceType,
    Priority,
} from './types';

const NativeFirebaseBridgeDatabase = NativeModules.FirebaseBridgeDatabase;

export class DataSnapshot {

    parentPromise:Promise<DataSnapshotDescriptor>;

    constructor(data:DataSnapshotDescriptor | Promise<DataSnapshotDescriptor>) {
        this.parentPromise = Promise.resolve(data);
    }

    child(path:string) : DataSnapshot {
        const promise = this.parentPromise.then(({ uuid }) =>
            NativeFirebaseBridgeDatabase.snapshotChild(uuid, path)
        );
        return new DataSnapshot(promise);
    }

    hasChild(path:string) : Promise<boolean> {
        return this.parentPromise.then(({ uuid }) =>
            NativeFirebaseBridgeDatabase.snapshotHasChild(uuid, path));
    }

    hasChildren() {
        return this.parentPromise.then(({ hasChildren }) => hasChildren);
    }

    exists() {
        return this.parentPromise.then(({ exists }) => exists);
    }

    numChildren() {
        return this.parentPromise.then(({ childrenCount }) => childrenCount);
    }

    val() : Promise<any> {
        return this.parentPromise.then(({ uuid }) =>
            NativeFirebaseBridgeDatabase.snapshotValue(uuid));
    }

    exportVal() : Promise<any> {
        return this.parentPromise.then(({ uuid }) =>
            NativeFirebaseBridgeDatabase.snapshotExportValue(uuid));
    }

    getPriority() : Promise<Priority> {
        return this.parentPromise.then(({ priority }) => priority);
    }

    /**
     * Fire callback for each child. The callback should return a Promise that resolves
     * (or rejects) when you are finished with the snapshot. This is done so the snapshot
     * can be released. If the promise resolves to boolean false then iteration will
     * terminate and no further callbacks will be triggered. eg.
     * snapshot.forEach(async (snapshot) => {
     *    // ... whatever
     *    if (terminalCondition) {
     *       return false;
     *    }
     * })
     */
    forEach(cb:(snapshot:DataSnapshotType) => Promise) : Promise {
        const wrapCb = (data:DataSnapshotDescriptor) => {
            const snapshot:DataSnapshotType = new DataSnapshot(data);
            const promise = cb(snapshot);
            invariant(promise && typeof promise.then == 'function',
                'DataSnapshot.forEach callbacks should return a promise so we know when ' +
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
            return promise;
        };
        return this.parentPromise.then(({ uuid }) =>
            NativeFirebaseBridgeDatabase.snapshotChildren(uuid).then(async (children = []) => {
                let terminated = false;
                for (const child:DataSnapshotDescriptor of children) {
                    if (terminated) {
                        NativeFirebaseBridgeDatabase.releaseSnapshot(child.uuid);
                        continue;
                    }
                    const result = await wrapCb(child);
                    // Boolean false indicates we should stop iterating now.
                    // Flag for termination but continue iterating to release remaining snapshots.
                    if (result === true) {
                        terminated = true;
                    }
                }
            }));
    }

}

export class DatabaseReference {

    parentPromise: Promise;
    keyPromise: Promise;

    constructor(parentPromise:?Promise = null) {
        this.parentPromise = (parentPromise || Promise.resolve({}));
        this.keyPromise = this.parentPromise.then(({ key }) => key);
    }

    key() : Promise<string> {
        return this.keyPromise;
    }

    child(pathString:string) : DatabaseReferenceType {
        const promise = this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.child(locationUrl, pathString));
        return new DatabaseReference(promise);
    }

    push() : DatabaseReferenceType {
        const promise = this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.push(locationUrl));
        return new DatabaseReference(promise);
    }

    setValue(value:any) : Promise {
        // We wrap value in array for easier handling on Android.
        // See FirebridgeDatabase.java setValue()
        return this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.setValue(locationUrl, [value]));
    }

    setValueWithPriority(value:any, priority:Priority) : Promise {
        // We wrap value in array for easier handling on Android.
        // See FirebridgeDatabase.java setValue()
        return this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.setValueWithPriority(
                locationUrl, [value], [priority]));
    }

    setPriority(priority:Priority) : Promise {
        // We wrap priority in array for easier handling on Android.
        // See FirebridgeDatabase.java setPriority()
        return this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.setPriority(locationUrl, [priority])
        );
    }

    remove() : Promise {
        return this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.removeValue(locationUrl));
    }

    /**
     * Subscribe to an event.
     * @return {Function} a function that will unsubscribe from this event
     */
    on(eventType:EventType, cb:((snapshot:DataSnapshotType) => Promise)) : () => void {
        const p = this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.on(locationUrl, eventType))
            .then(uniqueEventName => {
                // We receive a string back from the native module that is a unique
                // event name just for this event registration. An event with this name
                // will be emitted for this registration. This is cached on the native
                // side with the event registration handle so we can unsubscribe as
                // needed.
                const listener = (data:DataSnapshotDescriptor) => {
                    // Snapshot's are cached on the native side so we can perform further
                    // queries on them. Because of this we need a way to release the
                    // snapshot once we are done with them. We do this by returning a
                    // promise which, when it resolves (or rejects), causes the snapshot
                    // to be released on the native. The most convenient way to do this
                    // is to simply define your callback as async:
                    // ref.on(async (snapshot) => {
                    //    // this now automatically returns a promise
                    // })
                    const snapshot:DataSnapshotType = new DataSnapshot(data);
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
                };
                const subscription = NativeAppEventEmitter.addListener(uniqueEventName, listener);
                return () => {
                    subscription.remove();
                    NativeFirebaseBridgeDatabase.off(uniqueEventName);
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
