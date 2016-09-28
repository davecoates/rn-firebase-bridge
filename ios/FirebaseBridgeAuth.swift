//
//  FirebaseBridgeAuth.swift
//
//  Created by Dave Coates on 4/06/2016.
//

import Firebase

func userToDict(user:FIRUser) -> Dictionary<String, AnyObject> {
  var data:Dictionary<String, AnyObject> = [
    "uid": user.uid,
    "emailVerified": user.emailVerified,
    "anonymous": user.anonymous,
  ]
  if let email = user.email {
    data["email"] = email
  }
  if let displayName = user.displayName {
    data["displayName"] = displayName
  }
  if let photoURL = user.photoURL {
    data["photoURL"] = photoURL.absoluteString
  }
  
  return data
}

func authErrorCodeToString(code:FIRAuthErrorCode) -> String {
  switch (code) {
  case .ErrorCodeUserDisabled:
    return "auth/user-disabled"
  case .ErrorCodeInvalidEmail:
    return "auth/invalid-email"
  case .ErrorCodeWrongPassword:
    return "auth/wrong-password"
  case .ErrorCodeUserNotFound:
    return "auth/user-not-found"
  case .ErrorCodeAppNotAuthorized:
    return "auth/app-not-authorized"
  case .ErrorCodeCredentialAlreadyInUse:
    return "auth/credential-already-in-use"
  case .ErrorCodeInvalidCustomToken:
    return "auth/invalid-custom-token"
  case .ErrorCodeCustomTokenMismatch:
    return "auth/custom-token-mismatch"
  case .ErrorCodeEmailAlreadyInUse:
    return "auth/email-already-in-use"
  case .ErrorCodeInvalidAPIKey:
    return "auth/invalid-api-key"
  case .ErrorCodeInvalidCredential:
    return "auth/invalid-credential"
  case .ErrorCodeInvalidUserToken:
    return "auth/invalid-user-token"
  case .ErrorCodeNetworkError:
    return "auth/network-request-failed"
  case .ErrrorCodeAccountExistsWithDifferentCredential:
    return "auth/account-exists-with-different-credential"
  case .ErrorCodeWeakPassword:
    return "auth/weak-password"
  case .ErrorCodeTooManyRequests:
    return "auth/too-many-requests"
  case .ErrorCodeOperationNotAllowed:
    return "auth/operation-not-allowed"
  case .ErrorCodeRequiresRecentLogin:
    return "auth/requires-recent-login"
  case .ErrorCodeUserTokenExpired:
    return "auth/user-token-expired"
    
  // These codes don't have equivalent in javascript API
  case .ErrorCodeInternalError:
    return "auth/internal-error"
  case .ErrorCodeUserMismatch:
    return "auth/user-mismatch"
  case .ErrorCodeKeychainError:
    return "auth/keychain-error"
  case .ErrorCodeProviderAlreadyLinked:
    return "auth/provider-already-linked"
  case .ErrorCodeNoSuchProvider:
    return "auth/no-such-provider"
  }
}


@objc(FirebaseBridgeAuth)
class FirebaseBridgeAuth: RCTEventEmitter, RCTInvalidating {
  
  func invalidate() {
    if let handle = self.authStateDidChangeListenerHandle {
      FIRAuth.auth()?.removeAuthStateDidChangeListener(handle)
    }
  }
  
  override init() {
    super.init()
  }
  
  
  override func supportedEvents() -> [String]! {
    return ["authStateDidChange"]
  }
  
  var authStateDidChangeListenerHandles = Dictionary<String, FIRAuthStateDidChangeListenerHandle>();
  
  var authStateDidChangeListenerHandle:FIRAuthStateDidChangeListenerHandle?;
  @objc func addAuthStateDidChangeListenerOLD() {
    self.authStateDidChangeListenerHandle = FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth:FIRAuth, user) in
      if (user == nil) {
        self.sendEventWithName("authStateDidChange", body: nil)
      } else {
        self.sendEventWithName("authStateDidChange", body: userToDict(user!))
      }
    })
  }
  
  @objc func addAuthStateDidChangeListener(appName: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if let app = FIRApp(named: appName) {
      resolve(nil)
      let handle = FIRAuth(app:app)?.addAuthStateDidChangeListener({ (auth:FIRAuth, user) in
        var userDict:Dictionary<String, AnyObject>? = nil
        if let user = user {
          userDict = userToDict(user)
        }
        let body:Dictionary<String, AnyObject> = [
          "app": appName,
          "user": userDict ?? false
        ]
        self.sendEventWithName("authStateDidChange", body: body)
      })
      authStateDidChangeListenerHandles[appName] = handle;
    } else {
      reject("app_not_found", "App with name \(appName) not found", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  @objc func createUserWithEmail(appName: String, email:String, password:String,
                                 resolver resolve: RCTPromiseResolveBlock,
                                 rejecter reject: RCTPromiseRejectBlock)
  {
    FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
      if let error = error {
        var code = ""
        if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
          code = authErrorCodeToString(errorCode)
        } else if let userInfo = error.userInfo as? Dictionary<String, AnyObject> {
          code = userInfo["error_name"] as! String
        }
        reject(code, error.localizedDescription, error);
        return;
      }
      
      resolve(userToDict(user!));
    }
  }
  
  @objc func signInWithEmail(email:String, password:String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
      if let error = error {
        var code = ""
        if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
          code = authErrorCodeToString(errorCode)
        } else if let userInfo = error.userInfo as? Dictionary<String, AnyObject> {
          code = userInfo["error_name"] as! String
        }
        reject(code, error.localizedDescription, error);
        return;
      }
      
      resolve(userToDict(user!));
    }
  }
  
  @objc func signInAnonymously(appName:String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    
    if let app = FIRApp(named: appName) {
      FIRAuth(app:app)?.signInAnonymouslyWithCompletion() { (user, error) in
        if let error = error {
          var code = ""
          if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
            code = authErrorCodeToString(errorCode)
          } else if let userInfo = error.userInfo as? Dictionary<String, AnyObject> {
            code = userInfo["error_name"] as! String
          }
          reject(code, error.localizedDescription, error);
          return;
        }
        
        resolve(userToDict(user!));
      }
    } else {
      reject("app_not_found", "App with name \(appName) not found", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  @objc func signInWithCredential(credentialId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if let credential = FirebaseBridgeCredentialCache.getCredential(credentialId) {
      
      FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
        if let error = error {
          var code = ""
          if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
            code = authErrorCodeToString(errorCode)
          } else if let userInfo = error.userInfo as? Dictionary<String, AnyObject> {
            code = userInfo["error_name"] as! String
          }
          reject(code, error.localizedDescription, error);
          return;
        }
        
        resolve(userToDict(user!));
      }
      )
    } else {
      reject("auth/credential-not-found", "Credential not found", NSError(domain: "FirebaseBridgeAuth", code: 0, userInfo: nil));
    }
  }
  
  @objc func signOut(appName: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if let app = FIRApp(named: appName) {
      do {
        try FIRAuth(app:app)?.signOut();
        resolve(nil)
      } catch let error as NSError {
        var code = ""
        if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
          code = authErrorCodeToString(errorCode)
        } else if let userInfo = error.userInfo as? Dictionary<String, AnyObject> {
          code = userInfo["error_name"] as! String
        }
        reject(code, error.localizedDescription, error);
      }
    } else {
      reject("app_not_found", "App with name \(appName) not found", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  @objc func getCurrentUser(appName:String, resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if let user = FIRAuth.auth()?.currentUser {
      resolve(userToDict(user))
    } else {
      resolve(nil)
    }
  }
  
  
}

