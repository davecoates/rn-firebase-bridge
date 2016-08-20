package com.davecoates.rnfirebasebridge;
import com.facebook.react.bridge.*;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.FacebookAuthProvider;

/**
 * Created by dave on 20/08/16.
 */
public class FirebaseBridgeFacebookAuthProvider extends ReactContextBaseJavaModule {

    public FirebaseBridgeFacebookAuthProvider(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "FirebaseBridgeFacebookAuthProvider";
    }

    @ReactMethod
    public void credential(String token, Promise promise) {
        AuthCredential credential = FacebookAuthProvider.getCredential(token);
        WritableMap data = Arguments.createMap();
        data.putString("id", FirebaseBridgeCredentialCache.addCredential(credential));
        data.putString("provider", credential.getProvider());
        promise.resolve(data);
    }

}
