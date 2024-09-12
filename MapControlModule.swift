import Foundation
import MapsIndoors
import MapsIndoorsCore
import MapsIndoorsCodable

import React

@objc(MapControlModule)
public class MapControlModule: RCTEventEmitter {
    @objc override public static func requiresMainQueueSetup() -> Bool {return false}

    enum HexParsingError: Error {
        case invalidHexString(String)
    }
    func colorFromHexString(hex: String) throws -> UIColor {
        let regex = try! NSRegularExpression(pattern: "^#[0-9A-Fa-f]{6}$|^#[0-9A-Fa-f]{8}$")
        let range = NSRange(location: 0, length: hex.utf16.count)

        if (regex.matches(in: hex, range: range).count == 1) {
            return UIColor(hex: hex)!
        } else {
            throw HexParsingError.invalidHexString(hex)
        }
    }

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
            
            MapsIndoorsData.sharedInstance.directionsRenderer?.clear()
            MapsIndoorsData.sharedInstance.directionsRenderer = nil
            if mapView.getMapControl() != nil {
                return resolve(nil)
            }
            
            self.mapConfig = mapView.getConfig(config: config)
            
            guard let mapControl = MPMapsIndoors.createMapControl(mapConfig: self.mapConfig!) else {
                return doReject(reject, message: "Unable to initialize Map Control")
            }
            
            
            let mapsIndoorsData = MapsIndoorsData.sharedInstance
            
