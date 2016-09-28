import { NativeModules, NativeEventEmitter } from 'react-native';
import type { App, User } from './types';

const NativeFirebaseBridgeAuth = NativeModules.FirebaseBridgeAuth;
const authEmitter = new NativeEventEmitter(NativeFirebaseBridgeAuth);
const authInstances = [];
authEmitter.addListener(
  'authStateDidChange',
  ({ user, app }:{|user: ?User, app: String|}) => {
      authInstances.forEach(auth => {
          if (auth.app.name === app) {
              auth._authStateChanged(user);
          }
      })
  }
);

export default class Auth {
    app: App;
    currentUser:?User;
    authStateDidChangeListeners:Array<AuthStateListener> = [];

    _authStateChanged(user) {
        this.currentUser = user;
        this.authStateDidChangeListeners.forEach(cb => cb(user));
    }

    constructor(app:App) {
        this.app = app;
        NativeFirebaseBridgeAuth.addAuthStateDidChangeListener(this.app.name);
        authInstances.push(this);
    }

    onAuthStateChanged(cb:AuthStateListener) : () => void {
        this.authStateDidChangeListeners.push(cb);
        cb(Auth.currentUser);
        return () => {
            const index = this.authStateDidChangeListeners.indexOf(cb);
            if (index === -1) {
                console.warn( // eslint-disable-line
                    'onAuthStateChanged listener not found; did you call unsubscribe twice?');
                return;
            }
            this.authStateDidChangeListeners.splice(index, 1);
        };
    }

    createUserWithEmailAndPassword(email:string, password:string) : Promise<User> {

    }

    fetchProvidersForEmail(email:string) : Promise<Array<string>> {

    }

    sendPasswordResetEmail(email:string) : Promise<void> {

    }

    signInAnonymously() : Promise<User> {
        return NativeFirebaseBridgeAuth.signInAnonymously(this.app.name);
    }

    signInWithEmail(email:string, password:string) : Promise<User> {

    }

    signInWithCredential(credential:AuthCredential|Promise<AuthCredential>) : Promise<User> {

    }

    signInWithCustomToken(token:string) : Promise<User> {

    }

    signOut() : Promise<void> {

    }

}
