#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(MapsIndoorsModule, NSObject)
RCT_EXTERN_METHOD(requiresMainQueueSetup)

    RCT_EXTERN_METHOD(addEvent:(NSString *)name
                      location:(NSString *)location
                      date:(nonnull NSNumber *)date)

    RCT_EXTERN_METHOD(loadMapsIndoors: (NSString *) apiKey
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(test)

    RCT_EXTERN_METHOD(getVenues:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getBuildings:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getCategories:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getLocations:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(disableEventLogging:(BOOL) disable
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getApiKey:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getAvailableLanguages:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getDefaultLanguage:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getLanguage:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getLocationById:(NSString) id
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getLocationsByExternalIds:(NSArray) ids
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getMapStyles:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getSolution:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getLocationsAsync:(NSString) query
                      filter:(NSString) filter
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(locationDisplayRuleExists:(NSString) locId
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(displayRuleNameExists:(NSString) name
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(onPositionUpdate:(NSString) position
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setPositionProvider:(NSString) positionProviderName
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(removePositionProvider:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getUserRoles:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(applyUserRoles:(NSString) userRolesJSON
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getAppliedUserRoles:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(isApiKeyValid:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(isReady:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getDefaultVenue:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(checkOfflineDataAvailability:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(destroy:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(isInitialized:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(synchronizeContent:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setLanguage:(NSString) language
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)
@end
