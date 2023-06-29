//
//  UtilsBridge.m
//  react-native-maps-indoors
//
//  Created by Tim Mikkelsen on 26/04/2023.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(UtilsModule, NSObject)

    RCT_EXTERN_METHOD(requiresMainQueueSetup)

    RCT_EXTERN_METHOD(venueHasGraph: (NSString *) venueId
          resolver:(RCTPromiseResolveBlock) resolve
          rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(pointAngleBetween: (NSString *) point1
          point2: (NSString *) point2
          resolver:(RCTPromiseResolveBlock) resolve
          rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(pointDistanceTo: (NSString *) point1
          point2: (NSString *) point2
          resolver:(RCTPromiseResolveBlock) resolve
          rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(geometryIsInside: (NSString *) point
          geometry: (NSString *) geometry
          resolver:(RCTPromiseResolveBlock) resolve
          rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(geometryArea: (NSString *) geometry
          resolver:(RCTPromiseResolveBlock) resolve
          rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(polygonDistanceToClosestEdge: (NSString *) point
          geometry: (NSString *) geometry
          resolver:(RCTPromiseResolveBlock) resolve
          rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(parseMapClientUrl: (NSString *) venueId
          locationId: (NSString *) locationId
          resolver:(RCTPromiseResolveBlock) resolve
          rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setCollisionHandling: (nonnull NSNumber *) collisionHandling
          resolver:(RCTPromiseResolveBlock) resolve
          rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(enableClustering: (BOOL) value
          resolver:(RCTPromiseResolveBlock) resolve
          rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setExtrusionOpacity: (double) opacity
          resolver:(RCTPromiseResolveBlock) resolve
          rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setWallOpacity: (double) opacity
          resolver:(RCTPromiseResolveBlock) resolve
          rejecter:(RCTPromiseRejectBlock) reject)

@end
