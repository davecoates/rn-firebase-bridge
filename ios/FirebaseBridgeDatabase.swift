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
  JsDataEventType.Value: FIRDataEventType.value,
  JsDataEventType.ChildAdded: FIRDataEventType.childAdded,
  JsDataEventType.ChildRemoved: FIRDataEventType.childRemoved,
  JsDataEventType.ChildChanged: FIRDataEventType.childChanged,
  JsDataEventType.ChildMoved: FIRDataEventType.childMoved,
];


@objc(FirebaseBridgeDatabase)
class FirebaseBridgeDatabase: RCTEventEmitter, RCTInvalidating {
  
  func invalidate() {
    self.databaseEventHandles.forEach { (_, pair) in
      pair.0.removeObserver(withHandle: pair.1)
    }
  }
  
  let snapshotCache = NSCache<AnyObject, AnyObject>()
  
  func cacheSnapshotAndConvert(_ snapshot:FIRDataSnapshot) -> Dictionary<String, AnyObject> {
    let snapshotUUID = UUID.init()
    self.snapshotCache.setObject(snapshot, forKey: snapshotUUID.uuidString as AnyObject)
    var body:Dictionary<String, AnyObject> = [
      "ref": self.convertRef(snapshot.ref) as AnyObject,
      "exists": snapshot.exists() as AnyObject,
      "childrenCount": snapshot.childrenCount as AnyObject,
      "hasChildren": snapshot.hasChildren() as AnyObject,
      "uuid": snapshotUUID.uuidString as AnyObject,
    ]
    if let priority = snapshot.priority {
      body["priority"] = priority as AnyObject?
    }
    return body
  }
  
