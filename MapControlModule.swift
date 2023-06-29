import Foundation
import MapsIndoors
import MapsIndoorsCore
import MapsIndoorsCodable

import React

@objc(MapControlModule)
public class MapControlModule: RCTEventEmitter {
    @objc override public static func requiresMainQueueSetup() -> Bool {return false}
    
    private var mapConfig: MPMapConfig? = nil
    
    /// Base overide for RCTEventEmitter.
    ///
    /// - Returns: all supported events
    @objc open override func supportedEvents() -> [String] {
        return MapsIndoorsData.sharedInstance.allEvents
    }
    
    @objc public func initMapControl(_ config: NSDictionary,
                                     resolver resolve: @escaping RCTPromiseResolveBlock,
                                     rejecter reject: @escaping RCTPromiseRejectBlock) {
        
        DispatchQueue.main.async {
            guard let mapView = MapsIndoorsData.sharedInstance.mapView else {
                return doReject(reject, message: "Mapview not available")
            }
            
            self.mapConfig = mapView.getConfig()
            
            guard let mapControl = MPMapsIndoors.createMapControl(mapConfig: self.mapConfig!) else {
                return doReject(reject, message: "Unable to initialize Map Control")
            }
            
            let mapsIndoorsData = MapsIndoorsData.sharedInstance
            
            if (mapsIndoorsData.mapControlListenerDelegate == nil) {
                mapsIndoorsData.mapControlListenerDelegate = MapControlDelegate(eventEmitter: self)
            }
            mapsIndoorsData.mapControl = mapControl
            mapControl.delegate = mapsIndoorsData.mapControlListenerDelegate
            
            
            return resolve(nil)
        }
    }
    
