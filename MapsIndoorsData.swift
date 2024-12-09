import MapsIndoors
import MapsIndoorsCore
import MapsIndoorsCodable
import React

protocol LiveDataDelegate {
    func onLiveDataReceived(liveUpdate: MPLiveUpdate)
}

class MapsIndoorsData {
    public static var sharedInstance: MapsIndoorsData = MapsIndoorsData()
    
    public static func reset() {
        sharedInstance = MapsIndoorsData()
    }

    public var mapView: RCMapView?
    public var directionsRenderer: MPDirectionsRenderer? = nil
    public var isInitialized: Bool = false

    var mapControlListenerDelegate: MapControlDelegate?
    var floorSelector: FloorSelector?

    public enum Event: String, CaseIterable, RawRepresentable {
        case onFloorUpdate
        case floorSelector
        case cameraEvent
        case onLocationSelected
        case onMapClick
        case onVenueFoundAtCameraTarget
        case onBuildingFoundAtCameraTarget
        case onMarkerClick
        case onInfoWindowClick
        case onLiveLocationUpdate
        case onLegSelected
    }

    lazy var allEvents: [String] = {
        var allEventNames: [String] = Event.allCases.map{$0.rawValue}
        return allEventNames
    }()
}

class MapControlDelegate: MPMapControlDelegate, LiveDataDelegate, MPFloorSelectorDelegate {
    var eventEmitter: RCTEventEmitter

    var respondToTap: Bool = false
    var consumeTap: Bool = false

    var respondToTapIcon: Bool = false
    var consumeTapIcon: Bool = false

    var respondToDidChangeFloorIndex: Bool = false

    var respondToDidChangeBuilding: Bool = false

    var respondToDidChangeVenue: Bool = false

    var respondToDidChangeLocation: Bool = false
    var consumeChangeLocation: Bool = false

    var respondToDidTapInfoWindow: Bool = false
    
    var respondToCameraEvents: Bool = false

    init(eventEmitter: RCTEventEmitter) {
        self.eventEmitter = eventEmitter
    }
    

    private func sendEvent(event: MapsIndoorsData.Event, body: [String: Any?]) {
        eventEmitter.sendEvent(withName: event.rawValue, body: body)
    }

    // MPMapControlDelegate:
    
    func didChangeCameraPosition() -> Bool {
        if (respondToCameraEvents) {
            sendEvent(event: .cameraEvent, body: ["event": 5])
        }
        return false;
    }

    func cameraIdle() -> Bool {
        if (respondToCameraEvents) {
            sendEvent(event: .cameraEvent, body: ["event": 7])
        }
        return false;
    }
    
    func cameraWillMove() -> Bool {
        if (respondToCameraEvents) {
            sendEvent(event: .cameraEvent, body: ["event": 5])
        }
        return false;
    }
    
    func didTap(coordinate: MPPoint) -> Bool {
        if (respondToTap) {
            sendEvent(event: .onMapClick, body: ["point": toJSON(coordinate)])
            return consumeTap
        }
        return false
    }

    func didTapIcon(location: MPLocation) -> Bool {
        if (respondToTapIcon) {
            sendEvent(event: .onMarkerClick, body: ["locationId": location.locationId])
            return consumeTapIcon
        }
        return false
    }

    func didChange(floorIndex: Int) -> Bool {
        if (respondToDidChangeFloorIndex) {
            sendEvent(event: .onFloorUpdate, body: ["floorIndex": floorIndex])
        }
        
        MapsIndoorsData.sharedInstance.floorSelector?.onFloorSelectionChanged(newFloor: NSNumber(value: floorIndex))
        return false
    }

    func didChange(selectedVenue: MPVenue?) -> Bool {
        if (respondToDidChangeVenue) {
            sendEvent(event: .onVenueFoundAtCameraTarget, body: ["venue": selectedVenue.map{ toJSON(MPVenueCodable(withVenue:($0))) }])
        }
        return false
    }

    func didChange(selectedBuilding: MPBuilding?) -> Bool {
        if (respondToDidChangeBuilding) {
            sendEvent(event: .onBuildingFoundAtCameraTarget, body: ["building": selectedBuilding.map{ toJSON(MPBuildingCodable(withBuilding:($0))) }])
        }
        MapsIndoorsData.sharedInstance.floorSelector?.building = selectedBuilding
        return false
    }

