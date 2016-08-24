// @flow
import { NativeModules, NativeEventEmitter } from 'react-native';
import type { User } from './types';
const NativeFirebaseBridgeUser = NativeModules.FirebaseBridgeUser;


const updateEmail:(email:string) => Promise<null> =
    NativeFirebaseBridgeUser.updateEmail;

const updatePassword:(email:string) => Promise<null> =
    NativeFirebaseBridgeUser.updatePassword;

const sendEmailVerification:() => Promise<null> =
    NativeFirebaseBridgeUser.sendEmailVerification;


async function reauthenticateWithCredential(credential:AuthCredential|Promise<AuthCredential>) : Promise<null> {
    return NativeFirebaseBridgeUser.reauthenticateWithCredential((await credential).id);
}

export default {
    updateEmail,
    updatePassword,
    sendEmailVerification,
    reauthenticateWithCredential,
};

export {
    updateEmail,
    updatePassword,
    sendEmailVerification,
    reauthenticateWithCredential,
};
