//
//  FirebaseBridgeUser.swift
//  testapp
//
//  Created by Dave Coates on 1/10/2016.
//

import Firebase

@objc(FirebaseBridgeUser)
class FirebaseBridgeUser : NSObject {
  
  func getUser(appName:String) throws -> FIRUser {
     if let app = FIRApp(named: appName) {
      if let user = FIRAuth(app:app)?.currentUser {
        return user
      }
      throw FirebaseBridgeError.UserNotLoggedIn()
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
  
  @objc func sendEmailVerification(appName:String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock)
  {
    do {
      try self.getUser(appName).sendEmailVerificationWithCompletion{ (error) in
        if let error = error {
          self.reject(reject, error: error)
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
  
  @objc func delete(appName:String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock)
  {
    do {
      try self.getUser(appName).deleteWithCompletion{ (error) in
        if let error = error {
          self.reject(reject, error: error)
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
  
  @objc func getToken(appName:String, forceRefresh:Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock)
  {
    do {
      try self.getUser(appName).getTokenForcingRefresh(forceRefresh, completion: { (token, error) in
        if let error = error {
          self.reject(reject, error: error)
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
  
  @objc func link(appName:String, credentialId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock)
  {
    do {
      let credential = try FirebaseBridgeCredentialCache.getCredential(credentialId)
      try self.getUser(appName).linkWithCredential(credential, completion: { (user, error) in
        if let error = error {
          self.reject(reject, error: error)
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
  
  @objc func reauthenticate(appName:String, credentialId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock)
  {
    do {
      let credential = try FirebaseBridgeCredentialCache.getCredential(credentialId)
      try self.getUser(appName).reauthenticateWithCredential(credential, completion: { (error) in
        if let error = error {
          self.reject(reject, error: error)
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
  
  @objc func reload(appName:String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock)
  {
    do {
      try self.getUser(appName).reloadWithCompletion() { (error) in
        if let error = error {
          self.reject(reject, error: error)
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
  
  @objc func unlink(appName:String, providerId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock)
  {
    do {
      try self.getUser(appName).unlinkFromProvider(providerId, completion: { (user, error) in
        if let error = error {
          self.reject(reject, error: error)
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
  
  @objc func updateEmail(appName:String, newEmail: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock)
  {
    do {
      try self.getUser(appName).updateEmail(newEmail, completion: { (error) in
        if let error = error {
          self.reject(reject, error: error)
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
  
  @objc func updatePassword(appName:String, newPassword: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock)
  {
    do {
      try self.getUser(appName).updatePassword(newPassword, completion: { (error) in
        if let error = error {
          self.reject(reject, error: error)
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
  
  @objc func updateProfile(appName:String, profile: [AnyObject], resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock)
  {
    do {
      let data = profile[0] as! Dictionary<String, AnyObject>
      let user = try self.getUser(appName)
      let changeRequest = user.profileChangeRequest()
      if let displayName = data["displayName"] {
        changeRequest.displayName = displayName as? String
      }
      if let photoURL = data["photoURL"] {
        changeRequest.photoURL = NSURL(string: photoURL as! String)
      }
      changeRequest.commitChangesWithCompletion() { (error) in
        if let error = error {
          self.reject(reject, error: error)
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




