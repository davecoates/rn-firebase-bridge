// @flow

export type EventType = 'value' | 'child_added' | 'child_removed' | 'child_changed' | 'child_moved';

export type Priority = number | string | null;

export interface DataSnapshot {
    child(path: string) : DataSnapshot;
    exists() : Promise<boolean>;
    exportVal() : Promise<any>;
    forEach(cb:(snapshot:DataSnapshot) => Promise<?boolean>) : Promise<void>;
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
    on(eventType:EventType, cb:((snapshot:DataSnapshot) => Promise<void>)) : () => void;
    once(eventType:EventType, cb:((snapshot:DataSnapshot) => Promise<void>)) : () => void;
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
    setValue(value:any) : Promise<void>;
    setValueWithPriority(value:any, priority:Priority) : Promise<void>;
    remove() : Promise<void>;
    setPriority(priority:Priority) : Promise<void>;
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
    locationUrl?: ?string;
    key?: string;
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

export type AuthCredential = {
    id: string;
    provider: string;
};

export type FacebookAuthProvider = {
    credential(token:string) : Promise<AuthCredential>;
};

export type TwitterAuthProvider = {
    credential(token:string, secret:string) : Promise<AuthCredential>;
};

export type GoogleAuthProvider = {
    credential(idToken:string, accessToken:string) : Promise<AuthCredential>;
};

export type GithubAuthProvider = {
    credential(token:string) : Promise<AuthCredential>;
};

export type AuthModule = {
    currentUser:?User;
    createUserWithEmail(email:string, password:string) : Promise<User>;
    signInWithEmail(email:string, password:string) : Promise<User>;
    signInAnonymously() : Promise<User>;
    signInWithCredential(credential:AuthCredential|Promise<AuthCredential>) : Promise<User>;
    FacebookAuthProvider: FacebookAuthProvider;
    GithubAuthProvider: GithubAuthProvider;
    TwitterAuthProvider: TwitterAuthProvider;
    GoogleAuthProvider: GoogleAuthProvider;
    getCurrentUser() : Promise<User>;
};
