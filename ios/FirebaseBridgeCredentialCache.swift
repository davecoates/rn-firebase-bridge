//
//  FirebaseBridgeCredentialCache.swift
//  move
//
//  Created by Dave Coates on 20/08/2016.
//  Copyright © 2016 Facebook. All rights reserved.
//

import Firebase

class FirebaseBridgeCredentialCache {
  
  static let credentialCache = NSCache<AnyObject, AnyObject>()
  
  static func addCredential(_ credential:FIRAuthCredential) -> String {
    let credentialUUID = UUID.init()
    self.credentialCache.setObject(credential, forKey: credentialUUID.uuidString as AnyObject)
    return credentialUUID.uuidString
  }
  
  static func getCredential(_ id:String) throws -> FIRAuthCredential {
    if let credential = credentialCache.object(forKey: id as AnyObject) as? FIRAuthCredential {
      return credential
    }
    throw FirebaseBridgeError.credentialNotFound()
  }
  
}
