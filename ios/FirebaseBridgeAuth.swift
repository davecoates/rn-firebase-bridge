//
//  FirebaseBridgeAuth.swift
//
//  Created by Dave Coates on 4/06/2016.
//

import Firebase

func userToDict(user:FIRUser) -> Dictionary<String, AnyObject> {
  return [
    "uid": user.uid,
    "email": (user.email ?? ""),
    "emailVerified": user.emailVerified,
    "displayName": (user.displayName ?? ""),
    "photoUrl": (user.photoURL ?? ""),
    "anonymous": user.anonymous,
  ]
}


@objc(FirebaseBridgeAuth)
class FirebaseBridgeAuth: NSObject, RCTInvalidating {
  
  var bridge: RCTBridge!
  
  func invalidate() {
    if let handle = self.authStateDidChangeListenerHandle {
      FIRAuth.auth()?.removeAuthStateDidChangeListener(handle)
    }
  }
  
  override init() {
    super.init()
  }
  
  var authStateDidChangeListenerHandle:FIRAuthStateDidChangeListenerHandle?;
  @objc func addAuthStateDidChangeListener() {
    self.authStateDidChangeListenerHandle = FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth:FIRAuth, user) in
      if (user == nil) {
        self.bridge.eventDispatcher().sendAppEventWithName(
          "authStateDidChange", body: [])
      } else {
        self.bridge.eventDispatcher().sendAppEventWithName(
          "authStateDidChange", body: ["user": userToDict(user!)])
      }
    })
  }
  
  @objc func createUserWithEmail(email:String, password:String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
      if (user == nil) {
        var name = ""
        if let userInfo = error?.userInfo as? Dictionary<String, AnyObject> {
          name = userInfo["error_name"] as! String
        }
        reject(name, error?.localizedDescription, error);
        return;
      }
      
      resolve(userToDict(user!));
    }
  }
  
  @objc func signInWithEmail(email:String, password:String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
      if (user == nil) {
        var name = ""
        if let userInfo = error?.userInfo as? Dictionary<String, AnyObject> {
          name = userInfo["error_name"] as! String
        }
        reject(name, error?.localizedDescription, error);
        return;
      }
      
      resolve(userToDict(user!));
    }
  }
  
  
}

