import { NativeModules, NativeEventEmitter } from 'react-native';
import type { User, AuthCredential, App } from './types';

const NativeFirebaseBridgeAuth = NativeModules.FirebaseBridgeAuth;
const NativeFirebaseBridgeUser = NativeModules.FirebaseBridgeUser;
const authEmitter = new NativeEventEmitter(NativeFirebaseBridgeAuth);
const authInstances = [];
authEmitter.addListener(
    'authStateDidChange',
    ({ user, app }:{|user: ?User, app: String|}) => {
        authInstances.forEach(auth => {
            if (auth.app.name === app) {
                auth._authStateChanged(user ? user : null);
            }
        })
    }
);

class FirebaseUser {

    app:App;

    uid: string;
    email: ?string;
    emailVerified: boolean;
    providerId: string;
    displayName: ?string;
    photoUrl: ?string;
    isAnonymous: boolean;

    constructor(app:App, user:User) {
        this.app = app;
        Object.keys(user).forEach(key => {
            this[key] = user[key];
        });
    }

    delete() : Promise<void> {
        return NativeFirebaseBridgeUser.delete(this.app.name);
    }

    getToken() : Promise<string> {
        return NativeFirebaseBridgeUser.getToken(this.app.name);
    }

    async link(credential) : Promise<User> {
        return NativeFirebaseBridgeUser.link(this.app.name, (await credential).id);
    }

    async reauthenticate(credential) : Promise<void> {
        return NativeFirebaseBridgeUser.reauthenticate(this.app.name, (await credential).id);
    }

    reload() : Promise<void> {
        return NativeFirebaseBridgeUser.reload(this.app.name);
    }

    sendEmailVerification() : Promise<void> {
        return NativeFirebaseBridgeUser.sendEmailVerification(this.app.name);
    }

    unlink(providerId:string) : Promise<void> {
        return NativeFirebaseBridgeUser.unlink(this.app.name, providerId);
    }

    updateEmail(newEmail:string) : Promise<void> {
        return NativeFirebaseBridgeUser.updateEmail(this.app.name, newEmail);
    }

    updatePassword(newPassword:string) : Promise<void> {
        return NativeFirebaseBridgeUser.updatePassword(this.app.name, newPassword);
    }

    updateProfile(profile:{|displayName?:string, photoURL?:string|}) : Promise<void> {
        return NativeFirebaseBridgeUser.updateProfile(this.app.name, [profile]);
    }

}

export default class Auth {
    app: App;
    currentUser:?User;
    authStateDidChangeListeners:Array<AuthStateListener> = [];

    _authStateChanged(user) {
        this.currentUser = user ? new FirebaseUser(this.app, user) : null;
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
        return NativeFirebaseBridgeAuth.createUserWithEmail(this.app.name, email, password);
    }

    fetchProvidersForEmail(email:string) : Promise<Array<string>> {
        return NativeFirebaseBridgeAuth.fetchProvidersForEmail(this.app.name, email);
    }

    sendPasswordResetEmail(email:string) : Promise<void> {
        return NativeFirebaseBridgeAuth.sendPasswordResetEmail(this.app.name, email);
    }

    signInAnonymously() : Promise<User> {
        return NativeFirebaseBridgeAuth.signInAnonymously(this.app.name);
    }

    signInWithEmail(email:string, password:string) : Promise<User> {
        return NativeFirebaseBridgeAuth.signInWithEmail(this.app.name, email, password);
    }

    async signInWithCredential(credential:AuthCredential|Promise<AuthCredential>) : Promise<User> {
        return NativeFirebaseBridgeAuth.signInWithCredential(this.app.name, (await credential).id);
    }

    signInWithCustomToken(token:string) : Promise<User> {
        return NativeFirebaseBridgeAuth.signInWithCustomToken(this.app.name, token);
    }

    signOut() : Promise<void> {
        return NativeFirebaseBridgeAuth.signOut(this.app.name);
    }

}

const {
    FirebaseBridgeFacebookAuthProvider,
    FirebaseBridgeTwitterAuthProvider,
    FirebaseBridgeGoogleAuthProvider,
    FirebaseBridgeGithubAuthProvider,
} = NativeModules;

Auth.FacebookAuthProvider = {
    credential(token:string) : Promise<AuthCredential> {
        return FirebaseBridgeFacebookAuthProvider.credential(token);
    },
};

Auth.TwitterAuthProvider = {
    credential(token:string, secret:string) : Promise<AuthCredential> {
        return FirebaseBridgeTwitterAuthProvider.credential(token, secret);
    },
};

Auth.GoogleAuthProvider = {
    credential(idToken:string, accessToken:string) : Promise<AuthCredential> {
        return FirebaseBridgeGoogleAuthProvider.credential(idToken, accessToken);
    },
};

Auth.GithubAuthProvider = {
    credential(token:string) : Promise<AuthCredential> {
        return FirebaseBridgeGithubAuthProvider.credential(token);
    },
};
