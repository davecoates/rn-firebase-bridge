import { FirebaseBridgeAuth as NativeFirebaseBridgeAuth } from 'NativeModules';
import { NativeAppEventEmitter } from 'react-native';

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

export default {
    ...NativeFirebaseBridgeAuth,
    addAuthStateDidChangeListener(cb) {
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
    },
};
