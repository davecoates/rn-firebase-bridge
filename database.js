// @flow
import { NativeModules, NativeAppEventEmitter } from 'react-native';
import invariant from 'invariant';
import type {
    EventType,
    DataSnapshotDescriptor,
    DataSnapshot as DataSnapshotType,
    DatabaseReference as DatabaseReferenceType,
    DatabaseReferenceDescriptor,
    Query as QueryType,
    Priority,
    App,
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

    key() : Promise<any> {
        return this.parentPromise.then(({ uuid }) =>
            NativeFirebaseBridgeDatabase.snapshotKey(uuid));
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
    forEach(cb:(snapshot:DataSnapshotType) => Promise<?boolean>) : Promise<void> {
        const wrapCb = (data:DataSnapshotDescriptor) : Promise<?boolean> => {
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
                    // Boolean true indicates we should stop iterating now.
                    // Flag for termination but continue iterating to release remaining snapshots.
                    if (result === true) {
                        terminated = true;
                    }
                }
            }));
    }

}


export class Query {

    app:App;
    parentPromise: Promise<DatabaseReferenceDescriptor>;
    query:Array<Array<any>>;

    constructor(
        app:App,
        parentPromise:Promise<DatabaseReferenceDescriptor>,
        query:Array<Array<any>> = []) {
        this.app = app;
        // Wait on app to be ready to we can guarantee name is set
        this.parentPromise = Promise.all([parentPromise, app.ready()]).then(([data]) => data);
        this.query = query;
    }

    startAt(value:number|string|boolean|null, key:?string) : QueryType {
        const q = ['startAt', value];
        if (key != null) {
            q.push(key);
        }
        return new Query(this.app, this.parentPromise, [...this.query, q]);
    }

    endAt(value:number|string|boolean|null, key:?string) : QueryType {
        const q = ['endAt', value];
        if (key != null) {
            q.push(key);
        }
        return new Query(this.app, this.parentPromise, [...this.query, q]);
    }

    equalTo(value:number|string|boolean|null, key:?string) : QueryType {
        const q = ['equalTo', value];
        if (key != null) {
            q.push(key);
        }
        return new Query(this.app, this.parentPromise, [...this.query, q]);
    }

    limitToFirst(limit:number) : QueryType {
        return new Query(this.app, this.parentPromise, [...this.query, ['limitToFirst', limit]]);
    }

    limitToLast(limit:number) : QueryType {
        return new Query(this.app, this.parentPromise, [...this.query, ['limitToLast', limit]]);
    }

    /**
     * Subscribe to an event.
     * @return {Function} a function that will unsubscribe from this event
     */
    on(eventType:EventType, cb:((snapshot:DataSnapshotType) => Promise<void>)) : () => void {
        const p = this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.on(
                this.app.name, locationUrl, eventType, this.query))
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

    once(eventType:EventType, cb:((snapshot:DataSnapshotType) => Promise<void>)) : () => void {
        const p = this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.once(
                this.app.name, locationUrl, eventType, this.query))
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
                    // NativeFirebaseBridgeDatabase.off(uniqueEventName);
                };
            });
        return () => {
            p.then(unsubscribe => unsubscribe());
        };
    }

    orderByChild(path:string) : QueryType {
        return new Query(this.app, this.parentPromise, [...this.query, ['orderByChild', path]]);
    }

    orderByKey() : QueryType {
        return new Query(this.app, this.parentPromise, [...this.query, ['orderByKey']]);
    }

    orderByPriority() : QueryType {
        return new Query(this.app, this.parentPromise, [...this.query, ['orderByPriority']]);
    }

    orderByValue() : QueryType {
        return new Query(this.app, this.parentPromise, [...this.query, ['orderByValue']]);
    }

    toString() : Promise<string> {
        return this.parentPromise.then(({ locationUrl }) => locationUrl);
    }

}


export class DatabaseReference extends Query {

    child(pathString:string) : DatabaseReferenceType {
        const promise = this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.child(
                this.app.name, locationUrl, pathString));
        return new DatabaseReference(this.app, promise);
    }

    push() : DatabaseReferenceType {
        const promise = this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.push(this.app.name, locationUrl));
        return new DatabaseReference(this.app, promise);
    }

    setValue(value:any) : Promise<void> {
        // We wrap value in array for easier handling on Android.
        // See FirebridgeDatabase.java setValue()
        return this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.setValue(
                this.app.name, locationUrl, [value]));
    }

    update(value:{ [key:string]: any }) : Promise<void> {
        return this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.update(
                this.app.name, locationUrl, value));
    }

    setValueWithPriority(value:any, priority:Priority) : Promise<void> {
        // We wrap value in array for easier handling on Android.
        // See FirebridgeDatabase.java setValue()
        return this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.setValueWithPriority(
                this.app.name, locationUrl, [value], [priority]));
    }

    setPriority(priority:Priority) : Promise<void> {
        // We wrap priority in array for easier handling on Android.
        // See FirebridgeDatabase.java setPriority()
        return this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.setPriority(
                this.app.name, locationUrl, [priority])
        );
    }

    remove() : Promise<void> {
        return this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.removeValue(
                this.app.name, locationUrl));
    }

    key() : Promise<string> {
        return this.parentPromise.then(({ key }) => key);
    }

    parent() : Promise<DatabaseReference> {
        return new DatabaseReference(this.app, this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.parent(
                this.app.name, locationUrl)));
    }

    root() : Promise<DatabaseReference> {
        return new DatabaseReference(this.app, this.parentPromise.then(
            ({ locationUrl }) => NativeFirebaseBridgeDatabase.parent(
                this.app.name, locationUrl)));
    }

}

class Database {

    static ServerValue = {
        TIMESTAMP: '@@firebase/ServerValue/TIMESTAMP',
    };

    static enableLogging(enabled) {
        NativeFirebaseBridgeDatabase.enableLogging(enabled);
    }

    static sdkVersion() : Promise<string> {
        return NativeFirebaseBridgeDatabase.sdkVersion();
    }


    app: App;

    constructor(app:App) {
        this.app = app;
    }

    async goOffline() {
        await this.app.ready();
        NativeFirebaseBridgeDatabase.goOffline(this.app.name);
    }

    async goOnline() {
        await this.app.ready();
        NativeFirebaseBridgeDatabase.goOnline(this.app.name);
    }

    async setPersistenceEnabled(enabled:boolean) {
        await this.app.ready();
        NativeFirebaseBridgeDatabase.setPersistenceEnabled(this.app.name, enabled);
    }

    ref(path?:string) : DatabaseReference {
        invariant(path == null || typeof path == 'string',
            `If path is provided it must be a string, received ${typeof path}`
        );
        const ref = this.app.ready().then(
            () => NativeFirebaseBridgeDatabase.ref(this.app.name, path));
        return new DatabaseReference(this.app, ref);
    }

    refFromURL(url) : DatabaseReference {
        const ref = this.app.ready().then(
            () => NativeFirebaseBridgeDatabase.refFromURL(this.app.name, url));
        return new DatabaseReference(this.app, ref);
    }

}

export default Database;
