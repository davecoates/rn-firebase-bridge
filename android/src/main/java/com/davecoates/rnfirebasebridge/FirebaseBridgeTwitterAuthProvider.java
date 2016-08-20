package com.davecoates.rnfirebasebridge;
import com.facebook.react.bridge.*;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.TwitterAuthProvider;

/**
 * Created by dave on 20/08/16.
 */
public class FirebaseBridgeTwitterAuthProvider extends ReactContextBaseJavaModule {

    public FirebaseBridgeTwitterAuthProvider(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "FirebaseBridgeTwitterAuthProvider";
    }

    @ReactMethod
    public void credential(String token, String secret, Promise promise) {
        AuthCredential credential = TwitterAuthProvider.getCredential(token, secret);
        WritableMap data = Arguments.createMap();
        data.putString("id", FirebaseBridgeCredentialCache.addCredential(credential));
        data.putString("provider", credential.getProvider());
        promise.resolve(data);
    }
}
