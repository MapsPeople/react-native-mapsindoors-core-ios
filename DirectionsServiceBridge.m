//
//  DirectionsServiceBridge.m
//  react-native-maps-indoors
//
//  Created by Tim Mikkelsen on 02/05/2023.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(DirectionsService, NSObject)

    RCT_EXTERN_METHOD(requiresMainQueueSetup)

    RCT_EXTERN_METHOD(create: (RCTPromiseResolveBlock) resolve
      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(addAvoidWayType: (NSString *) wayType
        id: (NSString *) id
        resolver:(RCTPromiseResolveBlock) resolve
        rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(clearWayType: (NSString *) id
        resolver:(RCTPromiseResolveBlock) resolve
        rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getRoute: (NSString *) originString
        destinationString: (NSString *) destinationString
        id: (NSString *) id
        resolver:(RCTPromiseResolveBlock) resolve
        rejecter:(RCTPromiseRejectBlock) reject)
        
    RCT_EXTERN_METHOD(setTravelMode: (NSString *) travelMode
        id: (NSString *) id
        resolver:(RCTPromiseResolveBlock) resolve
        rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setTime: (nonnull NSNumber *) time
        id: (NSString *) id
        resolver:(RCTPromiseResolveBlock) resolve
        rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setIsDeparture: (BOOL) isDeparture
        id: (NSString *) id
        resolver:(RCTPromiseResolveBlock) resolve
        rejecter:(RCTPromiseRejectBlock) reject)
@end
