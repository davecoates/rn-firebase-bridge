package com.davecoates.rnfirebasebridge;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import com.facebook.react.bridge.*;
import com.facebook.react.modules.core.RCTNativeAppEventEmitter;
import com.google.android.gms.tasks.*;
import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.*;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;


public class FirebaseBridgeAuth extends ReactContextBaseJavaModule {

    private static final String TAG = "FirebaseBridgeAuth";

    public FirebaseBridgeAuth(ReactApplicationContext reactContext) {
        super(reactContext);
        LifecycleEventListener listener = new LifecycleEventListener() {
            @Override
            public void onHostResume() {
            }

            @Override
            public void onHostPause() {
            }
            @Override
            public void onHostDestroy() {
                for (Map.Entry<String, FirebaseAuth.AuthStateListener> entry : authStateDidChangeListeners.entrySet()) {
                    FirebaseApp app = FirebaseApp.getInstance(entry.getKey());
                    FirebaseAuth.getInstance(app).removeAuthStateListener(entry.getValue());
                }
            }
        };
        reactContext.addLifecycleEventListener(listener);
    }

    private void sendEvent(String eventName,
                           @Nullable WritableMap params) {
        ReactContext reactContext = getReactApplicationContext();
        reactContext
                .getJSModule(RCTNativeAppEventEmitter.class)
                .emit(eventName, params);
    }

    @Override
    public String getName() {
        return "FirebaseBridgeAuth";
    }

    private WritableMap convertUser(FirebaseUser user) {
        final WritableMap m = Arguments.createMap();
        m.putString("uid", user.getUid());
        m.putString("email", user.getEmail());
        m.putBoolean("emailVerified", user.isEmailVerified());
        m.putString("displayName", user.getDisplayName());
        if (user.getPhotoUrl() != null) {
            m.putString("photoUrl", user.getPhotoUrl().toString());
        }
        m.putBoolean("isAnonymous", user.isAnonymous());
        m.putString("providerId", user.getProviderId());
        return m;
    }

    private Map<String, FirebaseAuth.AuthStateListener> authStateDidChangeListeners = new HashMap<>();

    static public void rejectFromException(Exception e, Promise promise) {
        // Error codes as per https://firebase.google.com/docs/reference/js/firebase.auth.Auth#createUserWithEmailAndPassword
        if (e instanceof FirebaseAuthWeakPasswordException) {
            promise.reject("auth/weak-password", e.getMessage());
            return;
        }
        if (e instanceof FirebaseAuthRecentLoginRequiredException) {
            promise.reject("auth/requires-recent-login", e.getMessage());
            return;
        }
        if (e instanceof FirebaseAuthUserCollisionException) {
            promise.reject("auth/email-already-in-use", e.getMessage());
            return;
        }
        if (e instanceof FirebaseAuthInvalidUserException) {
            String code = ((FirebaseAuthInvalidUserException)e).getErrorCode();
            if (code.equals("ERROR_USER_DISABLED")) {
                promise.reject("auth/user-disabled", e.getMessage());
            } else {
                promise.reject("auth/user-not-found", e.getMessage());
            }
            return;
        }
        if (e instanceof FirebaseAuthInvalidCredentialsException) {
            String code = ((FirebaseAuthInvalidCredentialsException) e).getErrorCode();
            if (code.equals("ERROR_INVALID_EMAIL")) {
                promise.reject("auth/invalid-email", e.getMessage());
            } else {
                promise.reject("auth/wrong-password", e.getMessage());
            }
            return;
        }
        promise.reject(e);
    }

    @ReactMethod
    public void addAuthStateDidChangeListener(final String appName, Promise promise) {
        if (authStateDidChangeListeners.containsKey(appName)) {
            promise.reject("auth_listener_registered", "Auth listener for app already registered");
            return;
        }
        FirebaseApp app = FirebaseApp.getInstance(appName);
        FirebaseAuth auth = FirebaseAuth.getInstance(app);
        FirebaseAuth.AuthStateListener listener = new FirebaseAuth.AuthStateListener() {
            @Override
            public void onAuthStateChanged(@NonNull FirebaseAuth firebaseAuth) {
                FirebaseUser user = firebaseAuth.getCurrentUser();
                WritableMap m = Arguments.createMap();
                m.putString("app", appName);
                if (user != null) {
                    m.putMap("user", convertUser(user));
                } else {
                    m.putNull("user");
                }
                sendEvent("authStateDidChange", m);
            }
        };
        auth.addAuthStateListener(listener);
        authStateDidChangeListeners.put(appName, listener);
        promise.resolve(null);
    }

