import { NativeModules, NativeAppEventEmitter } from 'react-native';
const NativeFirebaseBridgeAuth = NativeModules.FirebaseBridgeAuth;

const authStateDidChangeListeners = [];

let authUser;
var subscription = NativeAppEventEmitter.addListener(
  'authStateDidChange',
  (user) => {
      authUser = user;
      authStateDidChangeListeners.forEach(cb => cb(user));
  }
);


let authStateDidChangeListenerRegistered = false;
const {
    createUserWithEmail,
    signInWithEmail,
} = NativeFirebaseBridgeAuth;

const addAuthStateDidChangeListener = (cb) => {
    authStateDidChangeListeners.push(cb);
    if (!authStateDidChangeListenerRegistered) {
        NativeFirebaseBridgeAuth.addAuthStateDidChangeListener();
        authStateDidChangeListenerRegistered = true;
    } else {
        cb(user);
    }
    return () => {
        const index = authStateDidChangeListeners.indexOf(cb);
        if (index === -1) {
            console.warn('Callback not found for authStateDidChangeListener');
            return;
        }
        authStateDidChangeListeners.splice(index, 1);
    };
};

export default {
    createUserWithEmail,
    signInWithEmail,
    addAuthStateDidChangeListener,
};

export {
    addAuthStateDidChangeListener,
    createUserWithEmail,
    signInWithEmail,
};
