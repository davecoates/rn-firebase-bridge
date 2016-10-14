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

class App {
    name: String;
    options: {};

    authInstance: Auth;

    constructor(data) {
        this.name = data.name;
        this.options = data.options;
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

async function initializeApp(options, name?:string) : Promise<types.App> {
    return new App(await NativeFirebaseBridgeApp.initializeApp(options, name));
}

let defaultApp;

async function initializeDefaultApp() : Promise<types.App> {
    if (!defaultApp) {
        defaultApp = new App(await NativeFirebaseBridgeApp.initializeDefaultApp());
    }

    return defaultApp;
}

async function database() : Promise<Database> {
    const app = await initializeDefaultApp();
    return app.database();
}

async function auth() : Promise<Auth> {
    const app = await initializeDefaultApp();
    return app.database();
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
