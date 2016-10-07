//  FirebaseApp.swift
//
//  Created by Dave Coates on 25/09/2016.
//

import Firebase

func appToDict(app:FIRApp) -> Dictionary<String, AnyObject> {
  let options = app.options
  let optionsDict = options.dictionaryWithValuesForKeys([
    "androidClientID",
    "APIKey",
    "databaseURL",
    "GCMSenderID",
    "googleAppID",
    "storageBucket",
    ])
  let data:Dictionary<String, AnyObject> = [
    "name": app.name,
    "options" : optionsDict,
  ]
  
  return data
}

@objc(FirebaseBridgeApp)
class FirebaseBridgeApp: NSObject, RCTInvalidating {
  
  func invalidate() {
    print("invalidate")
    if let apps = FIRApp.allApps() {
      for app in apps {
        (app.1 as! FIRApp).deleteApp({ (success) in
          if (!success) {
            print("Failed to delete app", app)
          }
        })
      }
    }
  }
  
  @objc func initializeApp(options:NSObject, name:String?, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    let fbOptions = FIROptions.init(
      googleAppID: options.valueForKey("googleAppID") as? String,
      bundleID: options.valueForKey("bundleID") as? String,
      GCMSenderID: options.valueForKey("GCMSenderID") as? String,
      APIKey: options.valueForKey("APIKey") as? String,
      clientID: options.valueForKey("clientID") as? String,
      trackingID: options.valueForKey("trackingID") as? String,
      androidClientID: options.valueForKey("androidClientID") as? String,
      databaseURL: options.valueForKey("databaseURL") as? String,
      storageBucket: options.valueForKey("storageBucket") as? String,
      deepLinkURLScheme: options.valueForKey("deepLinkURLScheme") as? String
    )
    var app:FIRApp?;
    if let name = name where name != "" {
      FIRApp.configureWithName(name, options: fbOptions)
      app = FIRApp(named: name)
    } else {
      //FIRApp.configure()
      FIRApp.configureWithOptions(fbOptions)
      app = FIRApp.defaultApp()
    }
    if let app = app {
      resolve(appToDict(app));
    } else {
      reject("app_initialize_failure", "App initialization failed", NSError(domain: "FirebaseBridge", code: 0, userInfo: nil))
    }
  }
  
  @objc func initializeDefaultApp(resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock)
  {
    FIRApp.configure();
    if let app = FIRApp.defaultApp() {
      resolve(appToDict(app));
    } else {
      reject("app_initialize_failure", "App initialization failed", NSError(domain: "FirebaseBridge", code: 0, userInfo: nil))
    }
  }

}
