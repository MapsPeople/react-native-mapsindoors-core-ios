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
        DispatchQueue.main.async {
            if self.latestPosition?.floorIndex != positionResult.floorIndex {
                let floorSelector = self.mapsIndoorsData.floorSelector
                floorSelector?.onUserPositionFloorChange(floorIndex: positionResult.floorIndex)
            }

            self.delegate?.onPositionUpdate(position: positionResult)
            self.latestPosition = positionResult
        }
    }
}
