//
//  FirebaseBridgeAuth.swift
//
//  Created by Dave Coates on 20/08/2016.
//

import Firebase

@objc(FirebaseBridgeGoogleAuthProvider)
class FirebaseBridgeGoogleAuthProvider : NSObject {
  
  var bridge: RCTBridge!
  
  override init() {
    super.init()
  }
  
  @objc func credential(idToken:String, accessToken:String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    let credential = FIRGoogleAuthProvider.credentialWithIDToken(idToken, accessToken: accessToken)
    resolve([
      "id": FirebaseBridgeCredentialCache.addCredential(credential),
      "provider": credential.provider,
      ])
  }
}





