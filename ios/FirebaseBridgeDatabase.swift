//
//  FirebaseDatabase.swift
//  FirebaseBridge
//
//  Created by Dave Coates on 4/06/2016.
//  Copyright © 2016. All rights reserved.
//

import Firebase


@objc(FirebaseBridgeDatabase)
class FirebaseBridgeDatabase: NSObject {
  
  var bridge: RCTBridge!
  
  @objc func constantsToExport() -> Dictionary<String, AnyObject> {
    return [
      "DataEventTypes": [
        "ChildAdded": FIRDataEventType.ChildAdded.rawValue,
        "ChildChanged": FIRDataEventType.ChildChanged.rawValue,
        "ChildMoved": FIRDataEventType.ChildMoved.rawValue,
        "ChildRemoved": FIRDataEventType.ChildRemoved.rawValue,
        "Value": FIRDataEventType.Value.rawValue,
      ]
    ]
  }
  
  @objc func on(databaseUrl: String?, eventType:FIRDataEventType) {
    var ref:FIRDatabaseReference = FIRDatabase.database().reference()
    if let url = databaseUrl {
      ref = FIRDatabase.database().referenceFromURL(url)
    }
    ref.observeEventType(eventType, withBlock: { snapshot in
      let body:Dictionary<String, AnyObject> = [
        "url": snapshot.ref.description(),
        "eventType": eventType.rawValue,
        "value": snapshot.value ?? "",
        "exists": snapshot.exists(),
        "childrenCount": snapshot.childrenCount,
      ]
      self.bridge.eventDispatcher().sendAppEventWithName(
          "onDatabaseEvent", body: body)
      print(snapshot)
      }, withCancelBlock: { error in
        print(error)
    })
  }
  
  @objc func child(databaseUrl: String?, path:String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    var ref:FIRDatabaseReference = FIRDatabase.database().reference()
    if let url = databaseUrl {
      ref = FIRDatabase.database().referenceFromURL(url)
    }
    let nextRef = ref.child(path)
    resolve([
      "key": nextRef.key,
      "locationUrl": nextRef.description()
    ])
  }
  
  @objc func childByAutoId(databaseUrl: String?, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    var ref:FIRDatabaseReference = FIRDatabase.database().reference()
    if let url = databaseUrl {
      ref = FIRDatabase.database().referenceFromURL(url)
    }
    let nextRef = ref.childByAutoId()
    resolve([
      "key": nextRef.key,
      "locationUrl": nextRef.description()
    ])
  }
  
  @objc func setValue(databaseUrl:String, value:AnyObject) {
    FIRDatabase.database().referenceFromURL(databaseUrl).setValue(value)
  }
  
}