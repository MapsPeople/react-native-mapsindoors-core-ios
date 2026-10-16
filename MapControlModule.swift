import Foundation
import MapsIndoors
import MapsIndoorsCodable
import MapsIndoorsCore
import React

@objc(MapControlModule)
public class MapControlModule: RCTEventEmitter {
    @objc public override static func requiresMainQueueSetup() -> Bool { return false }

    enum HexParsingError: Error {
        case invalidHexString(String)
    }
    func colorFromHexString(hex: String) throws -> UIColor {
        let regex = try! NSRegularExpression(pattern: "^#[0-9A-Fa-f]{6}$|^#[0-9A-Fa-f]{8}$")
        let range = NSRange(location: 0, length: hex.utf16.count)

        if regex.matches(in: hex, range: range).count == 1 {
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

    @objc public func initMapControl(
        _ config: NSDictionary,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
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

            if let showUserPosition = config["showUserPosition"] as? Bool {
                mapControl.showUserPosition = showUserPosition
            }

            let mapsIndoorsData = MapsIndoorsData.sharedInstance

            if mapsIndoorsData.mapControlListenerDelegate == nil {
                mapsIndoorsData.mapControlListenerDelegate = MapControlDelegate(eventEmitter: self)
            }
            mapView.setMapControl(mapControl: mapControl)
            mapControl.delegate = mapsIndoorsData.mapControlListenerDelegate

            return resolve(nil)
        }
    }

    @objc public func clearFilter(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        DispatchQueue.main.async {
            MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.clearFilter()
            return resolve(nil)
        }
    }

    @objc public func setFilter(
        _ filterJSON: String,
        filterBehaviorJSON: String,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        do {
            let filter: MPFilter = try fromJSON(filterJSON)
            let filterBehavior: MPFilterBehavior = try fromJSON(filterBehaviorJSON)
            if filterBehavior.maxZoom == 999 {
                filterBehavior.maxZoom = Double.nan
            }

            onMainThread {
                MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.setFilter(filter: filter, behavior: filterBehavior)
                resolve(true)
            }
        } catch let e {
            return doReject(reject, error: e)
        }
    }

    @objc public func setFilterWithLocations(
        _ locationIdsJSON: String,
        filterBehaviorJSON: String,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        do {
            let locations: [String] = try fromJSON(locationIdsJSON)
            let filterBehavior: MPFilterBehavior = try fromJSON(filterBehaviorJSON)
            let locs = (locations.compactMap { MPMapsIndoors.shared.locationWith(locationId: $0) })

            onMainThread {
                MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.setFilter(locations: locs, behavior: filterBehavior)
                resolve(true)
            }
        } catch let e {
            return doReject(reject, error: e)
        }
    }

    @objc public func setHighlight(
        _ locationIdsJSON: String,
        highlightBehaviorJSON: String,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        do {
            let locations: [String] = try fromJSON(locationIdsJSON)
            let highlightBehavior: MPHighlightBehavior = try fromJSON(highlightBehaviorJSON)
            let locs = (locations.compactMap { MPMapsIndoors.shared.locationWith(locationId: $0) })

            if highlightBehavior.maxZoom == 999 {
                highlightBehavior.maxZoom = Double.nan
            }

            onMainThread {
                MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.setHighlight(locations: locs, behavior: highlightBehavior)
                resolve(true)
            }
        } catch let e {
            return doReject(reject, error: e)
        }
    }

    @objc public func clearHighlight(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        DispatchQueue.main.async {
            MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.clearHighlight()
            return resolve(nil)
        }
    }

    @objc public func showUserPosition(
        _ show: Bool,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        // The crash reported in SPEX-2633: this ran on React Native's queue on the first map open.
        onMainThread {
            MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.showUserPosition = show
            resolve(nil)
        }
    }

    @objc public func isUserPositionShown(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            resolve(MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.showUserPosition)
        }
    }

