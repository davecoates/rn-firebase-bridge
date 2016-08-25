// @flow
import { NativeModules, NativeEventEmitter } from 'react-native';
import type { User, AuthCredential } from './types';
const NativeFirebaseBridgeAuth = NativeModules.FirebaseBridgeAuth;
const {
    FirebaseBridgeFacebookAuthProvider,
    FirebaseBridgeTwitterAuthProvider,
    FirebaseBridgeGoogleAuthProvider,
    FirebaseBridgeGithubAuthProvider,
} = NativeModules;

const createUserWithEmail:(email:string, password:string) => Promise<User> =
    NativeFirebaseBridgeAuth.createUserWithEmail;
const signInWithEmail:(email:string, password:string) => Promise<User> =
    NativeFirebaseBridgeAuth.signInWithEmail;

async function signInWithCredential(credential:AuthCredential|Promise<AuthCredential>) : Promise<User> {
    return NativeFirebaseBridgeAuth.signInWithCredential((await credential).id);
}

const signInAnonymously:() => Promise<User> =
    NativeFirebaseBridgeAuth.signInAnonymously;

const currentUser:() => Promise<User> = 
    NativeFirebaseBridgeAuth.currentUser;

const signOut:() => Promise<null> =
    NativeFirebaseBridgeAuth.signOut;
type AuthStateListener = (user:User) => void;

const authStateDidChangeListeners:Array<AuthStateListener> = [];

let authUser:User;
const authEmitter = new NativeEventEmitter(NativeFirebaseBridgeAuth);
const subscription = authEmitter.addListener(
    'authStateDidChange',
    (user:User) => {
        authUser = user;
        authStateDidChangeListeners.forEach(cb => cb(user));
    }
);

let authStateDidChangeListenerRegistered = false;
function addAuthStateDidChangeListener(cb:AuthStateListener) : () => void {
    authStateDidChangeListeners.push(cb);
    if (!authStateDidChangeListenerRegistered) {
        NativeFirebaseBridgeAuth.addAuthStateDidChangeListener();
        authStateDidChangeListenerRegistered = true;
    } else {
        cb(authUser);
    }
    return () => {
        const index = authStateDidChangeListeners.indexOf(cb);
        if (index === -1) {
            console.warn( // eslint-disable-line
                'Callback not found for authStateDidChangeListener');
            return;
        }
        authStateDidChangeListeners.splice(index, 1);
    };
}

const FacebookAuthProvider = {
    credential(token:string) : Promise<AuthCredential> {
        return FirebaseBridgeFacebookAuthProvider.credential(token);
    },
};

const TwitterAuthProvider = {
    credential(token:string, secret:string) : Promise<AuthCredential> {
        return FirebaseBridgeTwitterAuthProvider.credential(token, secret);
    },
};

const GoogleAuthProvider = {
    credential(idToken:string, accessToken:string) : Promise<AuthCredential> {
        return FirebaseBridgeGoogleAuthProvider.credential(idToken, accessToken);
    },
};

const GithubAuthProvider = {
    credential(token:string) : Promise<AuthCredential> {
        return FirebaseBridgeGithubAuthProvider.credential(token);
    },
};

export default {
    addAuthStateDidChangeListener,
    createUserWithEmail,
    signInWithEmail,
    signInAnonymously,
    signInWithCredential,
    signOut,
    currentUser,
    FacebookAuthProvider,
    GithubAuthProvider,
    TwitterAuthProvider,
    GoogleAuthProvider,
};

export {
    addAuthStateDidChangeListener,
    createUserWithEmail,
    signInWithEmail,
    signInAnonymously,
    signInWithCredential,
    signOut,
    currentUser,
    FacebookAuthProvider,
    GithubAuthProvider,
    TwitterAuthProvider,
    GoogleAuthProvider,
};
