#import "FirebaseBridge.h"


@interface RCT_EXTERN_MODULE(FirebaseBridgeDatabase, NSObject)

RCT_EXTERN_METHOD(once:(NSString)databaseUrl
                  eventTypeString:(NSString)eventTypeString
                  query:NSObject
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(on:(NSString)databaseUrl
                  eventTypeString:(NSString)eventTypeString
                  query:NSObject
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(off:(NSString)handleUUID)

RCT_EXTERN_METHOD(snapshotChild:(NSString)snapshotUUID
                  path:(NSString)path
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(snapshotHasChild:(NSString)snapshotUUID
                  path:(NSString)path
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(releaseSnapshot:(NSString)snapshotUUID)

RCT_EXTERN_METHOD(snapshotExportValue:(NSString)snapshotUUID
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(snapshotValue:(NSString)snapshotUUID
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(snapshotKey:(NSString)snapshotUUID
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(snapshotChildren:(NSString)snapshotUUID
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(update:(NSString)databaseUrl
                  value:NSObject
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(setValue:(NSString)databaseUrl
                  value:NSObject
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(setValueWithPriority:(NSString)databaseUrl
                  value:NSObject
                  priority:NSObject
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(setPriority:(NSString)databaseUrl
                  priority:NSObject
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(removeValue:(NSString)databaseUrl
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(child:(NSString)databaseUrl
                  path:(NSString)path
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(push:(NSString)databaseUrl
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(setPersistenceEnabled:(BOOL)enabled)

@end

@interface RCT_EXTERN_MODULE(FirebaseBridgeAuth, NSObject)

RCT_EXTERN_METHOD(addAuthStateDidChangeListener)

RCT_EXTERN_METHOD(createUserWithEmail:(NSString)email
                  password:NSString
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(signInWithEmail:(NSString)email
                  password:NSString
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(signInAnonymously:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(signInWithCredential:(NSString)credentialId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
@end

@interface RCT_EXTERN_MODULE(FirebaseBridgeFacebookAuthProvider, NSObject)

RCT_EXTERN_METHOD(credential:(NSString)token
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
@end


@interface RCT_EXTERN_MODULE(FirebaseBridgeGithubAuthProvider, NSObject)

RCT_EXTERN_METHOD(credential:(NSString)token
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
@end


@interface RCT_EXTERN_MODULE(FirebaseBridgeTwitterAuthProvider, NSObject)

RCT_EXTERN_METHOD(credential:(NSString)token
                  secret:NSString
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
@end


@interface RCT_EXTERN_MODULE(FirebaseBridgeGoogleAuthProvider, NSObject)

RCT_EXTERN_METHOD(credential:(NSString)idToken
                  accessToken:NSString
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
@end