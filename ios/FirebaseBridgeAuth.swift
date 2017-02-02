//
//  FirebaseBridgeAuth.swift
//
//  Created by Dave Coates on 4/06/2016.
//

import Firebase

func userToDict(_ user:FIRUser) -> Dictionary<String, AnyObject> {
  var data:Dictionary<String, AnyObject> = [
    "uid": user.uid as AnyObject,
    "emailVerified": user.isEmailVerified as AnyObject,
    "isAnonymous": user.isAnonymous as AnyObject,
    "providerId": user.providerID as AnyObject,
  ]
  if let email = user.email {
    data["email"] = email as AnyObject?
  }
  if let displayName = user.displayName {
    data["displayName"] = displayName as AnyObject?
  }
  if let photoURL = user.photoURL {
    data["photoURL"] = photoURL.absoluteString as AnyObject?
  }
  
  return data
}

func authErrorCodeToString(_ code:FIRAuthErrorCode) -> String {
  switch (code) {
  case .errorCodeUserDisabled:
    return "auth/user-disabled"
  case .errorCodeInvalidEmail:
    return "auth/invalid-email"
  case .errorCodeWrongPassword:
    return "auth/wrong-password"
  case .errorCodeUserNotFound:
    return "auth/user-not-found"
  case .errorCodeAppNotAuthorized:
    return "auth/app-not-authorized"
  case .errorCodeCredentialAlreadyInUse:
    return "auth/credential-already-in-use"
  case .errorCodeInvalidCustomToken:
    return "auth/invalid-custom-token"
  case .errorCodeCustomTokenMismatch:
    return "auth/custom-token-mismatch"
  case .errorCodeEmailAlreadyInUse:
    return "auth/email-already-in-use"
  case .errorCodeInvalidAPIKey:
    return "auth/invalid-api-key"
  case .errorCodeInvalidCredential:
    return "auth/invalid-credential"
  case .errorCodeInvalidUserToken:
    return "auth/invalid-user-token"
  case .errorCodeNetworkError:
    return "auth/network-request-failed"
  case .errorCodeAccountExistsWithDifferentCredential:
    fallthrough
  case .errorCodeAccountExistsWithDifferentCredential:
    return "auth/account-exists-with-different-credential"
  case .errorCodeWeakPassword:
    return "auth/weak-password"
  case .errorCodeTooManyRequests:
    return "auth/too-many-requests"
  case .errorCodeOperationNotAllowed:
    return "auth/operation-not-allowed"
  case .errorCodeRequiresRecentLogin:
    return "auth/requires-recent-login"
  case .errorCodeUserTokenExpired:
    return "auth/user-token-expired"
  // These codes don't have equivalent in javascript API
  case .errorCodeInternalError:
    return "auth/internal-error"
  case .errorCodeUserMismatch:
    return "auth/user-mismatch"
  case .errorCodeKeychainError:
    return "auth/keychain-error"
  case .errorCodeProviderAlreadyLinked:
    return "auth/provider-already-linked"
  case .errorCodeNoSuchProvider:
    return "auth/no-such-provider"
  case .errorCodeInvalidActionCode:
    return "auth/invalid-action-code"
  case .errorCodeExpiredActionCode:
    return "auth/expired-action-code"
  }
}


@objc(FirebaseBridgeAuth)
class FirebaseBridgeAuth: RCTEventEmitter, RCTInvalidating {
  
  func invalidate() {
    self.authStateDidChangeListenerHandles.forEach { (appName, handle) in
      do {
        try self.getAuthInstance(appName)?.removeStateDidChangeListener(handle)
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
  
  func getAuthInstance(_ appName:String) throws -> FIRAuth? {
     if let app = FIRApp(named: appName) {
      return FIRAuth(app:app)
    }
    throw FirebaseBridgeError.appNotFound(appName: appName)
  }
  
  fileprivate func reject(_ reject: RCTPromiseRejectBlock, error: NSError) {
    var code = ""
    if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
      code = authErrorCodeToString(errorCode)
    } else if let userInfo = error.userInfo as? Dictionary<String, AnyObject> {
      code = userInfo["error_name"] as! String
    }
    reject(code, error.localizedDescription,  NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
  }
  
  
  var authStateDidChangeListenerHandles = Dictionary<String, FIRAuthStateDidChangeListenerHandle>();
  
  @objc func addAuthStateDidChangeListener(_ appName: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    do {
      let auth = try self.getAuthInstance(appName)
      let handle = auth?.addStateDidChangeListener({ (auth:FIRAuth, user) in
        var userDict:Dictionary<String, AnyObject>? = nil
        if let user = user {
          userDict = userToDict(user)
        }
        let body:Dictionary<String, AnyObject> = [
          "app": appName as AnyObject,
          "user": userDict as AnyObject? ?? false as AnyObject
        ]
        self.sendEvent(withName: "authStateDidChange", body: body)
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
  
  @objc func createUserWithEmail(_ appName: String, email:String, password:String,
                                 resolver resolve: @escaping RCTPromiseResolveBlock,
                                 rejecter reject: @escaping RCTPromiseRejectBlock)
  {
    do {
      try self.getAuthInstance(appName)?.createUser(withEmail: email, password: password) { (user, error) in
        if let error = error {
          self.reject(reject, error: error as NSError)
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
  
  @objc func signInWithEmail(_ appName: String, email:String, password:String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    do {
      try self.getAuthInstance(appName)?.signIn(withEmail: email, password: password) { (user, error) in
        if let error = error {
          self.reject(reject, error: error as NSError)
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
  
  @objc func signInAnonymously(_ appName:String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    do {
      try self.getAuthInstance(appName)?.signInAnonymously() { (user, error) in
        if let error = error {
          self.reject(reject, error: error as NSError)
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
  
  @objc func signInWithCredential(_ appName:String, credentialId: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    do {
      let credential = try FirebaseBridgeCredentialCache.getCredential(credentialId)
      try self.getAuthInstance(appName)?.signIn(with: credential, completion: { (user, error) in
        if let error = error {
          self.reject(reject, error: error as NSError)
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
  
  @objc func signOut(_ appName: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
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
    
  @objc func sendPasswordResetEmail(_ appName: String, email: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    do {
        try self.getAuthInstance(appName)?.sendPasswordReset(withEmail: email, completion: { (error) in
            if let error = error {
                self.reject(reject, error: error as NSError)
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
    
  @objc func fetchProvidersForEmail(_ appName: String, email: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    do {
        try self.getAuthInstance(appName)?.fetchProviders(forEmail: email, completion: { (providers, error) in
            if let error = error {
                self.reject(reject, error: error as NSError)
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
    
  @objc func signInWithCustomToken(_ appName: String, token: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    do {
        try self.getAuthInstance(appName)?.signIn(withCustomToken: token, completion: { (user, error) in
            if let error = error {
                self.reject(reject, error: error as NSError)
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

