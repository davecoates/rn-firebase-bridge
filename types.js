// @flow

export type EventType = 'value' | 'child_added' | 'child_removed' | 'child_changed' | 'child_moved';

export interface DataSnapshot {
    child(path: string) : DataSnapshot;
    exists() : Promise<boolean>;
    exportVal() : Promise<any>;
    forEach(cb:(snapshot:DataSnapshot) => Promise) : Promise;
    getPriority() : Promise<string | number | null>;
    hasChild(path:string) : Promise<boolean>;
    hasChildren() : Promise<boolean>;
    numChildren() : Promise<number>;
    val() : Promise<any>;
}

export interface DatabaseReference {
    key(): Promise<string>;
    child(pathString:string) : DatabaseReference;
    push() : DatabaseReference;
    setValue(value:any) : Promise;
    remove() : Promise;
    setPriority(priority:number|string|null) : void;
    on(eventType:EventType, cb:((snapshot:DataSnapshotType) => Promise)) : () => void;
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
