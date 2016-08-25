// @flow
import { NativeModules, NativeEventEmitter } from 'react-native';
import type { User, AuthCredential, AuthModule } from './types';
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

const getCurrentUser:() => Promise<User> =
    NativeFirebaseBridgeAuth.getCurrentUser;

const signOut:() => Promise<null> =
    NativeFirebaseBridgeAuth.signOut;
type AuthStateListener = (user:?User) => void;

const authStateDidChangeListeners:Array<AuthStateListener> = [];

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

const Auth:AuthModule = {
    currentUser: null,
    onAuthStateChanged, // eslint-disable-line
    addAuthStateDidChangeListener, // eslint-disable-line
    createUserWithEmail,
    signInWithEmail,
    signInAnonymously,
    signInWithCredential,
    signOut,
    getCurrentUser,
    FacebookAuthProvider,
    GithubAuthProvider,
    TwitterAuthProvider,
    GoogleAuthProvider,
};
const authEmitter = new NativeEventEmitter(NativeFirebaseBridgeAuth);
const subscription = authEmitter.addListener(
    'authStateDidChange',
    (user?:User) => {
        Auth.currentUser = user;
        authStateDidChangeListeners.forEach(cb => cb(user));
    }
);

// Always add listener immediately so currentUser is set as soon as possible
function onAuthStateChanged(cb:AuthStateListener) : () => void {
    authStateDidChangeListeners.push(cb);
    cb(Auth.currentUser);
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

function addAuthStateDidChangeListener(cb:(payload:?{ user: User }) => void) : () => void {
    console.warn( // eslint-disable-line
        'addAuthStateDidChangeListener() is deprecated; use onAuthStateChanged. ' +
        'Callback passed to onAuthStateChanged will receive null or the user rather ' +
        "than null or an object with a 'user' key");
    return onAuthStateChanged(user => {
        if (user) {
            cb({ user });
        } else {
            cb(null);
        }
    });
}


export default Auth;
export {
    addAuthStateDidChangeListener,
    onAuthStateChanged,
    createUserWithEmail,
    signInWithEmail,
    signInAnonymously,
    signInWithCredential,
    signOut,
    getCurrentUser,
    FacebookAuthProvider,
    GithubAuthProvider,
    TwitterAuthProvider,
    GoogleAuthProvider,
};
