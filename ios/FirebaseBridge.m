#import "FirebaseBridge.h"

@interface RCT_EXTERN_MODULE(FirebaseBridgeApp, NSObject)

RCT_EXTERN_METHOD(initializeApp:NSObject
                  name:(NSString)name
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(initializeDefaultApp:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end

@interface RCT_EXTERN_MODULE(FirebaseBridgeDatabase, NSObject)

RCT_EXTERN_METHOD(once:(NSString)appName
                  databaseUrl:(NSString)databaseUrl
                  eventTypeString:(NSString)eventTypeString
                  query:NSObject
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(on:(NSString)appName
                  databaseUrl:(NSString)databaseUrl
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

RCT_EXTERN_METHOD(update:(NSString)appName
                  databaseUrl:(NSString)databaseUrl
                  value:NSObject
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(setValue:(NSString)appName
                  databaseUrl:(NSString)databaseUrl
                  value:NSObject
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(setValueWithPriority:(NSString)appName
                  databaseUrl:(NSString)databaseUrl
                  value:NSObject
                  priority:NSObject
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(setPriority:(NSString)appName
                  databaseUrl:(NSString)databaseUrl
                  priority:NSObject
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(removeValue:(NSString)appName
                  databaseUrl:(NSString)databaseUrl
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(child:(NSString)appName
                  databaseUrl:(NSString)databaseUrl
                  path:(NSString)path
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(push:(NSString)appName
                  databaseUrl:(NSString)databaseUrl
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(ref:(NSString)appName
                  path:(NSString)path
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(refFromURL:(NSString)appName
                  url:(NSString)url
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(parent:(NSString)appName
                  databaseUrl:(NSString)databaseUrl
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(root:(NSString)appName
                  databaseUrl:(NSString)databaseUrl
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(sdkVersion:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(enableLogging:(BOOL)enabled)

RCT_EXTERN_METHOD(setPersistenceEnabled:(NSString)appName
                  enabled:(BOOL)enabled)

RCT_EXTERN_METHOD(goOnline:(NSString)appName)

RCT_EXTERN_METHOD(goOffline:(NSString)appName)

@end

@interface RCT_EXTERN_MODULE(FirebaseBridgeAuth, RCTEventEmitter)

RCT_EXTERN_METHOD(addAuthStateDidChangeListener:(NSString)appName
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(createUserWithEmail:(NSString)appName
                  email:NSString
                  password:NSString
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(signInWithEmail:(NSString)appName
                  email:NSString
                  password:NSString
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(signInAnonymously:(NSString)appName
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(signInWithCredential:(NSString)appName
                  credentialId:NSString
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(signInWithCustomToken:(NSString)appName
                  token:NSString
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(signOut:(NSString)appName
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(sendPasswordResetEmail:(NSString)appName
                  email:NSString
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(fetchProvidersForEmail:(NSString)appName
                  email:NSString
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

@interface RCT_EXTERN_MODULE(FirebaseBridgeUser, NSObject)

RCT_EXTERN_METHOD(sendEmailVerification:(NSString)appName
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(delete:(NSString)appName
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getToken:(NSString)appName
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(link:(NSString)appName
                  credentialId:NSString
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(reauthenticate:(NSString)appName
                  credentialId:NSString
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(reload:(NSString)appName
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(unlink:(NSString)appName
                  providerId:NSString
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(updateEmail:(NSString)appName
                  newEmail:NSString
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(updatePassword:(NSString)appName
                  newPassword:NSString
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(updateProfile:(NSString)appName
                  profile:NSObject
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
