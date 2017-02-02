//
//  FirebaseBridgeAuth.swift
//
//  Created by Dave Coates on 20/08/2016.
//

import Firebase

@objc(FirebaseBridgeTwitterAuthProvider)
class FirebaseBridgeTwitterAuthProvider : NSObject {
  
  var bridge: RCTBridge!
  
  override init() {
    super.init()
  }
  
  @objc func credential(_ token:String, secret:String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    let credential = FIRTwitterAuthProvider.credential(withToken: token, secret: secret)
    resolve([
      "id": FirebaseBridgeCredentialCache.addCredential(credential),
      "provider": credential.provider,
      ])
  }
}





