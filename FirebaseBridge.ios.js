/**
 * @providesModule FirebaseBridge
 * @flow
 */
'use strict';

import FirebaseBridgeAuth from './FirebaseBridgeAuth';
import FirebaseBridgeDatabase, { DataEventTypes } from './FirebaseBridgeDatabase';

console.log(DataEventTypes);

export {
    DataEventTypes,
};

export default {

    database() {
        return FirebaseBridgeDatabase;
    },

    auth() {
        return FirebaseBridgeAuth;
    },

};
