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
class FirebaseBridgeDatabase: RCTEventEmitter, RCTInvalidating {
  
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
  
  @objc func snapshotKey(snapshotUUID: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if let snapshot = self.snapshotCache.objectForKey(snapshotUUID) as? FIRDataSnapshot {
      resolve(snapshot.key)
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
  
  var databaseEventHandles = Dictionary<String, (FIRDatabaseQuery, FIRDatabaseHandle)>();
  
  @objc func onRef(appName: String, databaseUrl: String?, eventTypeString:String, query: [[AnyObject]]) throws -> FIRDatabaseQuery {
    var ref:FIRDatabaseQuery = try getRefFromUrl(appName, databaseUrl: databaseUrl)
    for queryDescriptor in query {
      // Each query is array; first element is function name and rest
      // are arguments to that function
      let fnName:String = queryDescriptor[0] as! String
      let paramCount = queryDescriptor.count - 1
      switch (fnName) {
      case "orderByChild":
        ref = ref.queryOrderedByChild(queryDescriptor[1] as! String)
      case "orderByKey":
        ref = ref.queryOrderedByKey()
      case "orderByPriority":
        ref = ref.queryOrderedByPriority()
      case "orderByValue":
        ref = ref.queryOrderedByValue()
      case "startAt":
        if (paramCount == 2) {
          ref = ref.queryStartingAtValue(queryDescriptor[1], childKey: queryDescriptor[2] as? String)
        } else {
          ref = ref.queryStartingAtValue(queryDescriptor[1])
        }
      case "endAt":
        if (paramCount == 2) {
          ref = ref.queryEndingAtValue(queryDescriptor[1], childKey: queryDescriptor[2] as? String)
        } else {
          ref = ref.queryEndingAtValue(queryDescriptor[1])
        }
      case "equalTo":
        if (paramCount == 2) {
          ref = ref.queryEqualToValue(queryDescriptor[1], childKey: queryDescriptor[2] as? String)
        } else {
          ref = ref.queryEqualToValue(queryDescriptor[1])
        }
      case "limitToFirst":
        ref = ref.queryLimitedToFirst(queryDescriptor[1] as! UInt)
      case "limitToLast":
        ref = ref.queryLimitedToLast(queryDescriptor[1] as! UInt)
      default:
        throw FirebaseBridgeError.UnknownQueryFunction(fnName: fnName)
      }
    }
    return ref;
  }
  
  override func supportedEvents() -> [String]! {
    return ["databaseOn"]
  }
  
  
  // Setup event subscription. eventTypeString should match one of JsDataEventType.
  // Can't use @objc with string enums so we manually init it below.
  @objc func once(appName: String, databaseUrl: String?, eventTypeString:String, query: [[AnyObject]], resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    do {
      let ref = try onRef(appName, databaseUrl: databaseUrl, eventTypeString: eventTypeString, query: query);
      
      if let eventType = JsDataEventType.init(rawValue: eventTypeString) {
        let uniqueEventName = NSUUID.init()
        resolve(uniqueEventName.UUIDString)
        ref.observeSingleEventOfType(jsEventTypeMapping[eventType]!, withBlock: { snapshot in
          self.sendEventWithName("databaseOn", body: [
            "id": uniqueEventName.UUIDString,
            "snapshot": self.cacheSnapshotAndConvert(snapshot),
          ])
        }, withCancelBlock: { error in
          self.sendEventWithName("databaseOn", body: [
            "id": uniqueEventName.UUIDString,
            "error": error.localizedDescription,
            ]);
        })
      } else {
        reject("unknown_event", "Unknown event type provided \(eventTypeString)", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
      }
    } catch FirebaseBridgeError.UnknownQueryFunction(let fnName) {
      reject("invalid_query", "Unknown query function \(fnName)",
             NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    } catch let unknownError {
      reject("unknown_error", "Unknown query function \(unknownError)",
             NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }

  // Setup event subscription. eventTypeString should match one of JsDataEventType.
  // Can't use @objc with string enums so we manually init it below.
  @objc func on(appName: String, databaseUrl: String?, eventTypeString:String, query: [[AnyObject]], resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    do {
      let ref = try onRef(appName, databaseUrl: databaseUrl, eventTypeString: eventTypeString, query: query);
      
      if let eventType = JsDataEventType.init(rawValue: eventTypeString) {
        let uniqueEventName = NSUUID.init()
        resolve(uniqueEventName.UUIDString)
        let handle = ref.observeEventType(jsEventTypeMapping[eventType]!, withBlock: { snapshot in
          self.sendEventWithName("databaseOn", body: [
            "id": uniqueEventName.UUIDString,
            "snapshot": self.cacheSnapshotAndConvert(snapshot),
            ]
          )
          }, withCancelBlock: { error in
            self.sendEventWithName("databaseOn", body: [
              "id": uniqueEventName.UUIDString,
              "error": error.localizedDescription,
              ]);
          }
        )
        
        self.databaseEventHandles[uniqueEventName.UUIDString] = (ref, handle)
      } else {
        reject("unknown_event", "Unknown event type provided \(eventTypeString)", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
      }
    } catch FirebaseBridgeError.UnknownQueryFunction(let fnName) {
      reject("invalid_query", "Unknown query function \(fnName)",
             NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    } catch let unknownError {
      reject("unknown_error", "Unknown query function \(unknownError)",
             NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
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
  
  
  func getRefFromUrl(appName: String, databaseUrl: String?) throws -> FIRDatabaseReference {
    if let app = FIRApp(named: appName) {
      let database = FIRDatabase.database(app: app)
      if let url = databaseUrl where !url.isEmpty {
        return database.referenceFromURL(url)
      }
      return database.reference()
    } else {
      throw FirebaseBridgeError.AppNotFound(appName: appName)
    }
  }
  
  func getRefRomUrl(appName: String,
                    databaseUrl: String?,
                    success: (ref: FIRDatabaseReference) -> Void,
                    rejecter reject: RCTPromiseRejectBlock)
  {
    do {
      let ref = try getRefFromUrl(appName, databaseUrl: databaseUrl)
      success(ref: ref)
    } catch FirebaseBridgeError.AppNotFound(let appName) {
      reject("unknown_app", "Unknown app \(appName)",
             NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    } catch let unknownError {
      reject("unknown_error", "Unknown error \(unknownError)",
             NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  @objc func child(appName: String, databaseUrl: String?, path:String,
                   resolver resolve: RCTPromiseResolveBlock,
                   rejecter reject: RCTPromiseRejectBlock)
  {
    getRefRomUrl(appName, databaseUrl: databaseUrl,
                 success: { (ref) -> Void in
                  resolve(self.convertRef(ref.child(path)))
                 },
                 rejecter: reject)
  }
  
  
  @objc func push(appName: String, databaseUrl: String?, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    getRefRomUrl(appName, databaseUrl: databaseUrl,
                 success: { (ref) -> Void in
                  resolve(self.convertRef(ref.childByAutoId()))
                 },
                 rejecter: reject)
  }
  
  // We receive an array of a single element whh is the value to set
  @objc func update(appName: String, databaseUrl: String, value:Dictionary<String, AnyObject>, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    getRefRomUrl(appName, databaseUrl: databaseUrl,
                 success: { (ref) -> Void in
                  ref.updateChildValues(value, withCompletionBlock: {(error, ref) in
                    if (error != nil) {
                      reject("set_value_failed", error?.localizedDescription, error)
                    } else {
                      resolve(nil)
                    }
                  })
                 },
                 rejecter: reject)
  }
  
  // We receive an array of a single element which is the value to set
  @objc func setValue(appName: String, databaseUrl: String, value:[AnyObject],
                      resolver resolve: RCTPromiseResolveBlock,
                      rejecter reject: RCTPromiseRejectBlock) {
    getRefRomUrl(appName, databaseUrl: databaseUrl,
                 success: { (ref) -> Void in
                  ref.setValue(value[0], withCompletionBlock: {(error, ref) in
                    if (error != nil) {
                      reject("set_value_failed", error?.localizedDescription, error)
                    } else {
                      resolve(nil)
                    }
                  })
                 },
                 rejecter: reject)
  }
  
  @objc func setValueWithPriority(appName: String, databaseUrl: String, value:[AnyObject], priority:[AnyObject], resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    getRefRomUrl(appName, databaseUrl: databaseUrl,
                 success: { (ref) -> Void in
                  ref.setValue(value[0], andPriority: priority[0],
                    withCompletionBlock: {(error, ref) in
                      if (error != nil) {
                        reject("set_value_failed", error?.localizedDescription, error)
                      } else {
                        resolve(nil)
                      }
                    })
                 },
                 rejecter: reject)
  }
  
  
  @objc func setPriority(appName: String, databaseUrl: String, priority:[AnyObject], resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    getRefRomUrl(appName, databaseUrl: databaseUrl,
                 success: { (ref) -> Void in
                  ref.setPriority(priority[0], withCompletionBlock: {(error, ref) in
                    if (error != nil) {
                      reject("set_priority_failed", error?.localizedDescription, error)
                    } else {
                      resolve(nil)
                    }
                  })
                 },
                 rejecter: reject)
  }
  
  @objc func removeValue(appName: String, databaseUrl: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    getRefRomUrl(appName, databaseUrl: databaseUrl,
                 success: { (ref) -> Void in
                  ref.removeValueWithCompletionBlock { (error, ref) in
                    if (error != nil) {
                      reject("remove_value_failed", error?.localizedDescription, error)
                    } else {
                      resolve(nil);
                    }
                  }
                 },
                 rejecter: reject)
  }
  
  @objc func refFromURL(appName: String, url: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if let app = FIRApp(named: appName) {
        let database = FIRDatabase.database(app: app)
        let ref = database.referenceFromURL(url)
        resolve(convertRef(ref))
    } else {
        reject("app_not_found", "App with name \(appName) not found", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }  }
  
  @objc func ref(appName: String, path: String?, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    var ref:FIRDatabaseReference
    if let app = FIRApp(named: appName) {
      let database = FIRDatabase.database(app: app)
      if let path = path where path != "" {
        ref = database.referenceWithPath(path)
      } else {
        ref = database.reference()
      }
      resolve(convertRef(ref))
    } else {
      reject("app_not_found", "App with name \(appName) not found", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  @objc func parent(appName: String, databaseUrl: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    getRefRomUrl(appName, databaseUrl: databaseUrl,
                 success: { (ref) -> Void in
                  if let parent = ref.parent {
                    resolve(self.convertRef(parent))
                  } else {
                    resolve(nil)
                  }
                 },
                 rejecter: reject)
  }
  
  @objc func root(appName: String, databaseUrl: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    getRefRomUrl(appName, databaseUrl: databaseUrl,
                 success: { (ref) -> Void in
                  resolve(self.convertRef(ref.root))
                 },
                 rejecter: reject)
  }
  
  @objc func setPersistenceEnabled(appName: String, enabled:Bool) {
    if let app = FIRApp(named: appName) {
        let database = FIRDatabase.database(app: app)
        if (database.persistenceEnabled != enabled) {
            database.persistenceEnabled = enabled
        }
    } else {
        print("\(appName) not found - persistence not enabled")
    }
  }
  
  @objc func enableLogging(enabled:Bool) {
    FIRDatabase.setLoggingEnabled(enabled)
  }
  
  @objc func sdkVersion(resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    resolve(FIRDatabase.sdkVersion());
  }
    
    @objc func goOffline(appName: String) {
        if let app = FIRApp(named: appName) {
            let database = FIRDatabase.database(app: app)
            database.goOffline()
        } else {
            print("\(appName) not found - goOffline failed")
        }
    }

    
    @objc func goOnline(appName: String) {
        if let app = FIRApp(named: appName) {
            let database = FIRDatabase.database(app: app)
            database.goOnline()
        } else {
            print("\(appName) not found - goOnline failed")
        }
    }
    
}

