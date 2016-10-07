package com.davecoates.rnfirebasebridge;

import com.facebook.react.bridge.*;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.FirebaseOptions;


public class FirebaseBridgeApp extends ReactContextBaseJavaModule {

    public FirebaseBridgeApp(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "FirebaseBridgeApp";
    }

    private WritableMap convertApp(FirebaseApp app) {
        final WritableMap optionsMap = Arguments.createMap();
        FirebaseOptions options = app.getOptions();
        optionsMap.putString("APIKey", options.getApiKey());
        optionsMap.putString("databaseURL", options.getDatabaseUrl());
        optionsMap.putString("GCMSenderId", options.getGcmSenderId());
        optionsMap.putString("googleAppID", options.getApplicationId());
        optionsMap.putString("storageBucket", options.getStorageBucket());
        final WritableMap m = Arguments.createMap();
        m.putString("name", app.getName());
        m.putMap("options", optionsMap);
        return m;
    }

    @ReactMethod
    public void initializeDefaultApp(Promise promise)
    {
        FirebaseApp app = FirebaseApp.initializeApp(
                this.getReactApplicationContext());
        promise.resolve(convertApp(app));
    }

    @ReactMethod
    public void initializeApp(ReadableMap options, String name, Promise promise)
    {
        FirebaseOptions.Builder builder = new FirebaseOptions.Builder();
        if (options.hasKey("APIKey")) {
            builder.setApiKey(options.getString("APIKey"));
        }
        if (options.hasKey("googleAppID")) {
            builder.setApplicationId(options.getString("googleAppID"));
        }
        if (options.hasKey("databaseURL")) {
            builder.setDatabaseUrl(options.getString("databaseURL"));
        }
        if (options.hasKey("GCMSenderID")) {
            builder.setGcmSenderId(options.getString("GCMSenderID"));
        }
        if (options.hasKey("storageBucket")) {
            builder.setGcmSenderId(options.getString("storageBucket"));
        }
        FirebaseApp app = FirebaseApp.initializeApp(
                this.getReactApplicationContext(),
                builder.build(),
                name
        );
        promise.resolve(convertApp(app));
    }
}
