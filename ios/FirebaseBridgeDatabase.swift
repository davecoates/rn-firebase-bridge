//
//  FirebaseDatabase.swift
//
//  Created by Dave Coates on 4/06/2016.
//

import Firebase

// These match the node.js event names and are what we get from JS
enum JsDataEventType : String {
    case ChildAdded = "child_added"
    case ChildRemoved = "child_removed"
    case ChildChanged = "child_changed"
    case ChildMoved = "child_moved"
    case Value = "value"
}

// Map the above to FIRDataEventType's
let jsEventTypeMapping = [
  JsDataEventType.Value: FIRDataEventType.Value,
  JsDataEventType.ChildAdded: FIRDataEventType.ChildAdded,
  JsDataEventType.ChildRemoved: FIRDataEventType.ChildRemoved,
  JsDataEventType.ChildChanged: FIRDataEventType.ChildChanged,
  JsDataEventType.ChildMoved: FIRDataEventType.ChildMoved,
];


@objc(FirebaseBridgeDatabase)
class FirebaseBridgeDatabase: NSObject, RCTInvalidating {
  
  var bridge: RCTBridge!
  
  func invalidate() {
    self.databaseEventHandles.forEach { (_, pair) in
      pair.0.removeObserverWithHandle(pair.1)
    }
  }
  
  let snapshotCache = NSCache()
  
  func cacheSnapshotAndConvert(snapshot:FIRDataSnapshot) -> Dictionary<String, AnyObject> {
    let snapshotUUID = NSUUID.init()
    self.snapshotCache.setObject(snapshot, forKey: snapshotUUID.UUIDString)
    var body:Dictionary<String, AnyObject> = [
      "ref": self.convertRef(snapshot.ref),
      "exists": snapshot.exists(),
      "childrenCount": snapshot.childrenCount,
      "hasChildren": snapshot.hasChildren(),
      "uuid": snapshotUUID.UUIDString,
    ]
    if let priority = snapshot.priority {
      body["priority"] = priority
    }
    return body
  }
  
  @objc func snapshotChild(snapshotUUID: String, path: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if let snapshot = self.snapshotCache.objectForKey(snapshotUUID) as? FIRDataSnapshot {
      let childSnapshot = snapshot.childSnapshotForPath(path)
      resolve(cacheSnapshotAndConvert(childSnapshot))
    } else {
      reject("snapshot_not_found", "Snapshot not found; it may have been released.", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  @objc func snapshotHasChild(snapshotUUID: String, path: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if let snapshot = self.snapshotCache.objectForKey(snapshotUUID) as? FIRDataSnapshot {
      resolve(snapshot.hasChild(path))
    } else {
      reject("snapshot_not_found", "Snapshot not found; it may have been released.", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  @objc func releaseSnapshot(snapshotUUID: String) {
    self.snapshotCache.removeObjectForKey(snapshotUUID)
  }
  
  @objc func snapshotValue(snapshotUUID: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if let snapshot = self.snapshotCache.objectForKey(snapshotUUID) as? FIRDataSnapshot {
      resolve(snapshot.value)
    } else {
      reject("snapshot_not_found", "Snapshot not found; it may have been released.", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  @objc func snapshotExportValue(snapshotUUID: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if let snapshot = self.snapshotCache.objectForKey(snapshotUUID) as? FIRDataSnapshot {
      resolve(snapshot.valueInExportFormat())
    } else {
      reject("snapshot_not_found", "Snapshot not found; it may have been released.", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  @objc func snapshotChildren(snapshotUUID: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
     if let snapshot = self.snapshotCache.objectForKey(snapshotUUID) as? FIRDataSnapshot {
      resolve(snapshot.children.map({self.cacheSnapshotAndConvert($0 as! FIRDataSnapshot)}))
    } else {
      reject("snapshot_not_found", "Snapshot not found; it may have been released.", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  var databaseEventHandles = Dictionary<String, (FIRDatabaseReference, FIRDatabaseHandle)>();
  
  // Setup event subscription. eventTypeString should match one of JsDataEventType.
  // Can't use @objc with string enums so we manually init it below.
  @objc func on(databaseUrl: String?, eventTypeString:String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    let ref = getRefFromUrl(databaseUrl)
    if let eventType = JsDataEventType.init(rawValue: eventTypeString) {
      let uniqueEventName = NSUUID.init()
      resolve(uniqueEventName.UUIDString)
      let handle = ref.observeEventType(jsEventTypeMapping[eventType]!, withBlock: { snapshot in
        self.bridge.eventDispatcher().sendAppEventWithName(
            uniqueEventName.UUIDString, body: self.cacheSnapshotAndConvert(snapshot))
        })
      
      self.databaseEventHandles[uniqueEventName.UUIDString] = (ref, handle)
    } else {
      reject("unknown_event", "Unknown event type provided \(eventTypeString)", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  @objc func off(uniqueEventName:String) {
    if let (ref, handle) = databaseEventHandles[uniqueEventName] {
      ref.removeObserverWithHandle(handle)
    }
  }
  
  func convertRef(ref:FIRDatabaseReference) -> Dictionary<String, String> {
    return [
      "key": ref.key,
      "locationUrl": ref.description()
    ]
  }
  
  func getRefFromUrl(databaseUrl: String?) -> FIRDatabaseReference {
    if let url = databaseUrl {
      return FIRDatabase.database().referenceFromURL(url)
    }
    return FIRDatabase.database().reference()
  }
  
  @objc func child(databaseUrl: String?, path:String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    resolve(convertRef(getRefFromUrl(databaseUrl).child(path)))
  }
  
  
  @objc func push(databaseUrl: String?, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    resolve(convertRef(getRefFromUrl(databaseUrl).childByAutoId()))
  }
  
  // We receive an array of a single element which is the value to set
  @objc func setValue(databaseUrl:String, value:[AnyObject], resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    getRefFromUrl(databaseUrl).setValue(value[0])
    getRefFromUrl(databaseUrl).setValue(value[0], withCompletionBlock: {(error, ref) in
      if (error != nil) {
        reject("set_value_failed", error?.localizedDescription, error)
      } else {
        resolve(nil)
      }
    })
  }
  
  @objc func setValueWithPriority(databaseUrl:String, value:[AnyObject], priority:[AnyObject], resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    getRefFromUrl(databaseUrl).setValue(value[0], andPriority: priority[0], withCompletionBlock: {(error, ref) in
      if (error != nil) {
        reject("set_value_failed", error?.localizedDescription, error)
      } else {
        resolve(nil)
      }
    })
  }
  
  
  @objc func setPriority(databaseUrl:String, priority:[AnyObject], resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    getRefFromUrl(databaseUrl).setPriority(priority[0], withCompletionBlock: {(error, ref) in
      if (error != nil) {
        reject("set_priority_failed", error?.localizedDescription, error)
      } else {
        resolve(nil)
      }
    })
  }
  
  @objc func removeValue(databaseUrl:String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    getRefFromUrl(databaseUrl).removeValueWithCompletionBlock { (error, ref) in
      if (error != nil) {
        reject("remove_value_failed", error?.localizedDescription, error)
      } else {
        resolve(nil);
      }
    }
  }
  
}
