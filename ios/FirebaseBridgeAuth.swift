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
    "isAnonymous": user.anonymous,
    "providerId": user.providerID,
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
    self.authStateDidChangeListenerHandles.forEach { (appName, handle) in
      do {
        try self.getAuthInstance(appName)?.removeAuthStateDidChangeListener(handle)
      } catch let unknownError {
        print("Failed to cleanup auth listeners for \(appName)", unknownError)
      }
    }
  }
  
  override init() {
    super.init()
  }
  
  override func supportedEvents() -> [String]! {
    return ["authStateDidChange"]
  }
  
  func getAuthInstance(appName:String) throws -> FIRAuth? {
     if let app = FIRApp(named: appName) {
      return FIRAuth(app:app)
    }
    throw FirebaseBridgeError.AppNotFound(appName: appName)
  }
  
  private func reject(reject: RCTPromiseRejectBlock, error: NSError) {
    var code = ""
    if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
      code = authErrorCodeToString(errorCode)
    } else if let userInfo = error.userInfo as? Dictionary<String, AnyObject> {
      code = userInfo["error_name"] as! String
    }
    reject(code, error.localizedDescription,  NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
  }
  
  
  var authStateDidChangeListenerHandles = Dictionary<String, FIRAuthStateDidChangeListenerHandle>();
  
  @objc func addAuthStateDidChangeListener(appName: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    do {
      let auth = try self.getAuthInstance(appName)
      let handle = auth?.addAuthStateDidChangeListener({ (auth:FIRAuth, user) in
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
      resolve(nil)
      authStateDidChangeListenerHandles[appName] = handle;
    } catch let error as FirebaseBridgeError {
      reject(error.code, error.description, nil)
      return
    } catch let unknownError as NSError {
      reject("unknown_error", unknownError.localizedDescription, unknownError)
      return
    }
  }
  
  @objc func createUserWithEmail(appName: String, email:String, password:String,
                                 resolver resolve: RCTPromiseResolveBlock,
                                 rejecter reject: RCTPromiseRejectBlock)
  {
    do {
      try self.getAuthInstance(appName)?.createUserWithEmail(email, password: password) { (user, error) in
        if let error = error {
          self.reject(reject, error: error)
          return;
        }
        
        resolve(userToDict(user!));
      }
    } catch let error as FirebaseBridgeError {
      reject(error.code, error.description, nil)
      return
    } catch let unknownError as NSError {
      reject("unknown_error", unknownError.localizedDescription, unknownError)
      return
    }
  }
  
  @objc func signInWithEmail(appName: String, email:String, password:String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    do {
      try self.getAuthInstance(appName)?.signInWithEmail(email, password: password) { (user, error) in
        if let error = error {
          self.reject(reject, error: error)
          return;
        }
        
        resolve(userToDict(user!));
      }
    } catch let error as FirebaseBridgeError {
      reject(error.code, error.description, nil)
      return
    } catch let unknownError as NSError {
      reject("unknown_error", unknownError.localizedDescription, unknownError)
      return
    }
  }
  
  @objc func signInAnonymously(appName:String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    do {
      try self.getAuthInstance(appName)?.signInAnonymouslyWithCompletion() { (user, error) in
        if let error = error {
          self.reject(reject, error: error)
          return;
        }
        resolve(userToDict(user!));
      }
    } catch let error as FirebaseBridgeError {
      reject(error.code, error.description, nil)
      return
    } catch let unknownError as NSError {
      reject("unknown_error", unknownError.localizedDescription, unknownError)
      return
    }
  }
  
  @objc func signInWithCredential(appName:String, credentialId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    do {
      let credential = try FirebaseBridgeCredentialCache.getCredential(credentialId)
      try self.getAuthInstance(appName)?.signInWithCredential(credential, completion: { (user, error) in
        if let error = error {
          self.reject(reject, error: error)
          return;
        }
        resolve(userToDict(user!));
      })
    } catch let error as FirebaseBridgeError {
      reject(error.code, error.description, nil)
      return
    } catch let unknownError as NSError {
      reject("unknown_error", unknownError.localizedDescription, unknownError)
      return
    }
  }
  
  @objc func signOut(appName: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    do {
      try self.getAuthInstance(appName)?.signOut();
      resolve(nil)
    } catch let error as FirebaseBridgeError {
      reject(error.code, error.description, nil)
      return
    } catch let unknownError as NSError {
      reject("unknown_error", unknownError.localizedDescription, unknownError)
      return
    }
  }
    
  @objc func sendPasswordResetEmail(appName: String, email: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    do {
        try self.getAuthInstance(appName)?.sendPasswordResetWithEmail(email, completion: { (error) in
            if let error = error {
                self.reject(reject, error: error)
            } else {
                resolve(nil)
            }
        })
    } catch let error as FirebaseBridgeError {
        reject(error.code, error.description, nil)
        return
    } catch let unknownError as NSError {
        reject("unknown_error", unknownError.localizedDescription, unknownError)
        return
    }
  }
    
  @objc func fetchProvidersForEmail(appName: String, email: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    do {
        try self.getAuthInstance(appName)?.fetchProvidersForEmail(email, completion: { (providers, error) in
            if let error = error {
                self.reject(reject, error: error)
            } else {
                resolve(providers)
            }
        })
    } catch let error as FirebaseBridgeError {
        reject(error.code, error.description, nil)
        return
    } catch let unknownError as NSError {
        reject("unknown_error", unknownError.localizedDescription, unknownError)
        return
    }
  }
    
  @objc func signInWithCustomToken(appName: String, token: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    do {
        try self.getAuthInstance(appName)?.signInWithCustomToken(token, completion: { (user, error) in
            if let error = error {
                self.reject(reject, error: error)
                return;
            }
            resolve(userToDict(user!));
        })
    } catch let error as FirebaseBridgeError {
        reject(error.code, error.description, nil)
        return
    } catch let unknownError as NSError {
        reject("unknown_error", unknownError.localizedDescription, unknownError)
        return
    }
  }
    
}

