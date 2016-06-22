// @flow

export type EventType = 'value' | 'child_added' | 'child_removed' | 'child_changed' | 'child_moved';

export type Priority = number | string | null;

export interface DataSnapshot {
    child(path: string) : DataSnapshot;
    exists() : Promise<boolean>;
    exportVal() : Promise<any>;
    forEach(cb:(snapshot:DataSnapshot) => Promise) : Promise;
    getPriority() : Promise<Priority>;
    hasChild(path:string) : Promise<boolean>;
    hasChildren() : Promise<boolean>;
    numChildren() : Promise<number>;
    val() : Promise<any>;
}

export interface Query {
    endAt(value:number|string|boolean|null, key:?string) : Query;
    equalTo(value:number|string|boolean|null, key:?string) : Query;
    limitToFirst(limit:number) : Query;
    limitToLast(limit:number) : Query;
    on(eventType:EventType, cb:((snapshot:DataSnapshot) => Promise)) : () => void;
    once(eventType:EventType, cb:((snapshot:DataSnapshot) => Promise)) : () => void;
    orderByChild(path:string) : Query;
    orderByKey() : Query;
    orderByPriority() : Query;
    orderByValue() : Query;
    startAt(value:number|string|boolean|null, key:?string) : Query;
    toString() : Promise<string>;
}

export type DatabaseReference = Query & {
    key(): Promise<string>;
    child(pathString:string) : DatabaseReference;
    push() : DatabaseReference;
    setValue(value:any) : Promise;
    setValueWithPriority(value:any, priority:Priority) : Promise;
    remove() : Promise;
    setPriority(priority:Priority) : Promise;
    on(eventType:EventType, cb:((snapshot:DataSnapshot) => Promise)) : () => void;
}

export type User = {
    uid: string;
    email: ?string;
    displayName: ?string;
    photoUrl: ?string;
    anonymous: boolean;
}


// Description of reference received via native bridge calls
export type DatabaseReferenceDescriptor = {
    locationUrl: ?string;
    key: string;
}

// Description of snapshot received via native bridge calls
export type DataSnapshotDescriptor = {
    ref: DatabaseReferenceDescriptor;
    childrenCount: number;
    exists: boolean;
    hasChildren: boolean;
    uuid: string;
    priority: number;
};
