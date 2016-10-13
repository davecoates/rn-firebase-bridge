package com.davecoates.rnfirebasebridge;

import android.support.annotation.NonNull;
import com.facebook.react.bridge.*;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.GetTokenResult;


public class FirebaseBridgeUser extends ReactContextBaseJavaModule {

    public FirebaseBridgeUser(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "FirebaseBridgeUser";
    }

    @ReactMethod
    void sendEmailVerification(String appName, final Promise promise)
    {
        this.getUser(appName).sendEmailVerification()
                .addOnSuccessListener(new OnSuccessListener<Void>() {
                    @Override
                    public void onSuccess(Void aVoid) {
                       promise.resolve(null);
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        FirebaseBridgeAuth.rejectFromException(e, promise);
                    }
                });
    }

    @ReactMethod
    void delete(String appName, final Promise promise)
    {
        this.getUser(appName).delete()
                .addOnSuccessListener(new OnSuccessListener<Void>() {
                    @Override
                    public void onSuccess(Void aVoid) {
                        promise.resolve(null);
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        FirebaseBridgeAuth.rejectFromException(e, promise);
                    }
                });
    }

    @ReactMethod
    void getToken(String appName, Boolean forceRefresh, final Promise promise)
    {
        this.getUser(appName).getToken(forceRefresh)
                .addOnSuccessListener(new OnSuccessListener<GetTokenResult>() {
                    @Override
                    public void onSuccess(GetTokenResult getTokenResult) {
                        promise.resolve(getTokenResult.getToken());
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        FirebaseBridgeAuth.rejectFromException(e, promise);
                    }
                });
    }

    @ReactMethod
    void link(String appName, String credentialId, Promise promise)
    {

    }

    @ReactMethod
    void reauthenticate(String appName, String credentialId, Promise promise)
    {

    }

    @ReactMethod
    void reload(String appName, Promise promise)
    {

    }

    @ReactMethod
    void unlink(String appName, String providerId, Promise promise)
    {

    }

    @ReactMethod
    void updateEmail(String appName, String newEmail, Promise promise)
    {

    }

    @ReactMethod
    void updatePassword(String appName, String newPassword, Promise promise)
    {

    }

    @ReactMethod
    void updateProfile(String appName, ReadableArray profile, Promise promise)
    {
        ReadableMap data = profile.getMap(0);
    }

    private FirebaseUser getUser(String appName)
    {
        FirebaseApp app = FirebaseApp.getInstance(appName);
        return FirebaseAuth.getInstance(app).getCurrentUser();
    }

}
