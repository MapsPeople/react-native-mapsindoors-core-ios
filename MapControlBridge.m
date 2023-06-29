#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(MapControlModule, RCTEventEmitter)
    RCT_EXTERN_METHOD(requiresMainQueueSetup)

    RCT_EXTERN_METHOD(supportedEvents)


    RCT_EXTERN_METHOD(initMapControl:(NSDictionary) config
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(clearFilter:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setFilter:(NSString) filterJSON
                      filterBehaviorJSON:(NSString) filterBehaviorJSON
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setFilterWithLocations:(NSString) locationIdsJSON
                      filterBehaviorJSON:(NSString) filterBehaviorJSON
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(showUserPosition:(BOOL) show
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(isUserPositionShown:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(goTo:(NSString) entityJSON
                      entityType:(NSString) entityType
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getCurrentVenue:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getCurrentBuilding:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(selectVenue:(NSString) venueJSON
                      moveCamera:(BOOL) moveCamera
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(selectBuilding:(NSString) buildingJSON
                      moveCamera:(BOOL) moveCamera
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(selectLocation:(NSString) locationJSON
                      behaviorJSON:(NSString) behaviorJSON
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(selectLocationWithId:(NSString) locationId
                      behaviorJSON:(NSString) behaviorJSON
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setMapPadding:(NSInteger) left
                      top:(NSInteger) top
                      right:(NSInteger) right
                      bottom:(NSInteger) bottom
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getMapViewPaddingStart:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)
    RCT_EXTERN_METHOD(getMapViewPaddingEnd:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)
    RCT_EXTERN_METHOD(getMapViewPaddingTop:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)
    RCT_EXTERN_METHOD(getMapViewPaddingBottom:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setMapStyle:(NSString) mapStyleJSON
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getMapStyle:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(showInfoWindowOnClickedLocation:(BOOL) show
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(deSelectLocation:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getCurrentBuildingFloor:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getCurrentFloorIndex:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getCurrentMapsIndoorsZoom:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(selectFloor:(NSInteger) show
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(isFloorSelectorHidden:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(hideFloorSelector:(BOOL) hide
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(enableLiveData:(NSString) domainType
                      hasListener:(BOOL) hasListener
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(disableLiveData:(NSString) domainType
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(animateCamera:(NSString) updateJSON
                      duration:(NSInteger) duration
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(moveCamera:(NSString) updateJSON
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(getCurrentCameraPosition:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setFloorSelector:(BOOL) setup
                      isAutoFloorChangeEnabled:(BOOL) isAutoFloorChangeEnabled
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    // Set Listeners

    RCT_EXTERN_METHOD(setOnMapClickListener:(BOOL) setup
                      consumeEvent:(BOOL) consumeEvent
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setOnLocationSelectedListener:(BOOL) setup
                      consumeEvent:(BOOL) consumeEvent
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setOnCurrentVenueChangedListener:(BOOL) setup
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setOnCurrentBuildingChangedListener:(BOOL) setup
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setOnMarkerClickListener:(BOOL) setup
                      consumeEvent:(BOOL) consumeEvent
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setOnMarkerInfoWindowClickListener:(BOOL) setup
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setOnFloorUpdateListener:(BOOL) setup
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

    RCT_EXTERN_METHOD(setMPCameraEventListener:(BOOL) setup
                      resolver:(RCTPromiseResolveBlock) resolve
                      rejecter:(RCTPromiseRejectBlock) reject)

@end
