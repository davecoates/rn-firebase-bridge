//
//  FirebaseBridgeAuth.swift
//
//  Created by Dave Coates on 20/08/2016.
//

import Firebase

@objc(FirebaseBridgeGithubAuthProvider)
class FirebaseBridgeGithubAuthProvider : NSObject {
  
  var bridge: RCTBridge!
  
  override init() {
    super.init()
  }
  
  @objc func credential(_ token:String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    print(token)
    let credential = FIRGitHubAuthProvider.credential(withToken: token)
    resolve([
      "id": FirebaseBridgeCredentialCache.addCredential(credential),
      "provider": credential.provider,
      ])
  }
}





