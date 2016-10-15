// @flow
import { NativeModules } from 'react-native';
import invariant from 'invariant';
import type * as types from './types';
import Database from './database';
import Auth from './auth';
// See
// https://firebase.google.com/docs/reference/js/firebase

const NativeFirebaseBridgeApp = NativeModules.FirebaseBridgeApp;
invariant(
    NativeFirebaseBridgeApp,
    'Native module not found; on iOS this can happen if you have not yet ' +
    "added the 'ios' directory from rn-firebase-bridge to 'Libraries' in Xcode." +
    " On Android make sure you have run 'react-native link'."
);

type AppData = { name: String; options: {}};

class App {
    _name: String;
    _options: {};

    authInstance: Auth;

    isReady = false;
    readyPromise: Promise<void>;

    get name() {
        if (!this.isReady) {
            throw new Error('Attempted to access app name before app was ready');
        }
        return this._name;
    }

    get options() {
        if (!this.isReady) {
            throw new Error('Attempted to access app options before app was ready');
        }
        return this._options;
    }

    constructor(promise:Promise<AppData>) {
        this.readyPromise = promise.then((data:AppData) => {
            this._name = data.name;
            this._options = data.options;
            this.isReady = true;
        });
    }

    ready() : Promise {
        return this.readyPromise;
    }

    database() {
        return new Database(this);
    }

    auth() {
        if (!this.authInstance) {
            this.authInstance = new Auth(this);
        }
        return this.authInstance;
    }
}

function initializeApp(options, name?:string) : types.App {
    return new App(NativeFirebaseBridgeApp.initializeApp(options, name));
}

let defaultApp;

function initializeDefaultApp() : types.App {
    if (!defaultApp) {
        defaultApp = new App(NativeFirebaseBridgeApp.initializeDefaultApp());
    }

    return defaultApp;
}

function database() : Database {
    const app = initializeDefaultApp();
    return app.database();
}

function auth() : Auth {
    const app = initializeDefaultApp();
    return app.auth();
}
auth.FacebookAuthProvider = Auth.FacebookAuthProvider;
auth.GoogleAuthProvider = Auth.GoogleAuthProvider;
auth.GithubAuthProvider = Auth.GithubAuthProvider;
auth.TwitterAuthProvider = Auth.TwitterAuthProvider;

export default {
    database,
    auth,
    initializeApp,
    initializeDefaultApp,
};
