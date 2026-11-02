import Foundation
import MapsIndoors

public class ReactPositionProvider: MPPositionProvider {
    public var latestPosition: MapsIndoors.MPPositionResult?

    public var name = "default"
    // Weak: the delegate is the map control, which holds this provider. Strong, the pair kept each
    // other, and the map, alive after the map view was gone (SPEX-2885).
    public weak var delegate: MapsIndoors.MPPositionProviderDelegate?

    public func setLatestPosition(positionResult: MPPositionResult) {
        DispatchQueue.main.async {
            if self.latestPosition?.floorIndex != positionResult.floorIndex {
                // Read per call, not kept: every new map view resets `sharedInstance`, and a kept
                // instance closed the cycle provider -> data -> map view -> map control -> provider.
                let floorSelector = MapsIndoorsData.sharedInstance.floorSelector
                floorSelector?.onUserPositionFloorChange(floorIndex: positionResult.floorIndex)
            }

            self.delegate?.onPositionUpdate(position: positionResult)
            self.latestPosition = positionResult
        }
    }
}