            if (mapsIndoorsData.mapControlListenerDelegate == nil) {
                mapsIndoorsData.mapControlListenerDelegate = MapControlDelegate(eventEmitter: self)
            }
            mapView.setMapControl(mapControl: mapControl)
            mapControl.delegate = mapsIndoorsData.mapControlListenerDelegate
            
            
            return resolve(nil)
        }
    }
    
    @objc public func clearFilter(_ resolve: @escaping RCTPromiseResolveBlock,
                                  rejecter reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.clearFilter()
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
            
            MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.setFilter(filter: filter, behavior: filterBehavior)
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

            MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.setFilter(locations: locs, behavior: filterBehavior)

            return resolve(true)
        } catch let e {
            return doReject(reject, error: e)
        }
    }
    
    @objc public func setHighlight(_ locationIdsJSON: String,
                                             highlightBehaviorJSON: String,
                                             resolver resolve: RCTPromiseResolveBlock,
                                             rejecter reject: RCTPromiseRejectBlock) {
        do {
            let locations: [String] = try fromJSON(locationIdsJSON)
            let highlightBehavior: MPHighlightBehavior = try fromJSON(highlightBehaviorJSON)
            let locs = (locations.compactMap{MPMapsIndoors.shared.locationWith(locationId: $0)})

            MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.setHighlight(locations: locs, behavior: highlightBehavior)

            return resolve(true)
        } catch let e {
            return doReject(reject, error: e)
        }
    }

    @objc public func clearHighlight(_ resolve: @escaping RCTPromiseResolveBlock,
                                  rejecter reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.clearHighlight()
            return resolve(nil)
        }
    }
    
    @objc public func showUserPosition(_ show: Bool,
                                       resolver resolve: RCTPromiseResolveBlock,
                                       rejecter reject: RCTPromiseRejectBlock) {
        MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.showUserPosition = show
        return resolve(nil)
    }
    
    @objc public func isUserPositionShown(_ resolve: RCTPromiseResolveBlock,
                                          rejecter reject: RCTPromiseRejectBlock) {
        return resolve(MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.showUserPosition)
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
                MapsIndoorsData.sharedInstance.mapView?.getMapControl()!.goTo(entity: entity)
                return resolve(nil)
            }
        } catch let e {
            return doReject(reject, error: e)
        }
    }
    
    @objc public func getCurrentVenue(_ resolve: RCTPromiseResolveBlock,
                                      rejecter reject: RCTPromiseRejectBlock) {
        if let currentVenue = MapsIndoorsData.sharedInstance.mapView?.getMapControl()!.currentVenue {
            return resolve(toJSON(MPVenueCodable(withVenue: currentVenue)))
        } else {
            return resolve(nil)
        }
        
    }
    
    @objc public func getCurrentBuilding(_ resolve: RCTPromiseResolveBlock,
                                         rejecter reject: RCTPromiseRejectBlock) {
        if let currentBuilding = MapsIndoorsData.sharedInstance.mapView?.getMapControl()!.currentBuilding {
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
                MapsIndoorsData.sharedInstance.mapView?.getMapControl()!.select(venue: venue, behavior: behavior)
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
                MapsIndoorsData.sharedInstance.mapView?.getMapControl()!.select(building: building, behavior: behavior)
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
                    MapsIndoorsData.sharedInstance.mapView?.getMapControl()!.select(location: loc, behavior: behavior)
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
                MapsIndoorsData.sharedInstance.mapView?.getMapControl()!.select(location: location, behavior: behavior)
                return resolve(nil)
            }
            
        } catch let e {
            return doReject(reject, error: e)
        }
    }
    
    @objc public func setMapPadding(_ left: Int, top: Int, right: Int, bottom: Int,
                                    resolver resolve: @escaping RCTPromiseResolveBlock,
                                    rejecter reject: @escaping RCTPromiseRejectBlock) {
        
        let edgeInsets = UIEdgeInsets(top: CGFloat(top), left: CGFloat(left), bottom: CGFloat(bottom), right: CGFloat(right))
        
        DispatchQueue.main.async {
            MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.mapPadding = edgeInsets
            return resolve(nil)
        }
    }
    
    @objc public func getMapViewPaddingStart(_ resolve: RCTPromiseResolveBlock,
                                         rejecter reject: RCTPromiseRejectBlock) {
        guard let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() else {
            return doReject(reject, message: "mapcontrol not available")
        }
        return resolve(mapControl.mapPadding.left)
    }
    @objc public func getMapViewPaddingEnd(_ resolve:  RCTPromiseResolveBlock,
                                       rejecter reject: RCTPromiseRejectBlock) {
        guard let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() else {
            return doReject(reject, message: "mapcontrol not available")
        }
        return resolve(mapControl.mapPadding.right)
    }
    @objc public func getMapViewPaddingTop(_ resolve: RCTPromiseResolveBlock,
                                       rejecter reject: RCTPromiseRejectBlock) {
        guard let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() else {
            return doReject(reject, message: "mapcontrol not available")
        }
        return resolve(mapControl.mapPadding.top)
    }
    @objc public func getMapViewPaddingBottom(_ resolve:  RCTPromiseResolveBlock,
                                          rejecter reject: RCTPromiseRejectBlock) {
        guard let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() else {
            return doReject(reject, message: "mapcontrol not available")
        }
        return resolve(mapControl.mapPadding.bottom)
    }
    
    @objc public func setMapStyle(_ mapStyleJSON: String,
                                  resolver resolve: RCTPromiseResolveBlock,
                                  rejecter reject: RCTPromiseRejectBlock) {
        do {
            let mapStyle: MPMapStyleCodable = try fromJSON(mapStyleJSON)
            MapsIndoorsData.sharedInstance.mapView?.getMapControl()!.mapStyle = mapStyle
            return resolve(nil)
        } catch let e {
            return doReject(reject, error: e)
        }
    }
    
    @objc public func getMapStyle(_ resolve: RCTPromiseResolveBlock,
                                  rejecter reject: RCTPromiseRejectBlock) {
        guard let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() else {
            return doReject(reject, message: "mapControl not available")
        }

        let mapStyle: MPMapStyle? = mapControl.mapStyle
        return resolve(mapStyle.map{toJSON(MPMapStyleCodable(withMapStyle: $0))})
    }
    
    @objc public func showInfoWindowOnClickedLocation(_ show: Bool,
                                                      resolver resolve: RCTPromiseResolveBlock,
                                                      rejecter reject: RCTPromiseRejectBlock) {
        MapsIndoorsData.sharedInstance.mapView?.getMapControl()!.showInfoWindowOnClickedLocation = show
        return resolve(nil)
    }
    
    @objc public func deSelectLocation(_ resolve: @escaping RCTPromiseResolveBlock,
                                       rejecter reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            MapsIndoorsData.sharedInstance.mapView?.getMapControl()!.select(location: nil, behavior: .default)
            return resolve(nil)
        }
    }
    
    @objc public func getCurrentBuildingFloor(_ resolve: RCTPromiseResolveBlock,
                                              rejecter reject: RCTPromiseRejectBlock) {
        guard let curFloor = MapsIndoorsData.sharedInstance.mapView?.getMapControl()!.currentBuilding?.currentFloor else {
            return resolve(nil)
        }

        return resolve(toJSON(curFloor.stringValue))
    }
    
    @objc public func getCurrentFloorIndex(_ resolve: RCTPromiseResolveBlock,
                                           rejecter reject: RCTPromiseRejectBlock) {
        return resolve(MapsIndoorsData.sharedInstance.mapView?.getMapControl()!.currentFloorIndex)
    }
    
    @objc public func getCurrentMapsIndoorsZoom(_ resolve: RCTPromiseResolveBlock,
                                                rejecter reject: RCTPromiseRejectBlock) {
        return resolve(MapsIndoorsData.sharedInstance.mapView?.getMapControl()!.cameraPosition.zoom)
    }
    
    @objc public func selectFloor(_ floorIndex: Int,
                                  resolver resolve: @escaping RCTPromiseResolveBlock,
                                  rejecter reject: RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            MapsIndoorsData.sharedInstance.mapView?.getMapControl()!.select(floorIndex: floorIndex)
            return resolve(nil)
        }
    }
    
    @objc public func isFloorSelectorHidden(_ resolve: RCTPromiseResolveBlock,
                                            rejecter reject: RCTPromiseRejectBlock) {
        return resolve(MapsIndoorsData.sharedInstance.mapView?.getMapControl()!.hideFloorSelector)
    }
    
    @objc public func hideFloorSelector(_ hide: Bool,
                                        resolver resolve: RCTPromiseResolveBlock,
                                        rejecter reject: RCTPromiseRejectBlock) {
        MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.hideFloorSelector = hide
        return resolve(nil)
    }
    
    @objc public func animateCamera(_ updateJSON: String,
                                    duration: Int,
                                    resolver resolve: RCTPromiseResolveBlock,
                                    rejecter reject: RCTPromiseRejectBlock) {
        guard let mapView = MapsIndoorsData.sharedInstance.mapView else {
            return doReject(reject, message: "Google maps not available")
        }
        
        do {
            let cameraUpdate: CameraUpdate = try fromJSON(updateJSON)
            if (duration == -1) {
                try mapView.moveCamera(cameraUpdate: cameraUpdate)
            }else {
                try mapView.animateCamera(cameraUpdate: cameraUpdate, duration: duration)
            }

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
            return resolve(toJSON(MPCameraPositionCodable(withCameraPosition: MapsIndoorsData.sharedInstance.mapView!.getMapControl()!.cameraPosition)))
        }
    }
    
    @objc public func enableLiveData(_ domainType: String,
                                     hasListener: Bool,
                                     resolver resolve: RCTPromiseResolveBlock,
                                     rejecter reject: RCTPromiseRejectBlock) {
        
        let mapsIndoorsData = MapsIndoorsData.sharedInstance
        guard let mapControl = mapsIndoorsData.mapView?.getMapControl() else {
            return doReject(reject, message: "mapControl not available")
        }
        
        mapControl.enableLiveData(domain: domainType, listener: hasListener ? mapsIndoorsData.mapControlListenerDelegate?.onLiveDataReceived : nil)
        
        return resolve(nil)
    }
    
    @objc public func disableLiveData(_ domainType: String,
                                      resolver resolve: RCTPromiseResolveBlock,
                                      rejecter reject: RCTPromiseRejectBlock) {
        
        MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.disableLiveData(domain: domainType)
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
        MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.respondToCameraEvents = setup
        return resolve(nil)
    }

    // Floor selector

    @objc public func setFloorSelector(_ setup: Bool,
                                       isAutoFloorChangeEnabled: Bool,
                                       resolver resolve: RCTPromiseResolveBlock,
                                       rejecter reject: RCTPromiseRejectBlock) {

        let mapsIndoorsData = MapsIndoorsData.sharedInstance

        guard let mapControl = mapsIndoorsData.mapView?.getMapControl() else {
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
            let floor: MPFloorCodable = try fromJSON(newFloorJson)
            floorSelector.onFloorSelectionChanged(newFloor: floor.floorIndex ?? 0)
            return resolve(nil)
        } catch let e {
            return doReject(reject, error: e)
        }
    }

    @objc public func setLabelOptions(_ textSize: NSNumber?,
                                        color: String?,
                                        showHalo: Bool,
                                        resolver resolve: @escaping RCTPromiseResolveBlock,
                                        rejecter reject: @escaping RCTPromiseRejectBlock) {

        let mapsIndoorsData = MapsIndoorsData.sharedInstance
        guard let mapControl = mapsIndoorsData.mapView?.getMapControl() else {
            return doReject(reject, message: "mapControl is not available")
        }

        let haloWidth: Float = showHalo ? 1.0 : 0.0
        let haloBlur: Float = showHalo ? 1.0 : 0.0
        let haloColor = UIColor.white
        
        do {
            if (textSize != -1 && color != nil) {
                let textColor = try colorFromHexString(hex: color!)
                mapControl.setMapLabelFont(font: UIFont.systemFont(ofSize: CGFloat(truncating: textSize!)), textSize: Float(truncating: textSize!), color: textColor, labelHaloColor: haloColor, labelHaloWidth: haloWidth, labelHaloBlur: haloBlur)
                return resolve(nil)
            }
            if (color != nil) {
                let textColor = try colorFromHexString(hex: color!)
                mapControl.setMapLabelFont(color: textColor, labelHaloColor: haloColor, labelHaloWidth: haloWidth, labelHaloBlur: haloBlur)
                return resolve(nil)
            }
            if (textSize != -1) {
                mapControl.setMapLabelFont(font: UIFont.systemFont(ofSize: CGFloat(truncating: textSize!)), textSize: Float(truncating: textSize!), labelHaloColor: haloColor, labelHaloWidth: haloWidth, labelHaloBlur: haloBlur)
                return resolve(nil)
            }
            mapControl.setMapLabelFont(labelHaloColor: haloColor, labelHaloWidth: haloWidth, labelHaloBlur: haloBlur)
            return resolve(nil)
        } catch {
            return doReject(reject, error: error)
        }
    }

    @objc public func setBuildingSelectionMode(_ selectionMode: NSNumber,
                                        resolver resolve: @escaping RCTPromiseResolveBlock,
                                        rejecter reject: @escaping RCTPromiseRejectBlock) {
        let mapsIndoorsData = MapsIndoorsData.sharedInstance
        guard let mapControl = mapsIndoorsData.mapView?.getMapControl() else {
            return doReject(reject, message: "mapControl is not available")
        }

        mapControl.buildingSelectionMode = MPSelectionMode(rawValue: selectionMode.intValue) ?? .automatic
        return resolve(nil)
    }

    @objc public func getBuildingSelectionMode(_ resolve: RCTPromiseResolveBlock,
                                        rejecter reject: RCTPromiseRejectBlock) {
        guard let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() else {
            return doReject(reject, message: "mapControl is not available")
        }

        return resolve(mapControl.buildingSelectionMode.rawValue)
    }

    @objc public func setFloorSelectionMode(_ selectionMode: NSNumber,
                                        resolver resolve: @escaping RCTPromiseResolveBlock,
                                        rejecter reject: @escaping RCTPromiseRejectBlock) {
        let mapsIndoorsData = MapsIndoorsData.sharedInstance
        guard let mapControl = mapsIndoorsData.mapView?.getMapControl() else {
            return doReject(reject, message: "mapControl is not available")
        }

        mapControl.floorSelectionMode = MPSelectionMode(rawValue: selectionMode.intValue) ?? .automatic
        return resolve(nil)
    }

    @objc public func getFloorSelectionMode(_ resolve: RCTPromiseResolveBlock,
                                        rejecter reject: RCTPromiseRejectBlock) {
        guard let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() else {
            return doReject(reject, message: "mapControl is not available")
        }

        return resolve(mapControl.floorSelectionMode.rawValue)
    }

    @objc public func setHiddenFeatures(_ features: String,
                                    resolver resolve: @escaping RCTPromiseResolveBlock,
                                    rejecter reject: @escaping RCTPromiseRejectBlock) {
        let mapsIndoorsData = MapsIndoorsData.sharedInstance
        guard let mapControl = mapsIndoorsData.mapView?.getMapControl() else {
            return doReject(reject, message: "mapControl is not available")
        }

        guard let features = try? JSONDecoder().decode([Int].self, from: features.data(using: .utf8)!) else {
            return doReject(reject, message: "Features could not be parsed")
        }
        var featureTypes = [MPFeatureType]()
        
        for feature in features {
            guard let featureType = MPFeatureType(rawValue: feature) else {
                return doReject(reject, message: "Could not parse featureType")
            }
            featureTypes.append(featureType)
        }

        mapControl.hiddenFeatures = featureTypes.map({$0.rawValue})

        return resolve(nil)
    }

    @objc public func getHiddenFeatures(_ resolve: RCTPromiseResolveBlock,
                                    rejecter reject: RCTPromiseRejectBlock) {
        guard let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() else {
            return doReject(reject, message: "mapControl is not available")
        }

        var features = [String]()
        
        guard let hiddenFeatures = try? JSONEncoder().encode(mapControl.hiddenFeatures) else {
            return doReject(reject, message: "something went wrong encoding hiddenfeatures")
        }

        return resolve(String(data: hiddenFeatures, encoding: String.Encoding.utf8))     
    }
}