    @objc public func goTo(
        _ entityJSON: String,
        entityType: String,
        maxZoom: NSNumber?,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        let entity: MPEntity
        do {
            switch entityType {
            case "MPLocation":
                entity = try fromJSON(entityJSON, type: MPLocationCodable.self)
            case "MPBuilding":
                entity = try fromJSON(entityJSON, type: MPBuildingCodable.self)
            case "MPVenue":
                entity = try fromJSON(entityJSON, type: MPVenueCodable.self)
            case "MPFloor":
                entity = try fromJSON(entityJSON, type: MPFloorCodable.self)
            default:
                return doReject(reject, message: "goTo: Unknown entity type \(entityType)")
            }
        } catch let e {
            return doReject(reject, error: e)
        }

        onMainThread {
            guard let mapControl = self.requireMapControl(reject) else { return }
            if let maxZoom, maxZoom != -999 {
                mapControl.goTo(entity: entity, maxZoom: maxZoom.doubleValue)
            } else {
                mapControl.goTo(entity: entity)
            }
            resolve(nil)
        }
    }

    @objc public func getCurrentVenue(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            if let currentVenue = MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.currentVenue {
                resolve(toJSON(MPVenueCodable(withVenue: currentVenue)))
            } else {
                resolve(nil)
            }
        }
    }

    @objc public func getCurrentBuilding(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            if let currentBuilding = MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.currentBuilding {
                resolve(toJSON(MPBuildingCodable(withBuilding: currentBuilding)))
            } else {
                resolve(nil)
            }
        }
    }

    @objc public func selectVenue(
        _ venueJSON: String, moveCamera: Bool,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        do {
            let venue: MPVenueCodable = try fromJSON(venueJSON)
            let behavior = MPSelectionBehavior()
            behavior.moveCamera = moveCamera

            onMainThread {
                guard let mapControl = self.requireMapControl(reject) else { return }
                mapControl.select(venue: venue, behavior: behavior)
                resolve(nil)
            }
        } catch let e {
            return doReject(reject, error: e)
        }
    }

    @objc public func selectBuilding(
        _ buildingJSON: String, moveCamera: Bool,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        do {
            let building: MPBuildingCodable = try fromJSON(buildingJSON)
            let behavior = MPSelectionBehavior()
            behavior.moveCamera = moveCamera

            onMainThread {
                guard let mapControl = self.requireMapControl(reject) else { return }
                mapControl.select(building: building, behavior: behavior)
                resolve(nil)
            }
        } catch let e {
            return doReject(reject, error: e)
        }
    }

    @objc public func selectLocation(
        _ locationJSON: String,
        behaviorJSON: String,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        do {
            let location: MPLocationCodable = try fromJSON(locationJSON)
            let behavior: MPSelectionBehavior = try fromJSON(behaviorJSON)
            if behavior.maxZoom == 999 {
                behavior.maxZoom = Double.nan
            }

            // Looked up here rather than in a detached Task, so the selection keeps its place in the
            // order of calls (a Task could let a later call reach the map first).
            let loc = MPMapsIndoors.shared.locationWith(locationId: location.locationId)
            onMainThread {
                guard let mapControl = self.requireMapControl(reject) else { return }
                mapControl.select(location: loc, behavior: behavior)
                resolve(nil)
            }
        } catch let e {
            return doReject(reject, error: e)
        }
    }

    @objc public func selectLocationWithId(
        _ locationId: String,
        behaviorJSON: String,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        do {
            let location = MPMapsIndoors.shared.locationWith(locationId: locationId)
            let behavior: MPSelectionBehavior = try fromJSON(behaviorJSON)

            onMainThread {
                guard let mapControl = self.requireMapControl(reject) else { return }
                mapControl.select(location: location, behavior: behavior)
                resolve(nil)
            }
        } catch let e {
            return doReject(reject, error: e)
        }
    }

    @objc public func setMapPadding(
        _ left: Int, top: Int, right: Int, bottom: Int,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        let edgeInsets = UIEdgeInsets(top: CGFloat(top), left: CGFloat(left), bottom: CGFloat(bottom), right: CGFloat(right))

        DispatchQueue.main.async {
            MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.mapPadding = edgeInsets
            return resolve(nil)
        }
    }

    @objc public func getMapViewPaddingStart(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        resolveMapPadding(resolve, reject) { $0.left }
    }
    @objc public func getMapViewPaddingEnd(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        resolveMapPadding(resolve, reject) { $0.right }
    }
    @objc public func getMapViewPaddingTop(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        resolveMapPadding(resolve, reject) { $0.top }
    }
    @objc public func getMapViewPaddingBottom(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        resolveMapPadding(resolve, reject) { $0.bottom }
    }

    /// Resolves with one edge of the map control's padding, read on the main thread.
    private func resolveMapPadding(
        _ resolve: @escaping RCTPromiseResolveBlock,
        _ reject: @escaping RCTPromiseRejectBlock,
        function: String = #function,
        edge: @escaping (UIEdgeInsets) -> CGFloat
    ) {
        onMainThread {
            guard let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() else {
                return doReject(reject, message: "mapcontrol not available", _func: function)
            }
            resolve(edge(mapControl.mapPadding))
        }
    }

    @objc public func setMapStyle(
        _ mapStyleJSON: String,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        do {
            let mapStyle: MPMapStyleCodable = try fromJSON(mapStyleJSON)
            onMainThread {
                guard let mapControl = self.requireMapControl(reject) else { return }
                mapControl.mapStyle = mapStyle
                resolve(nil)
            }
        } catch let e {
            return doReject(reject, error: e)
        }
    }

    @objc public func getMapStyle(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            guard let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() else {
                return doReject(reject, message: "mapControl not available")
            }

            let mapStyle: MPMapStyle? = mapControl.mapStyle
            resolve(mapStyle.map { toJSON(MPMapStyleCodable(withMapStyle: $0)) })
        }
    }

    @objc public func showInfoWindowOnClickedLocation(
        _ show: Bool,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            guard let mapControl = self.requireMapControl(reject) else { return }
            mapControl.showInfoWindowOnClickedLocation = show
            resolve(nil)
        }
    }

    @objc public func deSelectLocation(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            guard let mapControl = self.requireMapControl(reject) else { return }
            mapControl.select(location: nil, behavior: .default)
            resolve(nil)
        }
    }

    @objc public func getCurrentBuildingFloor(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            guard let curFloor = MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.currentBuilding?.currentFloor else {
                return resolve(nil)
            }

            resolve(toJSON(curFloor.stringValue))
        }
    }

    @objc public func getCurrentFloorIndex(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            resolve(MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.currentFloorIndex)
        }
    }

    @objc public func getCurrentMapsIndoorsZoom(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            resolve(MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.cameraPosition.zoom)
        }
    }

    @objc public func selectFloor(
        _ floorIndex: Int,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            guard let mapControl = self.requireMapControl(reject) else { return }
            mapControl.select(floorIndex: floorIndex)
            resolve(nil)
        }
    }

    @objc public func isFloorSelectorHidden(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            resolve(MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.hideFloorSelector)
        }
    }

    @objc public func hideFloorSelector(
        _ hide: Bool,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) {
        DispatchQueue.main.async {
            MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.hideFloorSelector = hide
            return resolve(nil)
        }
    }

    @objc public func animateCamera(
        _ updateJSON: String,
        duration: Int,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) {
        guard let mapView = MapsIndoorsData.sharedInstance.mapView else {
            return doReject(reject, message: "Google maps not available")
        }

        do {
            let cameraUpdate: CameraUpdate = try fromJSON(updateJSON)
            if duration == -1 {
                try mapView.moveCamera(cameraUpdate: cameraUpdate)
            } else {
                try mapView.animateCamera(cameraUpdate: cameraUpdate, duration: duration)
            }

            return resolve(nil)
        } catch let e /*as CameraUpdateError*/ {
            return doReject(reject, error: e)
        }
    }

    @objc public func moveCamera(
        _ updateJSON: String,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) {
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

    @objc public func getCurrentCameraPosition(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            guard let mapControl = self.requireMapControl(reject) else { return }
            resolve(toJSON(MPCameraPositionCodable(withCameraPosition: mapControl.cameraPosition)))
        }
    }

    /// The map control, or nil after rejecting the promise when there is none yet. Main-actor only, like
    /// every other use of the map control.
    @MainActor private func requireMapControl(
        _ reject: @escaping RCTPromiseRejectBlock,
        function: String = #function
    ) -> MPMapControl? {
        guard let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() else {
            doReject(reject, message: "mapControl not available", _func: function)
            return nil
        }
        return mapControl
    }

    @objc public func enableLiveData(
        _ domainType: String,
        hasListener: Bool,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            let mapsIndoorsData = MapsIndoorsData.sharedInstance
            guard let mapControl = mapsIndoorsData.mapView?.getMapControl() else {
                return doReject(reject, message: "mapControl not available")
            }

            mapControl.enableLiveData(domain: domainType, listener: hasListener ? mapsIndoorsData.mapControlListenerDelegate?.onLiveDataReceived : nil)
            resolve(nil)
        }
    }

    @objc public func disableLiveData(
        _ domainType: String,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.disableLiveData(domain: domainType)
            resolve(nil)
        }
    }

    // Listeners

    @objc public func setOnMapClickListener(_ setup: Bool, consumeEvent: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        // On the main thread, where MapControlDelegate reads these flags.
        onMainThread {
            MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.respondToTap = setup
            MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.consumeTap = consumeEvent
            resolve(nil)
        }
    }

    @objc public func setOnLocationSelectedListener(_ setup: Bool, consumeEvent: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        // On the main thread, where MapControlDelegate reads these flags.
        onMainThread {
            MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.respondToDidChangeLocation = setup
            MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.consumeChangeLocation = consumeEvent
            resolve(nil)
        }
    }

    @objc public func setOnCurrentVenueChangedListener(_ setup: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        // On the main thread, where MapControlDelegate reads these flags.
        onMainThread {
            MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.respondToDidChangeVenue = setup
            resolve(nil)
        }
    }

    @objc public func setOnCurrentBuildingChangedListener(_ setup: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        // On the main thread, where MapControlDelegate reads these flags.
        onMainThread {
            MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.respondToDidChangeBuilding = setup
            resolve(nil)
        }
    }

    @objc public func setOnMarkerClickListener(_ setup: Bool, consumeEvent: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        // On the main thread, where MapControlDelegate reads these flags.
        onMainThread {
            MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.respondToTapIcon = setup
            MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.consumeTapIcon = consumeEvent
            resolve(nil)
        }
    }

    @objc public func setOnMarkerInfoWindowClickListener(_ setup: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        // On the main thread, where MapControlDelegate reads these flags.
        onMainThread {
            MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.respondToDidTapInfoWindow = setup
            resolve(nil)
        }
    }

    @objc public func setOnFloorUpdateListener(_ setup: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        // On the main thread, where MapControlDelegate reads these flags.
        onMainThread {
            MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.respondToDidChangeFloorIndex = setup
            resolve(nil)
        }
    }

    @objc public func setMPCameraEventListener(_ setup: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        // On the main thread, where MapControlDelegate reads these flags.
        onMainThread {
            MapsIndoorsData.sharedInstance.mapControlListenerDelegate?.respondToCameraEvents = setup
            resolve(nil)
        }
    }

    // Floor selector

    @objc public func setFloorSelector(
        _ setup: Bool,
        isAutoFloorChangeEnabled: Bool,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            let mapsIndoorsData = MapsIndoorsData.sharedInstance

            guard let mapControl = mapsIndoorsData.mapView?.getMapControl() else {
                return doReject(reject, message: "mapControl is not available")
            }

            if setup {
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

            resolve(nil)
        }
    }

    @objc public func onFloorSelectionChanged(
        _ newFloorJson: String,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        let floor: MPFloorCodable
        do {
            floor = try fromJSON(newFloorJson)
        } catch let e {
            return doReject(reject, error: e)
        }

        // `floorSelector` is assigned on the main thread by setFloorSelector.
        onMainThread {
            guard let floorSelector = MapsIndoorsData.sharedInstance.floorSelector else {
                return doReject(reject, message: "Floor selector not available")
            }

            floorSelector.onFloorSelectionChanged(newFloor: floor.floorIndex ?? 0)
            resolve(nil)
        }
    }

    @objc public func setLabelOptions(
        _ textSize: NSNumber?,
        color: String?,
        showHalo: Bool,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        let haloWidth: Float = showHalo ? 1.0 : 0.0
        let haloBlur: Float = showHalo ? 1.0 : 0.0
        let haloColor = UIColor.white

        let textColor: UIColor?
        do {
            textColor = try color.map { try colorFromHexString(hex: $0) }
        } catch {
            return doReject(reject, error: error)
        }

        onMainThread {
            guard let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() else {
                return doReject(reject, message: "mapControl is not available")
            }

            if textSize != -1, let textColor {
                mapControl.setMapLabelFont(font: UIFont.systemFont(ofSize: CGFloat(truncating: textSize!)), textSize: Float(truncating: textSize!), color: textColor, labelHaloColor: haloColor, labelHaloWidth: haloWidth, labelHaloBlur: haloBlur)
            } else if let textColor {
                mapControl.setMapLabelFont(color: textColor, labelHaloColor: haloColor, labelHaloWidth: haloWidth, labelHaloBlur: haloBlur)
            } else if textSize != -1 {
                mapControl.setMapLabelFont(font: UIFont.systemFont(ofSize: CGFloat(truncating: textSize!)), textSize: Float(truncating: textSize!), labelHaloColor: haloColor, labelHaloWidth: haloWidth, labelHaloBlur: haloBlur)
            } else {
                mapControl.setMapLabelFont(labelHaloColor: haloColor, labelHaloWidth: haloWidth, labelHaloBlur: haloBlur)
            }
            resolve(nil)
        }
    }

    @objc public func setBuildingSelectionMode(
        _ selectionMode: NSNumber,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            guard let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() else {
                return doReject(reject, message: "mapControl is not available")
            }

            mapControl.buildingSelectionMode = MPSelectionMode(rawValue: selectionMode.intValue) ?? .automatic
            resolve(nil)
        }
    }

    @objc public func getBuildingSelectionMode(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            guard let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() else {
                return doReject(reject, message: "mapControl is not available")
            }

            resolve(mapControl.buildingSelectionMode.rawValue)
        }
    }

    @objc public func setFloorSelectionMode(
        _ selectionMode: NSNumber,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            guard let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() else {
                return doReject(reject, message: "mapControl is not available")
            }

            mapControl.floorSelectionMode = MPSelectionMode(rawValue: selectionMode.intValue) ?? .automatic
            resolve(nil)
        }
    }

    @objc public func getFloorSelectionMode(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            guard let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() else {
                return doReject(reject, message: "mapControl is not available")
            }

            resolve(mapControl.floorSelectionMode.rawValue)
        }
    }

    @objc public func setHiddenFeatures(
        _ features: String,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
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

        onMainThread {
            guard let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() else {
                return doReject(reject, message: "mapControl is not available")
            }

            mapControl.hiddenFeatures = featureTypes.map({ $0.rawValue })
            resolve(nil)
        }
    }

    @objc public func getHiddenFeatures(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        onMainThread {
            guard let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() else {
                return doReject(reject, message: "mapControl is not available")
            }

            guard let hiddenFeatures = try? JSONEncoder().encode(mapControl.hiddenFeatures) else {
                return doReject(reject, message: "something went wrong encoding hiddenfeatures")
            }

            resolve(String(data: hiddenFeatures, encoding: String.Encoding.utf8))
        }
    }
}
