package com.davecoates.rnfirebasebridge;

import android.net.Uri;
import android.support.annotation.NonNull;
import com.facebook.react.bridge.*;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.auth.*;
import com.google.firebase.FirebaseApp;


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
    void link(String appName, String credentialId, final Promise promise)
    {
        AuthCredential credential = FirebaseBridgeCredentialCache.getCredential(credentialId);
        if (credential == null) {
            promise.reject("auth/credential-not-found", "Credential not found");
            return;
        }
        this.getUser(appName).linkWithCredential(credential)
                .addOnSuccessListener(new OnSuccessListener<AuthResult>() {
                    @Override
                    public void onSuccess(AuthResult authResult) {
                        promise.resolve(FirebaseBridgeAuth.convertUser(authResult.getUser()));
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
    void reauthenticate(String appName, String credentialId, final Promise promise)
    {
        AuthCredential credential = FirebaseBridgeCredentialCache.getCredential(credentialId);
        if (credential == null) {
            promise.reject("auth/credential-not-found", "Credential not found");
            return;
        }
        this.getUser(appName).reauthenticate(credential)
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
    void reload(String appName, final Promise promise)
    {
        this.getUser(appName).reload()
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
    void unlink(String appName, String providerId, final Promise promise)
    {
        this.getUser(appName).unlink(providerId)
                .addOnSuccessListener(new OnSuccessListener<AuthResult>() {
                    @Override
                    public void onSuccess(AuthResult authResult) {
                        promise.resolve(FirebaseBridgeAuth.convertUser(authResult.getUser()));
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
    void updateEmail(String appName, String newEmail, final Promise promise)
    {
        this.getUser(appName).updateEmail(newEmail)
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
    void updatePassword(String appName, String newPassword, final Promise promise)
    {
        this.getUser(appName).updatePassword(newPassword)
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
    void updateProfile(String appName, ReadableArray profile, final Promise promise)
    {
        ReadableMap data = profile.getMap(0);
        UserProfileChangeRequest.Builder builder = new UserProfileChangeRequest.Builder();

        if (data.hasKey("displayName")) {
            builder.setDisplayName(data.getString("displayName"));
        }
        if (data.hasKey("photoURL")) {
            builder.setPhotoUri(Uri.parse(data.getString("photoURL")));
        }
        UserProfileChangeRequest profileUpdates = builder.build();
        this.getUser(appName).updateProfile(profileUpdates)
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

    private FirebaseUser getUser(String appName)
    {
        FirebaseApp app = FirebaseApp.getInstance(appName);
        return FirebaseAuth.getInstance(app).getCurrentUser();
    }

}
