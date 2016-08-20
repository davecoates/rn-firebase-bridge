//
//  FirebaseBridgeAuth.swift
//
//  Created by Dave Coates on 20/08/2016.
//

import Firebase

@objc(FirebaseBridgeFacebookAuthProvider)
class FirebaseBridgeFacebookAuthProvider : NSObject {
  
  var bridge: RCTBridge!
  
  override init() {
    super.init()
  }
  
  @objc func credential(token:String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    let credential = FIRFacebookAuthProvider.credentialWithAccessToken(token)
    resolve([
      "id": FirebaseBridgeCredentialCache.addCredential(credential),
      "provider": credential.provider,
    ])
  }
}
  



