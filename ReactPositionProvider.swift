import Foundation

import MapsIndoors

public class ReactPositionProvider: MPPositionProvider {
    public var latestPosition: MapsIndoors.MPPositionResult?

    public var name = "default"
    public var delegate: MapsIndoors.MPPositionProviderDelegate?
    private var mapsIndoorsData: MapsIndoorsData

    init() {
        mapsIndoorsData = MapsIndoorsData.sharedInstance
    }

    public func setLatestPosition(positionResult: MPPositionResult) {
        if (latestPosition?.floorIndex != positionResult.floorIndex) {
            let floorSelector = mapsIndoorsData.floorSelector
            floorSelector?.onUserPositionFloorChange(floorIndex: positionResult.floorIndex)
        }

        delegate?.onPositionUpdate(position: positionResult)
        latestPosition = positionResult
    }
}