    func didChange(selectedLocation: MPLocation?) -> Bool {
        if (respondToDidChangeLocation) {
            sendEvent(event: .onLocationSelected, body: ["location": selectedLocation.map{ toJSON(MPLocationCodable(withLocation:($0))) }])
            return consumeChangeLocation
        }
        return false
    }

    func didTapInfoWindow(location: MPLocation) -> Bool {
        if (respondToDidTapInfoWindow) {
            sendEvent(event: .onInfoWindowClick, body: ["locationId": location.locationId])
        }
        return false
    }

    // LiveDataDelegate:

    func onLiveDataReceived(liveUpdate: MPLiveUpdate) {
        guard let location = MPMapsIndoors.shared.locationWith(locationId: liveUpdate.itemId) else {
            return
        }

        sendEvent(event: .onLiveLocationUpdate, body: [ "location": toJSON(MPLocationCodable(withLocation:(location))) ])
    }

    // MPFloorSelectorDelegate:

    func onFloorIndexChanged(_ floorIndex: NSNumber) {
        sendEvent(event: .onFloorUpdate, body: ["floorIndex": floorIndex])
        MapsIndoorsData.sharedInstance.floorSelector?.onFloorSelectionChanged(newFloor: floorIndex)
    }

    func floorSelector(method: FloorSelector.Event, args: [String: Any]) {
        let body = try! ["method": method.rawValue].merging(args, uniquingKeysWith: { _,_ in throw MPError.unknownError })

        sendEvent(event: .floorSelector, body: body)
    }
}


class FloorSelector: UIView, MPCustomFloorSelector {

    enum Event: String, CaseIterable, RawRepresentable {
        case show
        case setList
        case setUserPositionFloor
        // TODO: the rest are not implemented since they are not available from the MPCustomFloorSelector protocol, and are not implemented in flutter
//        case setSelectedFloor
        case setSelectedFloorByFloorIndex
//        case zoomLevelChanged
    }
    
    lazy var allEvents: [String] = {
        var allEventNames: [String] = Event.allCases.map{$0.rawValue}
        return allEventNames
    }()

    var building: MapsIndoors.MPBuilding?
    var latestBuilding: MapsIndoors.MPBuilding?
    var delegate: MapsIndoors.MPFloorSelectorDelegate?

    var hide: Bool = false
    
    var floorIndex: NSNumber?

    var autoFloorChange = true
    var listenerDelegate: MapControlDelegate

    init(delegate: MPFloorSelectorDelegate) {
        listenerDelegate = MapsIndoorsData.sharedInstance.mapControlListenerDelegate!

        super.init(frame: CGRect())
        self.delegate = delegate
    }

    required init?(coder: NSCoder) {
        listenerDelegate = MapsIndoorsData.sharedInstance.mapControlListenerDelegate!

        super.init(frame: CGRect())
    }

    func onFloorSelectionChanged(newFloor: NSNumber) {
        let floorIndex = newFloor.intValue
        listenerDelegate.floorSelector(method: .setSelectedFloorByFloorIndex, args: ["floorIndex": newFloor])
    }

    func onShow() {
        if (!hide && building === latestBuilding) {
            return
        }
        if let building {
            listenerDelegate.floorSelector(method: .setList, args: [
                "list": toJSON(building.floors?.values.sorted(by: { (floor1, floor2) -> Bool in
                    return floor1.floorIndex!.intValue < floor2.floorIndex!.intValue
                }).map{MPFloorCodable(withFloor: $0)})
            ])
        }

        listenerDelegate.floorSelector(method: .show, args: ["show": true, "animated": true])
        latestBuilding = building
        hide = false
    }
    
    func onHide() {
        if (hide) {
            return
        }
        listenerDelegate.floorSelector(method: .show, args: ["show": false, "animated": true])
        latestBuilding = nil
        hide = true
    }

    func onUserPositionFloorChange(floorIndex: Int) {
        listenerDelegate.floorSelector(method: .setUserPositionFloor, args: ["floor": floorIndex])
    }

}
