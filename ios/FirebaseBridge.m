#import "FirebaseBridge.h"


@interface RCT_EXTERN_MODULE(FirebaseBridgeDatabase, NSObject)

RCT_EXTERN_METHOD(on:(NSString)databaseUrl
                  eventType:(int)eventType)

RCT_EXTERN_METHOD(setValue:(NSString)databaseUrl
                  value:NSObject)

RCT_EXTERN_METHOD(child:(NSString)databaseUrl
                  path:(NSString)path
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(childByAutoId:(NSString)databaseUrl
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

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

@end

