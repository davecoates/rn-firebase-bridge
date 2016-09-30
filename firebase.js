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
    "added the 'ios' directory from rn-firebase-bridge to 'Libraries' in Xcode"
);

const SDK_VERSION = '???';
const appsByName = {}
const apps = [];

class App {
    name: String;
    options: {};

    _auth: Auth;

    constructor(data) {
        this.name = data.name;
        this.options = data.options;
    }

    database() {
        return new Database(this);
    }

    auth() {
        if (!this._auth) {
            this._auth = new Auth(this);
        }
        return this._auth;
    }
}

async function initializeApp(options, name?:string) : Promise<types.App> {
    const app = new App(await NativeFirebaseBridgeApp.initializeApp(options, name));
    apps.push(app);
    return app;
}

async function initializeDefaultApp() : Promise<types.App> {
    const app = new App(await NativeFirebaseBridgeApp.initializeDefaultApp());

    return app;
}

function database() {
    return new Database();
}

database.ServerValue = {
    TIMESTAMP: '@@firebase/ServerValue/TIMESTAMP',
};

database.enableLogging = enabled => {
    console.error("Not implemented");
}

function auth() {
    return new Auth();
}
auth.FacebookAuthProvider = Auth.FacebookAuthProvider;
auth.GoogleAuthProvider = Auth.GoogleAuthProvider;
auth.GithubAuthProvider = Auth.GithubAuthProvider;
auth.TwitterAuthProvider = Auth.TwitterAuthProvider;

export default {
    apps,
    database,
    auth,
    SDK_VERSION,
    initializeApp,
    initializeDefaultApp,
};
