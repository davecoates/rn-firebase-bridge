//
//  FirebaseBridgeUser.swift
//
//  Created by Batuhan Icoz on 24/08/2016.
//

import Firebase

@objc(FirebaseBridgeUser)
class FirebaseBridgeUser : NSObject {
  
  var bridge: RCTBridge!
  
  override init() {
    super.init()
  }
  
  
  @objc func updateEmail(email: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    
    let user = FIRAuth.auth()?.currentUser
    
    user?.updateEmail(email) { error in
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

      resolve(nil);
    }
  }
  
  
  @objc func updatePassword(password: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    
    let user = FIRAuth.auth()?.currentUser
    
    user?.updatePassword(password) { error in
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
      resolve(nil);
    }
  }
  
  @objc func sendEmailVerification(resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    
    let user = FIRAuth.auth()?.currentUser

    user?.sendEmailVerificationWithCompletion() { error in
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
      
      resolve(nil);
    }
  }
  
  
  @objc func reauthenticateWithCredential(credentialId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

    if let credential = FirebaseBridgeCredentialCache.getCredential(credentialId) {

      let user = FIRAuth.auth()?.currentUser

      user?.reauthenticateWithCredential(credential, completion: { (error) in
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

        resolve(nil);
        }
      )
    } else {
      reject("auth/credential-not-found", "Credential not found", NSError(domain: "FirebaseBridgeAuth", code: 0, userInfo: nil));
    }
  }


}

