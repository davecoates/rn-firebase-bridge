//
//  FirebaseBridgeUser.swift
//  testapp
//
//  Created by Dave Coates on 1/10/2016.
//

import Firebase

@objc(FirebaseBridgeUser)
class FirebaseBridgeUser : NSObject {
  
  func getUser(_ appName:String) throws -> FIRUser {
     if let app = FIRApp(named: appName) {
      if let user = FIRAuth(app:app)?.currentUser {
        return user
      }
      throw FirebaseBridgeError.userNotLoggedIn()
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
  
  @objc func sendEmailVerification(_ appName:String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock)
  {
    do {
      try self.getUser(appName).sendEmailVerification{ (error) in
        if let error = error {
          self.reject(reject, error: error as NSError)
          return;
        }
        resolve(nil)
      }
    } catch let error as FirebaseBridgeError {
      reject(error.code, error.description, nil)
      return
    } catch let unknownError as NSError {
      reject("unknown_error", unknownError.localizedDescription, unknownError)
      return
    }
  }
  
  @objc func delete(_ appName:String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock)
  {
    do {
      try self.getUser(appName).delete{ (error) in
        if let error = error {
          self.reject(reject, error: error as NSError)
          return;
        }
        resolve(nil)
      }
    } catch let error as FirebaseBridgeError {
      reject(error.code, error.description, nil)
      return
    } catch let unknownError as NSError {
      reject("unknown_error", unknownError.localizedDescription, unknownError)
      return
    }
  }
  
  @objc func getToken(_ appName:String, forceRefresh:Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock)
  {
    do {
      try self.getUser(appName).getTokenForcingRefresh(forceRefresh, completion: { (token, error) in
        if let error = error {
          self.reject(reject, error: error as NSError)
          return;
        }
        resolve(token)
      })
    } catch let error as FirebaseBridgeError {
      reject(error.code, error.description, nil)
      return
    } catch let unknownError as NSError {
      reject("unknown_error", unknownError.localizedDescription, unknownError)
      return
    }
  }
  
  @objc func link(_ appName:String, credentialId: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock)
  {
    do {
      let credential = try FirebaseBridgeCredentialCache.getCredential(credentialId)
      try self.getUser(appName).link(with: credential, completion: { (user, error) in
        if let error = error {
          self.reject(reject, error: error as NSError)
          return;
        }
        resolve(userToDict(user!))
      })
    } catch let error as FirebaseBridgeError {
      reject(error.code, error.description, nil)
      return
    } catch let unknownError as NSError {
      reject("unknown_error", unknownError.localizedDescription, unknownError)
      return
    }
  }
  
  @objc func reauthenticate(_ appName:String, credentialId: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock)
  {
    do {
      let credential = try FirebaseBridgeCredentialCache.getCredential(credentialId)
      try self.getUser(appName).reauthenticate(with: credential, completion: { (error) in
        if let error = error {
          self.reject(reject, error: error as NSError)
          return;
        }
        resolve(nil)
      })
    } catch let error as FirebaseBridgeError {
      reject(error.code, error.description, nil)
      return
    } catch let unknownError as NSError {
      reject("unknown_error", unknownError.localizedDescription, unknownError)
      return
    }
  }
  
  @objc func reload(_ appName:String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock)
  {
    do {
      try self.getUser(appName).reload() { (error) in
        if let error = error {
          self.reject(reject, error: error as NSError)
          return;
        }
        resolve(nil)
      }
    } catch let error as FirebaseBridgeError {
      reject(error.code, error.description, nil)
      return
    } catch let unknownError as NSError {
      reject("unknown_error", unknownError.localizedDescription, unknownError)
      return
    }
  }
  
  @objc func unlink(_ appName:String, providerId: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock)
  {
    do {
      try self.getUser(appName).unlink(fromProvider: providerId, completion: { (user, error) in
        if let error = error {
          self.reject(reject, error: error as NSError)
          return;
        }
        resolve(userToDict(user!))
      })
    } catch let error as FirebaseBridgeError {
      reject(error.code, error.description, nil)
      return
    } catch let unknownError as NSError {
      reject("unknown_error", unknownError.localizedDescription, unknownError)
      return
    }
  }
  
  @objc func updateEmail(_ appName:String, newEmail: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock)
  {
    do {
      try self.getUser(appName).updateEmail(newEmail, completion: { (error) in
        if let error = error {
          self.reject(reject, error: error as NSError)
          return;
        }
        resolve(nil)
      })
    } catch let error as FirebaseBridgeError {
      reject(error.code, error.description, nil)
      return
    } catch let unknownError as NSError {
      reject("unknown_error", unknownError.localizedDescription, unknownError)
      return
    }
  }
  
  @objc func updatePassword(_ appName:String, newPassword: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock)
  {
    do {
      try self.getUser(appName).updatePassword(newPassword, completion: { (error) in
        if let error = error {
          self.reject(reject, error: error as NSError)
          return;
        }
        resolve(nil)
      })
    } catch let error as FirebaseBridgeError {
      reject(error.code, error.description, nil)
      return
    } catch let unknownError as NSError {
      reject("unknown_error", unknownError.localizedDescription, unknownError)
      return
    }
  }
  
  @objc func updateProfile(_ appName:String, profile: [AnyObject], resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock)
  {
    do {
      let data = profile[0] as! Dictionary<String, AnyObject>
      let user = try self.getUser(appName)
      let changeRequest = user.profileChangeRequest()
      if let displayName = data["displayName"] {
        changeRequest.displayName = displayName as? String
      }
      if let photoURL = data["photoURL"] {
        changeRequest.photoURL = URL(string: photoURL as! String)
      }
      changeRequest.commitChanges() { (error) in
        if let error = error {
          self.reject(reject, error: error as NSError)
          return;
        }
        // TODO: Should we resolve with updated user? User change doesn't
        // seem to fire
        resolve(nil)
      }
    } catch let error as FirebaseBridgeError {
      reject(error.code, error.description, nil)
      return
    } catch let unknownError as NSError {
      reject("unknown_error", unknownError.localizedDescription, unknownError)
      return
    }
  }
  
}




