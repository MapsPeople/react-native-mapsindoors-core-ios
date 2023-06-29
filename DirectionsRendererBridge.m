//
//  DirectionsRendererBridge.m
//  react-native-maps-indoors
//
//  Created by Tim Mikkelsen on 01/05/2023.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(DirectionsRenderer, RCTEventEmitter)

    RCT_EXTERN_METHOD(requiresMainQueueSetup)

    RCT_EXTERN_METHOD(clear: (RCTPromiseResolveBlock) resolve
      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getSelectedLegFloorIndex: (RCTPromiseResolveBlock) resolve
      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(nextLeg: (RCTPromiseResolveBlock) resolve
      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(previousLeg: (RCTPromiseResolveBlock) resolve
      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(selectLegIndex: (nonnull NSNumber *) legIndex
      resolver:(RCTPromiseResolveBlock) resolve
      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setAnimatedPolyline: (BOOL) animated
      repeated:(BOOL): repeated
      duration :(nonnull NSNumber *) duration
      resolver:(RCTPromiseResolveBlock) resolve
      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setCameraViewFitMode: (nonnull NSNumber *) cameraFitMode
      resolver:(RCTPromiseResolveBlock) resolve
      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setOnLegSelectedListener: (RCTPromiseResolveBlock) resolve
      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setPolyLineColors: (NSString *) foregroundString
      backgroundString:(NSString *): backgroundString
      resolver:(RCTPromiseResolveBlock) resolve
      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setRoute: (NSString *) routeString
      resolver:(RCTPromiseResolveBlock) resolve
      rejecter:(RCTPromiseRejectBlock) reject)

@end