    @objc public func clearFilter(_ resolve: @escaping RCTPromiseResolveBlock,
                                  rejecter reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            MapsIndoorsData.sharedInstance.mapControl?.clearFilter()
            return resolve(nil)
        }
    }
    
    @objc public func setFilter(_ filterJSON: String,
                                filterBehaviorJSON: String,
                                resolver resolve: RCTPromiseResolveBlock,
                                rejecter reject: RCTPromiseRejectBlock) {
        do {
            let filter: MPFilter = try fromJSON(filterJSON)
            let filterBehavior: MPFilterBehavior = try fromJSON(filterBehaviorJSON)
            
            MapsIndoorsData.sharedInstance.mapControl?.setFilter(filter: filter, behavior: filterBehavior)
            return resolve(true)
        } catch let e {
            return doReject(reject, error: e)
        }
    }
    
    @objc public func setFilterWithLocations(_ locationIdsJSON: String,
                                             filterBehaviorJSON: String,
                                             resolver resolve: RCTPromiseResolveBlock,
                                             rejecter reject: RCTPromiseRejectBlock) {
        do {
            let locations: [String] = try fromJSON(locationIdsJSON)
            let filterBehavior: MPFilterBehavior = try fromJSON(filterBehaviorJSON)
            let locs = (locations.compactMap{MPMapsIndoors.shared.locationWith(locationId: $0)})

            MapsIndoorsData.sharedInstance.mapControl?.setFilter(locations: locs, behavior: filterBehavior)

            return resolve(true)
        } catch let e {
            return doReject(reject, error: e)
        }
    }
    
    
    @objc public func showUserPosition(_ show: Bool,
                                       resolver resolve: RCTPromiseResolveBlock,
                                       rejecter reject: RCTPromiseRejectBlock) {
        MapsIndoorsData.sharedInstance.mapControl?.showUserPosition = show
        return resolve(nil)
    }
    
    @objc public func isUserPositionShown(_ resolve: RCTPromiseResolveBlock,
                                          rejecter reject: RCTPromiseRejectBlock) {
        return resolve(MapsIndoorsData.sharedInstance.mapControl?.showUserPosition)
    }
    
    @objc public func goTo(_ entityJSON: String,
                           entityType: String,
                           resolver resolve: @escaping RCTPromiseResolveBlock,
                           rejecter reject: @escaping RCTPromiseRejectBlock) {
        var entity: MPEntity
        
        do {
            switch entityType {
            case "MPLocation":
                entity = try fromJSON(entityJSON, type: MPLocationCodable.self)
            case "MPBuilding":
                entity = try fromJSON(entityJSON, type: MPBuildingCodable.self)
            case "MPVenue":
                entity = try fromJSON(entityJSON, type: MPVenueCodable.self)
            case "MPFloor":
                // TODO: Not implemented, currently MPFloor is not an MPEntity
                return doReject(reject, message: "goTo: Not currently implemented for \(entityType) on iOS")
            default:
                return doReject(reject, message: "goTo: Unknown entity type \(entityType)")
            }
            
            DispatchQueue.main.async {
                MapsIndoorsData.sharedInstance.mapControl!.goTo(entity: entity)
                return resolve(nil)
            }
        } catch let e {
            return doReject(reject, error: e)
        }
    }
    
    @objc public func getCurrentVenue(_ resolve: RCTPromiseResolveBlock,
                                      rejecter reject: RCTPromiseRejectBlock) {
        if let currentVenue = MapsIndoorsData.sharedInstance.mapControl!.currentVenue {
            return resolve(toJSON(MPVenueCodable(withVenue: currentVenue)))
        } else {
            return resolve(nil)
        }
        
    }
    
    @objc public func getCurrentBuilding(_ resolve: RCTPromiseResolveBlock,
                                         rejecter reject: RCTPromiseRejectBlock) {
        if let currentBuilding = MapsIndoorsData.sharedInstance.mapControl!.currentBuilding {
            return resolve(toJSON(MPBuildingCodable(withBuilding: currentBuilding)))
        } else {
            return resolve(nil)
        }
    }
    
    @objc public func selectVenue(_ venueJSON: String, moveCamera: Bool,
                                resolver resolve: @escaping RCTPromiseResolveBlock,
                                rejecter reject: @escaping RCTPromiseRejectBlock) {
        do {
            let venue: MPVenueCodable = try fromJSON(venueJSON)
            let behavior = MPSelectionBehavior()
            behavior.moveCamera = moveCamera
            
            DispatchQueue.main.async {
                MapsIndoorsData.sharedInstance.mapControl!.select(venue: venue, behavior: behavior)
                return resolve(nil)
            }
        } catch let e {
            return doReject(reject, error: e)
        }
    }
    
    @objc public func selectBuilding(_ buildingJSON: String, moveCamera: Bool,
                                     resolver resolve: @escaping RCTPromiseResolveBlock,
                                     rejecter reject: @escaping RCTPromiseRejectBlock) {
        do {
            let building: MPBuildingCodable = try fromJSON(buildingJSON)
            let behavior = MPSelectionBehavior()
            behavior.moveCamera = moveCamera
            
            DispatchQueue.main.async {
                MapsIndoorsData.sharedInstance.mapControl!.select(building: building, behavior: behavior)
                return resolve(nil)
            }
        } catch let e {
            return doReject(reject, error: e)
        }
    }
    
    @objc public func selectLocation(_ locationJSON: String,
                                     behaviorJSON: String,
                                     resolver resolve: @escaping RCTPromiseResolveBlock,
                                     rejecter reject: @escaping RCTPromiseRejectBlock) {
        do {
            let location: MPLocationCodable = try fromJSON(locationJSON)
            let behavior: MPSelectionBehavior = try fromJSON(behaviorJSON)
            
            Task {
                let loc = MPMapsIndoors.shared.locationWith(locationId: location.locationId)
                DispatchQueue.main.async {
                    MapsIndoorsData.sharedInstance.mapControl!.select(location: loc, behavior: behavior)
                    return resolve(nil)
                }
            }
        } catch let e {
            return doReject(reject, error: e)
        }
    }
    
    @objc public func selectLocationWithId(_ locationId: String,
                                           behaviorJSON: String,
                                           resolver resolve: @escaping RCTPromiseResolveBlock,
                                           rejecter reject: @escaping RCTPromiseRejectBlock) {
        do {
            let location = MPMapsIndoors.shared.locationWith(locationId: locationId)
            let behavior: MPSelectionBehavior = try fromJSON(behaviorJSON)
            
            DispatchQueue.main.async {
                MapsIndoorsData.sharedInstance.mapControl!.select(location: location, behavior: behavior)
                return resolve(nil)
            }
            
        } catch let e {
            return doReject(reject, error: e)
        }
    }
    
    @objc public func setMapPadding(_ left: Int, top: Int, right: Int, bottom: Int,
                                    resolver resolve: RCTPromiseResolveBlock,
                                    rejecter reject: RCTPromiseRejectBlock) {
        
        let edgeInsets = UIEdgeInsets(top: CGFloat(top), left: CGFloat(left), bottom: CGFloat(bottom), right: CGFloat(right))
        
        MapsIndoorsData.sharedInstance.mapControl?.mapPadding = edgeInsets
        
        return resolve(nil)
    }
    
    @objc public func getMapViewPaddingStart(_ resolve: RCTPromiseResolveBlock,
                                         rejecter reject: RCTPromiseRejectBlock) {
        guard let mapControl = MapsIndoorsData.sharedInstance.mapControl else {
            return doReject(reject, message: "mapcontrol not available")
        }
        return resolve(mapControl.mapPadding.left)
    }
    @objc public func getMapViewPaddingEnd(_ resolve:  RCTPromiseResolveBlock,
                                       rejecter reject: RCTPromiseRejectBlock) {
        guard let mapControl = MapsIndoorsData.sharedInstance.mapControl else {
            return doReject(reject, message: "mapcontrol not available")
        }
        return resolve(mapControl.mapPadding.right)
    }
    @objc public func getMapViewPaddingTop(_ resolve: RCTPromiseResolveBlock,
                                       rejecter reject: RCTPromiseRejectBlock) {
        guard let mapControl = MapsIndoorsData.sharedInstance.mapControl else {
            return doReject(reject, message: "mapcontrol not available")
        }
        return resolve(mapControl.mapPadding.top)
    }
    @objc public func getMapViewPaddingBottom(_ resolve:  RCTPromiseResolveBlock,
                                          rejecter reject: RCTPromiseRejectBlock) {
        guard let mapControl = MapsIndoorsData.sharedInstance.mapControl else {
            return doReject(reject, message: "mapcontrol not available")
        }
        return resolve(mapControl.mapPadding.bottom)
    }
    
    @objc public func setMapStyle(_ mapStyleJSON: String,
                                  resolver resolve: RCTPromiseResolveBlock,
                                  rejecter reject: RCTPromiseRejectBlock) {
        do {
            let mapStyle: MPMapStyleCodable = try fromJSON(mapStyleJSON)
            MapsIndoorsData.sharedInstance.mapControl!.mapStyle = mapStyle
            return resolve(nil)
        } catch let e {
            return doReject(reject, error: e)
        }
    }
    
    @objc public func getMapStyle(_ resolve: RCTPromiseResolveBlock,
                                  rejecter reject: RCTPromiseRejectBlock) {
        guard let mapControl = MapsIndoorsData.sharedInstance.mapControl else {
            return doReject(reject, message: "mapControl not available")
        }

        let mapStyle: MPMapStyle? = mapControl.mapStyle
        return resolve(mapStyle.map{toJSON(MPMapStyleCodable(withMapStyle: $0))})
    }
    
    @objc public func showInfoWindowOnClickedLocation(_ show: Bool,
                                                      resolver resolve: RCTPromiseResolveBlock,
                                                      rejecter reject: RCTPromiseRejectBlock) {
        MapsIndoorsData.sharedInstance.mapControl!.showInfoWindowOnClickedLocation = show
        return resolve(nil)
    }
    
    @objc public func deSelectLocation(_ resolve: @escaping RCTPromiseResolveBlock,
                                       rejecter reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            MapsIndoorsData.sharedInstance.mapControl!.select(location: nil, behavior: .default)
            return resolve(nil)
        }
    }
    
    @objc public func getCurrentBuildingFloor(_ resolve: RCTPromiseResolveBlock,
                                              rejecter reject: RCTPromiseRejectBlock) {
        guard let curFloor = MapsIndoorsData.sharedInstance.mapControl!.currentBuilding?.currentFloor else {
            return resolve(nil)
        }

        return resolve(toJSON(curFloor.stringValue))
    }
    
    @objc public func getCurrentFloorIndex(_ resolve: RCTPromiseResolveBlock,
                                           rejecter reject: RCTPromiseRejectBlock) {
        return resolve(MapsIndoorsData.sharedInstance.mapControl!.currentFloorIndex)
    }
    
    @objc public func getCurrentMapsIndoorsZoom(_ resolve: RCTPromiseResolveBlock,
                                                rejecter reject: RCTPromiseRejectBlock) {
        return resolve(MapsIndoorsData.sharedInstance.mapControl!.cameraPosition.zoom)
    }
    
    @objc public func selectFloor(_ floorIndex: Int,
                                  resolver resolve: @escaping RCTPromiseResolveBlock,
                                  rejecter reject: RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            MapsIndoorsData.sharedInstance.mapControl!.select(floorIndex: floorIndex)
            return resolve(nil)
        }
    }
    
    @objc public func isFloorSelectorHidden(_ resolve: RCTPromiseResolveBlock,
                                            rejecter reject: RCTPromiseRejectBlock) {
        return resolve(MapsIndoorsData.sharedInstance.mapControl!.hideFloorSelector)
    }
    
    @objc public func hideFloorSelector(_ hide: Bool,
                                        resolver resolve: RCTPromiseResolveBlock,
                                        rejecter reject: RCTPromiseRejectBlock) {
        MapsIndoorsData.sharedInstance.mapControl?.hideFloorSelector = hide
        return resolve(nil)
    }
    
    @objc public func animateCamera(_ updateJSON: String,
                                    duration: Int, //TODO: confirm if Int is fine here (any useful distinction between 0 and nil here?) //_duration: NSNumber, // TODO: check if NSNumber matches java @Nullable
                                    resolver resolve: RCTPromiseResolveBlock,
                                    rejecter reject: RCTPromiseRejectBlock) {
        guard let mapView = MapsIndoorsData.sharedInstance.mapView else {
            return doReject(reject, message: "Google maps not available")
        }
        
        // /*if*/ let duration = _duration.intValue // Only used if using _duration: NSNumber to match @Nullable in Java
        do {
            let cameraUpdate: CameraUpdate = try fromJSON(updateJSON)
            
            try mapView.animateCamera(cameraUpdate: cameraUpdate, duration: duration)

            return resolve(nil)
        } catch let e /*as CameraUpdateError*/ {
            return doReject(reject, error: e)
        }
    }
    
    @objc public func moveCamera(_ updateJSON: String,
                                 resolver resolve: RCTPromiseResolveBlock,
                                 rejecter reject: RCTPromiseRejectBlock) {
        guard let mapView = MapsIndoorsData.sharedInstance.mapView else {
            return doReject(reject, message: "Google maps not available")
        }
        
        do {
            let cameraUpdate: CameraUpdate = try fromJSON(updateJSON)
            
            try mapView.moveCamera(cameraUpdate: cameraUpdate)

            return resolve(nil)
        } catch let e {
            return doReject(reject, error: e)
        }
    }
    
    @objc public func getCurrentCameraPosition(_ resolve: @escaping RCTPromiseResolveBlock,
                                               rejecter reject: RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            return resolve(toJSON(MPCameraPositionCodable(withCameraPosition: MapsIndoorsData.sharedInstance.mapControl!.cameraPosition)))
        }
    }
    
    @objc public func enableLiveData(_ domainType: String,
                                     hasListener: Bool,
                                     resolver resolve: RCTPromiseResolveBlock,
                                     rejecter reject: RCTPromiseRejectBlock) {
        
        let mapsIndoorsData = MapsIndoorsData.sharedInstance
        guard let mapControl = mapsIndoorsData.mapControl else {
            return doReject(reject, message: "mapControl not available")
        }
        
        mapControl.enableLiveData(domain: domainType, listener: hasListener ? mapsIndoorsData.mapControlListenerDelegate?.onLiveDataReceived : nil)
        
        return resolve(nil)
    }
    
    @objc public func disableLiveData(_ domainType: String,
                                      resolver resolve: RCTPromiseResolveBlock,
                                      rejecter reject: RCTPromiseRejectBlock) {
        
        MapsIndoorsData.sharedInstance.mapControl?.disableLiveData(domain: domainType)
        return resolve(nil)
    }

    // Listeners

    @objc public func setOnMapClickListener(_ setup: Bool, consumeEvent: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.respondToTap = setup
        MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.consumeTap = consumeEvent

        return resolve(nil)
    }

    @objc public func setOnLocationSelectedListener(_ setup: Bool, consumeEvent: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.respondToDidChangeLocation = setup
        MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.consumeChangeLocation = consumeEvent

        return resolve(nil)
    }

    @objc public func setOnCurrentVenueChangedListener(_ setup: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.respondToDidChangeVenue = setup

        return resolve(nil)
    }

    @objc public func setOnCurrentBuildingChangedListener(_ setup: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.respondToDidChangeBuilding = setup

        return resolve(nil)
    }

    @objc public func setOnMarkerClickListener(_ setup: Bool, consumeEvent: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.respondToTapIcon = setup
        MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.consumeTapIcon = consumeEvent

        return resolve(nil)
    }

    @objc public func setOnMarkerInfoWindowClickListener(_ setup: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.respondToDidTapInfoWindow = setup

        return resolve(nil)
    }

    @objc public func setOnFloorUpdateListener(_ setup: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.respondToDidChangeFloorIndex = setup

        return resolve(nil)
    }

    @objc public func setMPCameraEventListener(_ setup: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        
        return doReject(reject, message: "NOT IMPLEMENTED")
    }

    // Floor selector

    @objc public func setFloorSelector(_ setup: Bool,
                                       isAutoFloorChangeEnabled: Bool,
                                       resolver resolve: RCTPromiseResolveBlock,
                                       rejecter reject: RCTPromiseRejectBlock) {

        let mapsIndoorsData = MapsIndoorsData.sharedInstance

        guard let mapControl = mapsIndoorsData.mapControl else {
            return doReject(reject, message: "mapControl is not available")
        }

        if (setup) {
            let delegate = mapsIndoorsData.mapControlListenerDelegate!
            mapControl.delegate = delegate

            let floorSelector = FloorSelector(delegate: delegate)
            floorSelector.autoFloorChange = isAutoFloorChangeEnabled

            mapControl.floorSelector = floorSelector
            mapsIndoorsData.floorSelector = floorSelector

        } else {
            mapControl.floorSelector = nil
            mapsIndoorsData.floorSelector = nil
        }

        return resolve(nil)
    }

    @objc public func onFloorSelectionChanged(_ newFloorJson: String,
                                              resolver resolve: @escaping RCTPromiseResolveBlock,
                                              rejecter reject: @escaping RCTPromiseRejectBlock) {
        guard let floorSelector = MapsIndoorsData.sharedInstance.floorSelector else {
            return doReject(reject, message: "Floor selector not available")
        }

        do {
            floorSelector.onFloorSelectionChanged(newFloor: try fromJSON(newFloorJson))
            return resolve(nil)
        } catch let e {
            return doReject(reject, error: e)
        }
    }
}
