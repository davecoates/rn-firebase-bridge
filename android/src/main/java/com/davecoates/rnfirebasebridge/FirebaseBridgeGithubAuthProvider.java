package com.davecoates.rnfirebasebridge;
import com.facebook.react.bridge.*;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.GithubAuthProvider;

/**
 * Created by dave on 20/08/16.
 */
public class FirebaseBridgeGithubAuthProvider extends ReactContextBaseJavaModule{

    public FirebaseBridgeGithubAuthProvider(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "FirebaseBridgeGithubAuthProvider";
    }

    @ReactMethod
    public void credential(String token, Promise promise) {
        AuthCredential credential = GithubAuthProvider.getCredential(token);
        WritableMap data = Arguments.createMap();
        data.putString("id", FirebaseBridgeCredentialCache.addCredential(credential));
        data.putString("provider", credential.getProvider());
        promise.resolve(data);
    }
}
