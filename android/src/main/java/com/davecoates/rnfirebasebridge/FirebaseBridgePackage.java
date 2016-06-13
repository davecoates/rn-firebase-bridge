package com.davecoates.rnfirebasebridge;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;
import com.facebook.react.bridge.JavaScriptModule;

import com.davecoates.rnfirebasebridge.FirebaseBridgeAuth;
import com.davecoates.rnfirebasebridge.FirebaseBridgeDatabase;
import com.google.firebase.database.FirebaseDatabase;

public class FirebaseBridgePackage implements ReactPackage {

  FirebaseDatabase mDatabaseInstance;

  public FirebaseBridgePackage(FirebaseDatabase instance) {
    super();
    mDatabaseInstance = instance;
  }

  @Override
  public List<Class<? extends JavaScriptModule>> createJSModules() {
    return Collections.emptyList();
  }

  @Override
  public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
    return Collections.emptyList();
  }

  @Override
  public List<NativeModule> createNativeModules(
                              ReactApplicationContext reactContext) {
    List<NativeModule> modules = new ArrayList<>();

    modules.add(new FirebaseBridgeAuth(reactContext));
    modules.add(new FirebaseBridgeDatabase(reactContext, mDatabaseInstance));

    return modules;
  }

}