  @objc func snapshotChild(_ snapshotUUID: String, path: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if let snapshot = self.snapshotCache.object(forKey: snapshotUUID as AnyObject) as? FIRDataSnapshot {
      let childSnapshot = snapshot.childSnapshot(forPath: path)
      resolve(cacheSnapshotAndConvert(childSnapshot))
    } else {
      reject("snapshot_not_found", "Snapshot not found; it may have been released.", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  @objc func snapshotHasChild(_ snapshotUUID: String, path: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if let snapshot = self.snapshotCache.object(forKey: snapshotUUID as AnyObject) as? FIRDataSnapshot {
      resolve(snapshot.hasChild(path))
    } else {
      reject("snapshot_not_found", "Snapshot not found; it may have been released.", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  @objc func releaseSnapshot(_ snapshotUUID: String) {
    self.snapshotCache.removeObject(forKey: snapshotUUID as AnyObject)
  }
  
  @objc func snapshotValue(_ snapshotUUID: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if let snapshot = self.snapshotCache.object(forKey: snapshotUUID as AnyObject) as? FIRDataSnapshot {
      resolve(snapshot.value)
    } else {
      reject("snapshot_not_found", "Snapshot not found; it may have been released.", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  @objc func snapshotKey(_ snapshotUUID: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if let snapshot = self.snapshotCache.object(forKey: snapshotUUID as AnyObject) as? FIRDataSnapshot {
      resolve(snapshot.key)
    } else {
      reject("snapshot_not_found", "Snapshot not found; it may have been released.", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  @objc func snapshotExportValue(_ snapshotUUID: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if let snapshot = self.snapshotCache.object(forKey: snapshotUUID as AnyObject) as? FIRDataSnapshot {
      resolve(snapshot.valueInExportFormat())
    } else {
      reject("snapshot_not_found", "Snapshot not found; it may have been released.", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  @objc func snapshotChildren(_ snapshotUUID: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
     if let snapshot = self.snapshotCache.object(forKey: snapshotUUID as AnyObject) as? FIRDataSnapshot {
      resolve(snapshot.children.map({self.cacheSnapshotAndConvert($0 as! FIRDataSnapshot)}))
    } else {
      reject("snapshot_not_found", "Snapshot not found; it may have been released.", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  var databaseEventHandles = Dictionary<String, (FIRDatabaseQuery, FIRDatabaseHandle)>();
  
  @objc func onRef(_ appName: String, databaseUrl: String?, eventTypeString:String, query: [[AnyObject]]) throws -> FIRDatabaseQuery {
    var ref:FIRDatabaseQuery = try getRefFromUrl(appName, databaseUrl: databaseUrl)
    for queryDescriptor in query {
      // Each query is array; first element is function name and rest
      // are arguments to that function
      let fnName:String = queryDescriptor[0] as! String
      let paramCount = queryDescriptor.count - 1
      switch (fnName) {
      case "orderByChild":
        ref = ref.queryOrdered(byChild: queryDescriptor[1] as! String)
      case "orderByKey":
        ref = ref.queryOrderedByKey()
      case "orderByPriority":
        ref = ref.queryOrderedByPriority()
      case "orderByValue":
        ref = ref.queryOrderedByValue()
      case "startAt":
        if (paramCount == 2) {
          ref = ref.queryStarting(atValue: queryDescriptor[1], childKey: queryDescriptor[2] as? String)
        } else {
          ref = ref.queryStarting(atValue: queryDescriptor[1])
        }
      case "endAt":
        if (paramCount == 2) {
          ref = ref.queryEnding(atValue: queryDescriptor[1], childKey: queryDescriptor[2] as? String)
        } else {
          ref = ref.queryEnding(atValue: queryDescriptor[1])
        }
      case "equalTo":
        if (paramCount == 2) {
          ref = ref.queryEqual(toValue: queryDescriptor[1], childKey: queryDescriptor[2] as? String)
        } else {
          ref = ref.queryEqual(toValue: queryDescriptor[1])
        }
      case "limitToFirst":
        ref = ref.queryLimited(toFirst: queryDescriptor[1] as! UInt)
      case "limitToLast":
        ref = ref.queryLimited(toLast: queryDescriptor[1] as! UInt)
      default:
        throw FirebaseBridgeError.unknownQueryFunction(fnName: fnName)
      }
    }
    return ref;
  }
  
  override func supportedEvents() -> [String]! {
    return ["databaseOn"]
  }
  
  
  // Setup event subscription. eventTypeString should match one of JsDataEventType.
  // Can't use @objc with string enums so we manually init it below.
  @objc func once(_ appName: String, databaseUrl: String?, eventTypeString:String, query: [[AnyObject]], resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    do {
      let ref = try onRef(appName, databaseUrl: databaseUrl, eventTypeString: eventTypeString, query: query);
      
      if let eventType = JsDataEventType.init(rawValue: eventTypeString) {
        let uniqueEventName = UUID.init()
        resolve(uniqueEventName.uuidString)
        ref.observeSingleEvent(of: jsEventTypeMapping[eventType]!, with: { snapshot in
          self.sendEvent(withName: "databaseOn", body: [
            "id": uniqueEventName.uuidString,
            "snapshot": self.cacheSnapshotAndConvert(snapshot),
          ])
        }, withCancel: { error in
          self.sendEvent(withName: "databaseOn", body: [
            "id": uniqueEventName.uuidString,
            "error": error.localizedDescription,
            ]);
        })
      } else {
        reject("unknown_event", "Unknown event type provided \(eventTypeString)", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
      }
    } catch FirebaseBridgeError.unknownQueryFunction(let fnName) {
      reject("invalid_query", "Unknown query function \(fnName)",
             NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    } catch let unknownError {
      reject("unknown_error", "Unknown query function \(unknownError)",
             NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }

  // Setup event subscription. eventTypeString should match one of JsDataEventType.
  // Can't use @objc with string enums so we manually init it below.
  @objc func on(_ appName: String, databaseUrl: String?, eventTypeString:String, query: [[AnyObject]], resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    do {
      let ref = try onRef(appName, databaseUrl: databaseUrl, eventTypeString: eventTypeString, query: query);
      
      if let eventType = JsDataEventType.init(rawValue: eventTypeString) {
        let uniqueEventName = UUID.init()
        resolve(uniqueEventName.uuidString)
        let handle = ref.observe(jsEventTypeMapping[eventType]!, with: { snapshot in
          self.sendEvent(withName: "databaseOn", body: [
            "id": uniqueEventName.uuidString,
            "snapshot": self.cacheSnapshotAndConvert(snapshot),
            ]
          )
          }, withCancel: { error in
            self.sendEvent(withName: "databaseOn", body: [
              "id": uniqueEventName.uuidString,
              "error": error.localizedDescription,
              ]);
          }
        )
        
        self.databaseEventHandles[uniqueEventName.uuidString] = (ref, handle)
      } else {
        reject("unknown_event", "Unknown event type provided \(eventTypeString)", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
      }
    } catch FirebaseBridgeError.unknownQueryFunction(let fnName) {
      reject("invalid_query", "Unknown query function \(fnName)",
             NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    } catch let unknownError {
      reject("unknown_error", "Unknown query function \(unknownError)",
             NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }

  @objc func off(_ uniqueEventName:String) {
    if let (ref, handle) = databaseEventHandles[uniqueEventName] {
      ref.removeObserver(withHandle: handle)
    }
  }
  
  func convertRef(_ ref:FIRDatabaseReference) -> Dictionary<String, String> {
    return [
      "key": ref.key,
      "locationUrl": ref.description()
    ]
  }
  
  
  func getRefFromUrl(_ appName: String, databaseUrl: String?) throws -> FIRDatabaseReference {
    if let app = FIRApp(named: appName) {
      let database = FIRDatabase.database(app: app)
      if let url = databaseUrl, !url.isEmpty {
        return database.reference(fromURL: url)
      }
      return database.reference()
    } else {
      throw FirebaseBridgeError.appNotFound(appName: appName)
    }
  }
  
  func getRefRomUrl(_ appName: String,
                    databaseUrl: String?,
                    success: (_ ref: FIRDatabaseReference) -> Void,
                    rejecter reject: RCTPromiseRejectBlock)
  {
    do {
      let ref = try getRefFromUrl(appName, databaseUrl: databaseUrl)
      success(ref)
    } catch FirebaseBridgeError.appNotFound(let appName) {
      reject("unknown_app", "Unknown app \(appName)",
             NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    } catch let unknownError {
      reject("unknown_error", "Unknown error \(unknownError)",
             NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  @objc func child(_ appName: String, databaseUrl: String?, path:String,
                   resolver resolve: RCTPromiseResolveBlock,
                   rejecter reject: RCTPromiseRejectBlock)
  {
    getRefRomUrl(appName, databaseUrl: databaseUrl,
                 success: { (ref) -> Void in
                  resolve(self.convertRef(ref.child(path)))
                 },
                 rejecter: reject)
  }
  
  
  @objc func push(_ appName: String, databaseUrl: String?, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    getRefRomUrl(appName, databaseUrl: databaseUrl,
                 success: { (ref) -> Void in
                  resolve(self.convertRef(ref.childByAutoId()))
                 },
                 rejecter: reject)
  }
  
  // We receive an array of a single element whh is the value to set
  @objc func update(_ appName: String, databaseUrl: String, value:Dictionary<String, AnyObject>, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
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
  @objc func setValue(_ appName: String, databaseUrl: String, value:[AnyObject],
                      resolver resolve: @escaping RCTPromiseResolveBlock,
                      rejecter reject: @escaping RCTPromiseRejectBlock) {
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
  
  @objc func setValueWithPriority(_ appName: String, databaseUrl: String, value:[AnyObject], priority:[AnyObject], resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
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
  
  
  @objc func setPriority(_ appName: String, databaseUrl: String, priority:[AnyObject], resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
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
  
  @objc func removeValue(_ appName: String, databaseUrl: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    getRefRomUrl(appName, databaseUrl: databaseUrl,
                 success: { (ref) -> Void in
                  ref.removeValue { (error, ref) in
                    if (error != nil) {
                      reject("remove_value_failed", error?.localizedDescription, error)
                    } else {
                      resolve(nil);
                    }
                  }
                 },
                 rejecter: reject)
  }
  
  @objc func refFromURL(_ appName: String, url: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    if let app = FIRApp(named: appName) {
        let database = FIRDatabase.database(app: app)
        let ref = database.reference(fromURL: url)
        resolve(convertRef(ref))
    } else {
        reject("app_not_found", "App with name \(appName) not found", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }  }
  
  @objc func ref(_ appName: String, path: String?, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    var ref:FIRDatabaseReference
    if let app = FIRApp(named: appName) {
      let database = FIRDatabase.database(app: app)
      if let path = path, path != "" {
        ref = database.reference(withPath: path)
      } else {
        ref = database.reference()
      }
      resolve(convertRef(ref))
    } else {
      reject("app_not_found", "App with name \(appName) not found", NSError(domain: "FirebaseBridgeDatabase", code: 0, userInfo: nil));
    }
  }
  
  @objc func parent(_ appName: String, databaseUrl: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
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
  
  @objc func root(_ appName: String, databaseUrl: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    getRefRomUrl(appName, databaseUrl: databaseUrl,
                 success: { (ref) -> Void in
                  resolve(self.convertRef(ref.root))
                 },
                 rejecter: reject)
  }
  
  @objc func setPersistenceEnabled(_ appName: String, enabled:Bool) {
    if let app = FIRApp(named: appName) {
        let database = FIRDatabase.database(app: app)
        if (database.persistenceEnabled != enabled) {
            database.persistenceEnabled = enabled
        }
    } else {
        print("\(appName) not found - persistence not enabled")
    }
  }
  
  @objc func enableLogging(_ enabled:Bool) {
    FIRDatabase.setLoggingEnabled(enabled)
  }
  
  @objc func sdkVersion(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    resolve(FIRDatabase.sdkVersion());
  }
    
    @objc func goOffline(_ appName: String) {
        if let app = FIRApp(named: appName) {
            let database = FIRDatabase.database(app: app)
            database.goOffline()
        } else {
            print("\(appName) not found - goOffline failed")
        }
    }

    
    @objc func goOnline(_ appName: String) {
        if let app = FIRApp(named: appName) {
            let database = FIRDatabase.database(app: app)
            database.goOnline()
        } else {
            print("\(appName) not found - goOnline failed")
        }
    }
    
}

