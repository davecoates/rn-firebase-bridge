package com.davecoates.rnfirebasebridge;
import com.facebook.react.bridge.*;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.GoogleAuthProvider;

/**
 * Created by dave on 20/08/16.
 */
public class FirebaseBridgeGoogleAuthProvider extends ReactContextBaseJavaModule {

    public FirebaseBridgeGoogleAuthProvider(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "FirebaseBridgeGoogleAuthProvider";
    }

    @ReactMethod
    public void credential(String idToken, String accessToken, Promise promise) {
        AuthCredential credential = GoogleAuthProvider.getCredential(idToken, accessToken);
        WritableMap data = Arguments.createMap();
        data.putString("id", FirebaseBridgeCredentialCache.addCredential(credential));
        data.putString("provider", credential.getProvider());
        promise.resolve(data);
    }
}
