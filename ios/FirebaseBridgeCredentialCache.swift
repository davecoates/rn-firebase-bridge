//
//  FirebaseBridgeCredentialCache.swift
//  move
//
//  Created by Dave Coates on 20/08/2016.
//  Copyright © 2016 Facebook. All rights reserved.
//

import Firebase

class FirebaseBridgeCredentialCache {
  
  static let credentialCache = NSCache()
  
  static func addCredential(credential:FIRAuthCredential) -> String {
    let credentialUUID = NSUUID.init()
    self.credentialCache.setObject(credential, forKey: credentialUUID.UUIDString)
    return credentialUUID.UUIDString
  }
  
  static func getCredential(id:String) throws -> FIRAuthCredential {
    if let credential = credentialCache.objectForKey(id) as? FIRAuthCredential {
      return credential
    }
    throw FirebaseBridgeError.CredentialNotFound()
  }
  
}