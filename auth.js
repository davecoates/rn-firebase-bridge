// @flow
import { NativeModules, NativeAppEventEmitter } from 'react-native';
import type { User } from './types';
const NativeFirebaseBridgeAuth = NativeModules.FirebaseBridgeAuth;

const createUserWithEmail:(email:string, password:string) => Promise<User> =
    NativeFirebaseBridgeAuth.createUserWithEmail;
const signInWithEmail:(email:string, password:string) => Promise<User> =
    NativeFirebaseBridgeAuth.signInWithEmail;

const signInAnonymously:() => Promise<User> =
    NativeFirebaseBridgeAuth.signInAnonymously;

type AuthStateListener = (user:User) => void;

const authStateDidChangeListeners:Array<AuthStateListener> = [];

let authUser:User;
NativeAppEventEmitter.addListener(
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

export default {
    createUserWithEmail,
    signInWithEmail,
    signInAnonymously,
    addAuthStateDidChangeListener,
};

export {
    addAuthStateDidChangeListener,
    createUserWithEmail,
    signInWithEmail,
    signInAnonymously,
};