    @ReactMethod
    public void signInWithEmail(String appName, String email, String password, final Promise promise) {
        FirebaseApp app = FirebaseApp.getInstance(appName);
        FirebaseAuth.getInstance(app).signInWithEmailAndPassword(email, password)
                .addOnSuccessListener(new OnSuccessListener<AuthResult>() {
                    @Override
                    public void onSuccess(AuthResult result) {
                        promise.resolve(convertUser(result.getUser()));
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        rejectFromException(e, promise);
                    }
                });
    }

    @ReactMethod
    public void signInAnonymously(String appName, final Promise promise) {
        FirebaseApp app = FirebaseApp.getInstance(appName);
        FirebaseAuth.getInstance(app).signInAnonymously()
                .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        try {
                            AuthResult result = task.getResult();
                            promise.resolve(convertUser(result.getUser()));
                        } catch (RuntimeExecutionException e) {
                            promise.reject(e);
                        }
                    }
                });
    }

    @ReactMethod
    public void createUserWithEmail(String appName, String email, String password, final Promise promise) {
        FirebaseApp app = FirebaseApp.getInstance(appName);
        FirebaseAuth.getInstance(app).createUserWithEmailAndPassword(email, password)
                .addOnSuccessListener(new OnSuccessListener<AuthResult>() {
                    @Override
                    public void onSuccess(AuthResult authResult) {
                        promise.resolve(convertUser(authResult.getUser()));
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        rejectFromException(e, promise);
                    }
                });
    }

    @ReactMethod
    public void signInWithCredential(String appName, String id, final Promise promise) {
        FirebaseApp app = FirebaseApp.getInstance(appName);
        AuthCredential credential = FirebaseBridgeCredentialCache.getCredential(id);
        if (credential == null) {
            promise.reject("auth/credential-not-found", "Credential not found");
            return;
        }
        FirebaseAuth.getInstance(app).signInWithCredential(credential)
                .addOnSuccessListener(new OnSuccessListener<AuthResult>() {
                    @Override
                    public void onSuccess(AuthResult result) {
                        promise.resolve(convertUser(result.getUser()));
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        rejectFromException(e, promise);
                    }
                });
    }

    @ReactMethod
    public void signOut(String appName, Promise promise) {
        FirebaseApp app = FirebaseApp.getInstance(appName);
        FirebaseAuth.getInstance(app).signOut();
        promise.resolve(null);
    }

    @ReactMethod
    public void sendPasswordResetEmail(String appName, String email, final Promise promise) {
        FirebaseApp app = FirebaseApp.getInstance(appName);
        FirebaseAuth.getInstance(app).sendPasswordResetEmail(email).addOnSuccessListener(new OnSuccessListener<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                promise.resolve(null);
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                rejectFromException(e, promise);
            }
        });
    }

    @ReactMethod
    public void fetchProvidersForEmail(String appName, String email, final Promise promise) {
        FirebaseApp app = FirebaseApp.getInstance(appName);
        FirebaseAuth.getInstance(app).fetchProvidersForEmail(email).addOnSuccessListener(new OnSuccessListener<ProviderQueryResult>() {
            @Override
            public void onSuccess(ProviderQueryResult providerQueryResult) {
                List<String> providers = providerQueryResult.getProviders();
                WritableArray data = Arguments.createArray();
                if (providers != null) {
                    for (String provider : providers) {
                        data.pushString(provider);
                    }
                }
                promise.resolve(data);
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                rejectFromException(e, promise);
            }
        });
    }

    @ReactMethod
    public void signInWithCustomToken(String appName, String token, final Promise promise) {
        FirebaseApp app = FirebaseApp.getInstance(appName);
        FirebaseAuth.getInstance(app).signInWithCustomToken(token).addOnSuccessListener(new OnSuccessListener<AuthResult>() {
            @Override
            public void onSuccess(AuthResult authResult) {
                promise.resolve(convertUser(authResult.getUser()));
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                rejectFromException(e, promise);
            }
        });
    }

}
