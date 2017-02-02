//  FirebaseApp.swift
//
//  Created by Dave Coates on 25/09/2016.
//

import Firebase

func appToDict(_ app:FIRApp) -> Dictionary<String, AnyObject> {
  let options = app.options
  let optionsDict = options.dictionaryWithValues(forKeys: [
    "androidClientID",
    "APIKey",
    "databaseURL",
    "GCMSenderID",
    "googleAppID",
    "storageBucket",
    ])
  let data:Dictionary<String, AnyObject> = [
    "name": app.name as AnyObject,
    "options" : optionsDict as AnyObject,
  ]
  
  return data
}

@objc(FirebaseBridgeApp)
class FirebaseBridgeApp: NSObject, RCTInvalidating {
  
  func invalidate() {  
    /*
    // We don't want to do this; loses auth state etc
    if let apps = FIRApp.allApps() {
      for app in apps {
        (app.1 as! FIRApp).deleteApp({ (success) in
          if (!success) {
            print("Failed to delete app", app)
          }
        })
      }
    }
    */
  }
  
  @objc func initializeApp(_ options:NSObject, name:String?, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    
    if let app = FIRApp(named: name ?? "__FIRAPP_DEFAULT") {
      resolve(appToDict(app));
      return
    }
    
    let fbOptions = FIROptions.init(
      googleAppID: options.value(forKey: "googleAppID") as? String,
      bundleID: options.value(forKey: "bundleID") as? String,
      gcmSenderID: options.value(forKey: "GCMSenderID") as? String,
      apiKey: options.value(forKey: "APIKey") as? String,
      clientID: options.value(forKey: "clientID") as? String,
      trackingID: options.value(forKey: "trackingID") as? String,
      androidClientID: options.value(forKey: "androidClientID") as? String,
      databaseURL: options.value(forKey: "databaseURL") as? String,
      storageBucket: options.value(forKey: "storageBucket") as? String,
      deepLinkURLScheme: options.value(forKey: "deepLinkURLScheme") as? String
    )
    var app:FIRApp?;
    if let name = name, name != "" {
      FIRApp.configure(withName: name, options: fbOptions!)
      app = FIRApp(named: name)
    } else {
      //FIRApp.configure()
      FIRApp.configure(with: fbOptions!)
      app = FIRApp.defaultApp()
    }
    if let app = app {
      resolve(appToDict(app));
    } else {
      reject("app_initialize_failure", "App initialization failed", NSError(domain: "FirebaseBridge", code: 0, userInfo: nil))
    }
  }
  
  
  @objc func initializeDefaultApp(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock)
  {
    if let app = FIRApp(named:"__FIRAPP_DEFAULT") {
      resolve(appToDict(app));
      return
    }
    
    FIRApp.configure();
    if let app = FIRApp.defaultApp() {
      resolve(appToDict(app));
    } else {
      reject("app_initialize_failure", "App initialization failed", NSError(domain: "FirebaseBridge", code: 0, userInfo: nil))
    }
  }

}
