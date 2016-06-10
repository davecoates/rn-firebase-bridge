//
//  FirebaseDatabase.swift
//
//  Created by Dave Coates on 4/06/2016.
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
  
  let snapshotCache = NSCache()
  
  func cacheSnapshotAndConvert(snapshot:FIRDataSnapshot) -> Dictionary<String, AnyObject> {
    let snapshotUUID = NSUUID.init()
    self.snapshotCache.setObject(snapshot, forKey: snapshotUUID.UUIDString)
    
    // This whole this is possibly a terrible idea..?
    // Remove cached snapshot after a delay. Snapshot is retained
    // so can perform further queries on it if desired.
    let triggerTime = (Int64(NSEC_PER_SEC) * 10)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
      self.snapshotCache.removeObjectForKey(snapshotUUID.UUIDString)
    })
    let body:Dictionary<String, AnyObject> = [
      "ref": self.convertRef(snapshot.ref),
      "value": snapshot.value ?? "",
      "exists": snapshot.exists(),
      "childrenCount": snapshot.childrenCount,
      "uuid": snapshotUUID.UUIDString,
    ]
    return body
  }
  
  @objc func childSnapshotForPath(snapshotUUID: String, path: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if let snapshot = self.snapshotCache.objectForKey(snapshotUUID) as? FIRDataSnapshot {
      let childSnapshot = snapshot.childSnapshotForPath(path)
      resolve(cacheSnapshotAndConvert(childSnapshot))
    } else {
      reject("snapshot_expired", "Data snapshot has expired", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  var databaseEventHandles = Dictionary<String, (FIRDatabaseReference, FIRDatabaseHandle)>();
  
  @objc func on(databaseUrl: String?, eventType:FIRDataEventType, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    var ref:FIRDatabaseReference = FIRDatabase.database().reference()
    if let url = databaseUrl {
      ref = FIRDatabase.database().referenceFromURL(url)
    }
    let handleUUID = NSUUID.init()
    resolve(handleUUID.UUIDString)
    let handle = ref.observeEventType(eventType, withBlock: { snapshot in
      self.bridge.eventDispatcher().sendAppEventWithName(
          handleUUID.UUIDString, body: self.cacheSnapshotAndConvert(snapshot))
      })
    
    self.databaseEventHandles[handleUUID.UUIDString] = (ref, handle)
  }
  
  @objc func off(handleUUID:String) {
    if let (ref, handle) = databaseEventHandles[handleUUID] {
      ref.removeObserverWithHandle(handle)
    }
  }
  
  func convertRef(ref:FIRDatabaseReference) -> Dictionary<String, String> {
    return [
      "key": ref.key,
      "locationUrl": ref.description()
    ]
  }
  
  @objc func child(databaseUrl: String?, path:String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    var ref:FIRDatabaseReference = FIRDatabase.database().reference()
    if let url = databaseUrl {
      ref = FIRDatabase.database().referenceFromURL(url)
    }
    let nextRef = ref.child(path)
    resolve(convertRef(nextRef));
  }
  
  @objc func childByAutoId(databaseUrl: String?, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    var ref:FIRDatabaseReference = FIRDatabase.database().reference()
    if let url = databaseUrl {
      ref = FIRDatabase.database().referenceFromURL(url)
    }
    let nextRef = ref.childByAutoId()
    resolve(convertRef(nextRef));
  }
  
  @objc func setValue(databaseUrl:String, value:AnyObject) {
    FIRDatabase.database().referenceFromURL(databaseUrl).setValue(value)
  }
  
}
