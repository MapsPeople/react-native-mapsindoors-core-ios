import Foundation

import MapsIndoors
import MapsIndoorsCore

public struct IconSizeStruct: Codable {
    public var width: Int
    public var height: Int
}; extension IconSizeStruct { // Don't want to lose default initializer, so this must be in an extension
    public init(withCGSize: CGSize) {
        height = Int(withCGSize.height)
        width = Int(withCGSize.width)
    }
}

private func doReject(_ reject: RCTPromiseRejectBlock, displayRuleId: String,
                      _file: String = #fileID, _func: String = #function, _line: Int = #line, _col: Int = #column) {
    return doReject(reject, message: "The DisplayRule (id: \"\(displayRuleId)\") cannot be found", _file: _file, _func: _func, _line: _line, _col: _col)
}

@objc(DisplayRule)
public class MPDisplayRuleModule: NSObject {

    @objc static func requiresMainQueueSetup() -> Bool { return false }
    
    private func getIconPlacement(iconPlacement: NSNumber) -> MPIconPlacement {
        switch(iconPlacement.intValue) {
        case 1:
            return .above
        case 2:
            return .below
        case 3:
            return .left
        case 4:
            return .right
        default:
            return .center
        }
    }
    
    private func getLabelType(labelType: NSNumber) -> MPLabelType {
        switch(labelType.intValue) {
        case 0:
            return .flat
        case 1:
            return .floating
        case 2:
            return .graphic
        default:
            return .floating
        }
    }
    
    private func getBadgePosition(badgePosition: NSNumber) -> MPBadgePosition {
        switch(badgePosition.intValue) {
        case 1:
            return .bottomRight
        case 2:
            return .topLeft
        case 3:
            return .topRight
        default:
            return .bottomLeft
        }
    }
    
    private func getTypeRule(typeName: String) -> MPDisplayRuleType? {
    // TODO: very similar to FLutter code, maybe combine shared functions somewhere
        switch (typeName) {
        case "buildingOutline": // TODO: OutLine?
            return .buildingOutline
        case "selectionHighlight":
            return .selectionHighlight
        case "selection":
            return .selection
        case "highlight":
            return .highlight
        case "positionIndicator":
            return .blueDot
        case "main":
            return .main
        case "default":
            return .default
        default:
            return nil
        }
    }

    private func getRule(name: String) -> MPDisplayRule? {
        if let typeRule = getTypeRule(typeName: name) {
            return MPMapsIndoors.shared.displayRuleFor(displayRuleType: typeRule)
        } else if let namedRule = MPMapsIndoors.shared.displayRuleFor(type: name.lowercased()){
            return namedRule
        } else if let loc = MPMapsIndoors.shared.locationWith(locationId: name) {
            return MPMapsIndoors.shared.displayRuleFor(location: loc)!
        } else {
            return nil
        }
    }

    func hexStringFromColor(color: UIColor) -> String {
        // TODO: copy paste from Flutter
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        return hexString
    }

    enum HexParsingError: Error {
        case invalidHexString(String)
    }
    func colorFromHexString(hex: String) throws -> UIColor? {
        let regex = try! NSRegularExpression(pattern: "^#[0-9A-Fa-f]{6}$|^#[0-9A-Fa-f]{8}$")
        let range = NSRange(location: 0, length: hex.utf16.count)

        if (regex.matches(in: hex, range: range).count == 1) {
            return UIColor(hex: hex)!
        } else {
            throw HexParsingError.invalidHexString(hex)
        }
    }

    func cgSizeFromIconSizeJson(json: String) throws -> CGSize {
        let iconSize: IconSizeStruct = try fromJSON(json)
        return CGSize(width: iconSize.width, height: iconSize.height)
    }

    func iconSizeJsonFromCgSize(size: CGSize) -> String {
        let iconSize = IconSizeStruct(withCGSize: size)
        return toJSON(iconSize)
    }

// End of head

    // Getter isVisible->visible
    @objc public func isVisible(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.visible)
    }

    // Setter setVisible->visible
    @objc public func setVisible(_ displayRuleId: String, value: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        displayRule.visible = value

        return resolve(nil)
    }

    // Getter isIconVisible->iconVisible
    @objc public func isIconVisible(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.iconVisible)
    }

    // Setter setIconVisible->iconVisible
    @objc public func setIconVisible(_ displayRuleId: String, value: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        displayRule.iconVisible = value

        return resolve(nil)
    }

    // Getter isPolygonVisible->polygonVisible
    @objc public func isPolygonVisible(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.polygonVisible)
    }

    // Setter setPolygonVisible->polygonVisible
    @objc public func setPolygonVisible(_ displayRuleId: String, value: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        displayRule.polygonVisible = value

        return resolve(nil)
    }

    // Getter isLabelVisible->labelVisible
    @objc public func isLabelVisible(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.labelVisible)
    }

    // Setter setLabelVisible->labelVisible
    @objc public func setLabelVisible(_ displayRuleId: String, value: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        displayRule.labelVisible = value

        return resolve(nil)
    }

    // Getter isModel2DVisible->model2DVisible
    @objc public func isModel2DVisible(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.model2DVisible)
    }

    // Setter setModel2DVisible->model2DVisible
    @objc public func setModel2DVisible(_ displayRuleId: String, value: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        displayRule.model2DVisible = value

        return resolve(nil)
    }

    // Getter isWallVisible->wallsVisible
    @objc public func isWallVisible(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.wallsVisible)
    }

    // Setter setWallVisible->wallsVisible
    @objc public func setWallVisible(_ displayRuleId: String, value: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        displayRule.wallsVisible = value

        return resolve(nil)
    }

    // Getter isExtrusionVisible->extrusionVisible
    @objc public func isExtrusionVisible(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.extrusionVisible)
    }

    // Setter setExtrusionVisible->extrusionVisible
    @objc public func setExtrusionVisible(_ displayRuleId: String, value: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        displayRule.extrusionVisible = value

        return resolve(nil)
    }

    // Getter getZoomFrom->zoomFrom
    @objc public func getZoomFrom(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.zoomFrom)
    }

    // Setter setZoomFrom->zoomFrom
    @objc public func setZoomFrom(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if (value != -1) {
            displayRule.zoomFrom = value
        }
        
        return resolve(nil)
    }

    // Getter getZoomTo->zoomTo
    @objc public func getZoomTo(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.zoomTo)
    }

    // Setter setZoomTo->zoomTo
    @objc public func setZoomTo(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.zoomTo = value
        }
        
        return resolve(nil)
    }

    // Getter getIconUrl->iconURL
    @objc public func getIconUrl(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.iconURL?.absoluteString)
    }

    // Setter setIcon->iconURL
    @objc public func setIcon(_ displayRuleId: String, value: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        displayRule.iconURL = URL(string: value)

        return resolve(nil)
    }

    // Getter getIconSize->iconSize
    @objc public func getIconSize(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(iconSizeJsonFromCgSize(size: displayRule.iconSize))
    }

    // Setter setIconSize->iconSize
    @objc public func setIconSize(_ displayRuleId: String, value: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        do {
            displayRule.iconSize = try cgSizeFromIconSizeJson(json: value)
        } catch let e {
            return doReject(reject, error: e)
        }

        return resolve(nil)
    }

    // Getter getLabel->label
    @objc public func getLabel(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.label)
    }

    // Setter setLabel->label
    @objc public func setLabel(_ displayRuleId: String, value: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        displayRule.label = value

        return resolve(nil)
    }

    // Getter getLabelZoomFrom->labelZoomFrom
    @objc public func getLabelZoomFrom(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.labelZoomFrom)
    }

    // Setter setLabelZoomFrom->labelZoomFrom
    @objc public func setLabelZoomFrom(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.labelZoomFrom = value
        }

        return resolve(nil)
    }

    // Getter getLabelZoomTo->labelZoomTo
    @objc public func getLabelZoomTo(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.labelZoomTo)
    }

    // Setter setLabelZoomTo->labelZoomTo
    @objc public func setLabelZoomTo(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.labelZoomTo = value
        }

        return resolve(nil)
    }

    // Getter getLabelMaxWidth->labelMaxWidth
    @objc public func getLabelMaxWidth(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.labelMaxWidth)
    }

    // Setter setLabelMaxWidth->labelMaxWidth
    @objc public func setLabelMaxWidth(_ displayRuleId: String, value: UInt, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.labelMaxWidth = value
        }

        return resolve(nil)
    }

    // Getter getPolygonZoomFrom->polygonZoomFrom
    @objc public func getPolygonZoomFrom(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.polygonZoomFrom)
    }

    // Setter setPolygonZoomFrom->polygonZoomFrom
    @objc public func setPolygonZoomFrom(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.polygonZoomFrom = value
        }

        return resolve(nil)
    }

    // Getter getPolygonZoomTo->polygonZoomTo
    @objc public func getPolygonZoomTo(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.polygonZoomTo)
    }

    // Setter setPolygonZoomTo->polygonZoomTo
    @objc public func setPolygonZoomTo(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if(value != -1) {
            displayRule.polygonZoomTo = value
        }
        
        return resolve(nil)
    }

    // Getter getPolygonStrokeWidth->polygonStrokeWidth
    @objc public func getPolygonStrokeWidth(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.polygonStrokeWidth)
    }

    // Setter setPolygonStrokeWidth->polygonStrokeWidth
    @objc public func setPolygonStrokeWidth(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if(value != -1) {
            displayRule.polygonStrokeWidth = value
        }

        return resolve(nil)
    }

    // Getter getPolygonStrokeColor->polygonStrokeColor
    @objc public func getPolygonStrokeColor(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        guard let color = displayRule.polygonStrokeColor else {
            return resolve(nil)
        }

        return resolve(hexStringFromColor(color: color))
    }

    // Setter setPolygonStrokeColor->polygonStrokeColor
    @objc public func setPolygonStrokeColor(_ displayRuleId: String, value: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        do {
            displayRule.polygonStrokeColor = try colorFromHexString(hex: value)
        } catch let e {
            return doReject(reject, error: e)
        }

        return resolve(nil)
    }

    // Getter getPolygonStrokeOpacity->polygonStrokeOpacity
    @objc public func getPolygonStrokeOpacity(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.polygonStrokeOpacity)
    }

    // Setter setPolygonStrokeOpacity->polygonStrokeOpacity
    @objc public func setPolygonStrokeOpacity(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.polygonStrokeOpacity = value
        }else {
            displayRule.polygonStrokeOpacity = nil
        }

        return resolve(nil)
    }

    // Getter getPolygonFillColor->polygonFillColor
    @objc public func getPolygonFillColor(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        guard let color = displayRule.polygonFillColor else {
            return resolve(nil)
        }

        return resolve(hexStringFromColor(color: color))
    }

    // Setter setPolygonFillColor->polygonFillColor
    @objc public func setPolygonFillColor(_ displayRuleId: String, value: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        do {
            displayRule.polygonFillColor = try colorFromHexString(hex: value)
        } catch let e {
            return doReject(reject, error: e)
        }

        return resolve(nil)
    }

    // Getter getPolygonFillOpacity->polygonFillOpacity
    @objc public func getPolygonFillOpacity(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.polygonFillOpacity)
    }

    // Setter setPolygonFillOpacity->polygonFillOpacity
    @objc public func setPolygonFillOpacity(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if(value != -1) {
            displayRule.polygonFillOpacity = value
        }else {
            displayRule.polygonFillOpacity = nil
        }

        return resolve(nil)
    }

    // Getter getWallColor->wallsColor
    @objc public func getWallColor(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        guard let color = displayRule.wallsColor else {
            return resolve(nil)
        }

        return resolve(hexStringFromColor(color: color))
    }

    // Setter setWallColor->wallsColor
    @objc public func setWallColor(_ displayRuleId: String, value: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        do {
            displayRule.wallsColor = try colorFromHexString(hex: value)
        } catch let e {
            return doReject(reject, error: e)
        }

        return resolve(nil)
    }

    // Getter getWallHeight->wallsHeight
    @objc public func getWallHeight(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.wallsHeight)
    }

    // Setter setWallHeight->wallsHeight
    @objc public func setWallHeight(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.wallsHeight = value
        }

        return resolve(nil)
    }

    // Getter getWallZoomFrom->wallsZoomFrom
    @objc public func getWallZoomFrom(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.wallsZoomFrom)
    }

    // Setter setWallZoomFrom->wallsZoomFrom
    @objc public func setWallZoomFrom(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.wallsZoomFrom = value
        }

        return resolve(nil)
    }

    // Getter getWallZoomTo->wallsZoomTo
    @objc public func getWallZoomTo(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.wallsZoomTo)
    }

    // Setter setWallZoomTo->wallsZoomTo
    @objc public func setWallZoomTo(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.wallsZoomTo = value
        }

        return resolve(nil)
    }

    // Getter getExtrusionColor->extrusionColor
    @objc public func getExtrusionColor(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        guard let color = displayRule.extrusionColor else {
            return resolve(nil)
        }

        return resolve(hexStringFromColor(color: color))
    }

    // Setter setExtrusionColor->extrusionColor
    @objc public func setExtrusionColor(_ displayRuleId: String, value: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        do {
            displayRule.extrusionColor = try colorFromHexString(hex: value)
        } catch let e {
            return doReject(reject, error: e)
        }

        return resolve(nil)
    }

    // Getter getExtrusionHeight->extrusionHeight
    @objc public func getExtrusionHeight(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.extrusionHeight)
    }

    // Setter setExtrusionHeight->extrusionHeight
    @objc public func setExtrusionHeight(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.extrusionHeight = value
        }

        return resolve(nil)
    }

    // Getter getExtrusionZoomFrom->extrusionZoomFrom
    @objc public func getExtrusionZoomFrom(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.extrusionZoomFrom)
    }

    // Setter setExtrusionZoomFrom->extrusionZoomFrom
    @objc public func setExtrusionZoomFrom(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.extrusionZoomFrom = value
        }

        return resolve(nil)
    }

    // Getter getExtrusionZoomTo->extrusionZoomTo
    @objc public func getExtrusionZoomTo(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.extrusionZoomTo)
    }

    // Setter setExtrusionZoomTo->extrusionZoomTo
    @objc public func setExtrusionZoomTo(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.extrusionZoomTo = value
        }

        return resolve(nil)
    }

    // Getter getModel2DZoomFrom->model2DZoomFrom
    @objc public func getModel2DZoomFrom(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.model2DZoomFrom)
    }

    // Setter setModel2DZoomFrom->model2DZoomFrom
    @objc public func setModel2DZoomFrom(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.model2DZoomFrom = value
        }

        return resolve(nil)
    }

    // Getter getModel2DZoomTo->model2DZoomTo
    @objc public func getModel2DZoomTo(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.model2DZoomTo)
    }

    // Setter setModel2DZoomTo->model2DZoomTo
    @objc public func setModel2DZoomTo(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.model2DZoomTo = value
        }

        return resolve(nil)
    }

    // Getter getModel2DWidthMeters->model2DWidthMeters
    @objc public func getModel2DWidthMeters(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.model2DWidthMeters)
    }

    // Setter setModel2DWidthMeters->model2DWidthMeters
    @objc public func setModel2DWidthMeters(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.model2DWidthMeters = value
        }

        return resolve(nil)
    }

    // Getter getModel2DHeightMeters->model2DHeightMeters
    @objc public func getModel2DHeightMeters(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.model2DHeightMeters)
    }

    // Setter setModel2DHeightMeters->model2DHeightMeters
    @objc public func setModel2DHeightMeters(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.model2DHeightMeters = value
        }

        return resolve(nil)
    }

    // Getter getModel2DBearing->model2DBearing
    @objc public func getModel2DBearing(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.model2DBearing)
    }

    // Setter setModel2DBearing->model2DBearing
    @objc public func setModel2DBearing(_ displayRuleId: String, value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.model2DBearing = value
        }

        return resolve(nil)
    }

    // Getter getModel2DModel->model2DModel
    @objc public func getModel2DModel(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.model2DModel)
    }

    // Setter setModel2DModel->model2DModel
    @objc public func setModel2DModel(_ displayRuleId: String, value: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        displayRule.model2DModel = value

        return resolve(nil)
    }
    
    @objc public func getBadgeFillColor(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        guard let color = displayRule.badgeFillColor else {
            return resolve(nil)
        }

        return resolve(hexStringFromColor(color: color))
    }
    
    @objc public func setBadgeFillColor(_ displayRuleId: String, value: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        do {
            displayRule.badgeFillColor = try colorFromHexString(hex: value)
        } catch let e {
            return doReject(reject, error: e)
        }
        
        
        return resolve(nil)
    }
    
    @objc public func getBadgeStrokeColor(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        guard let color = displayRule.badgeStrokeColor else {
            return resolve(nil)
        }

        return resolve(hexStringFromColor(color: color))
    }
    
    @objc public func setBadgeStrokeColor(_ displayRuleId: String, value: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        do {
            displayRule.badgeStrokeColor = try colorFromHexString(hex: value)
        }catch let e {
           return doReject(reject, error: e)
        }
        
        return resolve(nil)
    }
    
    @objc public func getBadgeRadius(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.badgeRadius)
    }
    
    @objc public func setBadgeRadius(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.badgeRadius = value.intValue
        }
        
        return resolve(nil)
    }
    
    @objc public func getBadgeStrokeWidth(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.badgeStrokeWidth)
    }
    
    @objc public func setBadgeStrokeWidth(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.badgeStrokeWidth = value.doubleValue
        }
        
        return resolve(nil)
    }
    
    @objc public func getBadgePosition(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.badgePosition)
    }
    
    @objc public func setBadgePosition(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.badgePosition = getBadgePosition(badgePosition: value)
        }else {
            displayRule.badgePosition = nil
        }
        
        return resolve(nil)
    }
    
    @objc public func getIconPlacement(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.iconPlacement)
    }
    
    @objc public func setIconPlacement(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if (value != -1) {
            displayRule.iconPlacement = getIconPlacement(iconPlacement: value)
        }else {
            displayRule.iconPlacement = nil
        }
        
        return resolve(nil)
    }
    
    @objc public func getLabelType(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.iconPlacement)
    }
    
    @objc public func setLabelType(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if (value != -1) {
            displayRule.labelType = getLabelType(labelType: value)
        }else {
            displayRule.labelType = nil
        }
        
        return resolve(nil)
    }
    
    @objc public func getLabelStyleTextSize(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.labelStyleTextSize)
    }
    
    @objc public func setLabelStyleTextSize(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.labelStyleTextSize = value.intValue
        }
        
        return resolve(nil)
    }
    
    @objc public func getLabelStyleTextColor(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        guard let color = displayRule.labelStyleTextColor else {
            return resolve(nil)
        }

        return resolve(hexStringFromColor(color: color))
    }
    
    @objc public func setLabelStyleTextColor(_ displayRuleId: String, value: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        do {
            displayRule.labelStyleTextColor = try colorFromHexString(hex: value)
        } catch let e {
            return doReject(reject, error: e)
        }
        
        return resolve(nil)
    }
    
    @objc public func getLabelStyleHaloColor(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        guard let color = displayRule.labelStyleHaloColor else {
            return resolve(nil)
        }

        return resolve(hexStringFromColor(color: color))
    }
    
    @objc public func setLabelStyleHaloColor(_ displayRuleId: String, value: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        do {
            displayRule.labelStyleHaloColor = try colorFromHexString(hex: value)
        } catch let e {
            return doReject(reject, error: e)
        }

        return resolve(nil)
    }
    
    @objc public func getLabelStyleTextOpacity(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.labelStyleTextOpacity)
    }
    
    @objc public func setLabelStyleTextOpacity(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if (value != -1) {
            displayRule.labelStyleTextOpacity = value.doubleValue
        }
        
        return resolve(nil)
    }
    
    @objc public func getLabelStyleHaloWidth(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.labelStyleHaloWidth)
    }
    
    @objc public func setLabelStyleHaloWidth(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if (value != -1) {
            displayRule.labelStyleHaloWidth = value.intValue
        }
        
        return resolve(nil)
    }
    
    @objc public func getLabelStyleHaloBlur(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.labelStyleHaloBlur)
    }
    
    @objc public func setLabelStyleHaloBlur(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if (value != -1) {
            displayRule.labelStyleHaloBlur = value.intValue
        }
        
        return resolve(nil)
    }
    
    @objc public func getLabelStyleBearing(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.labelStyleBearing)
    }
    
    @objc public func setLabelStyleBearing(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if (value != -1) {
            displayRule.labelStyleBearing = value.doubleValue
        }
        
        return resolve(nil)
    }

    @objc public func setLabelStyleGraphic(_ displayRuleId: String, value: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        guard let labelGraphic = try? JSONDecoder().decode(LabelGraphic.self, from: value.data(using: .utf8)!) else {
            return doReject(reject, message: "Could not parse label graphic")
        }
        
        displayRule.labelStyleGraphicBackgroundImage = labelGraphic.backgroundImage
        displayRule.labelStyleGraphicStretchX = labelGraphic.stretchX
        displayRule.labelStyleGraphicStretchY = labelGraphic.stretchY
        displayRule.labelStyleGraphicContent = labelGraphic.content
        
        return resolve(nil)
    }

    @objc public func getLabelStyleGraphic(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        let labelGraphic = LabelGraphic(backgroundImage: displayRule.labelStyleGraphicBackgroundImage, stretchX: displayRule.labelStyleGraphicStretchX, stretchY: displayRule.labelStyleGraphicStretchY, content: displayRule.labelStyleGraphicContent)
        
        guard let graphicJson = try? JSONEncoder().encode(labelGraphic) else {
            return doReject(reject, message: "Could not encode label graphic")
        }
        
        return resolve(String(data: graphicJson, encoding: String.Encoding.utf8))
    }
    
    @objc public func getPolygonLightnessFactor(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        return resolve(displayRule.polygonLightnessFactor)
    }
    
    @objc public func setPolygonLightnessFactor(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if (value != -2) {
            displayRule.polygonLightnessFactor = value.doubleValue
        }
        
        return resolve(nil)
    }
    
    @objc public func getWallLightnessFactor(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.wallsLightnessFactor)
    }
    
    @objc public func setWallLightnessFactor(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if (value != -2) {
            displayRule.wallsLightnessFactor = value.doubleValue
        }
        
        return resolve(nil)
    }
    
    @objc public func getExtrusionLightnessFactor(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.extrusionLightnessFactor)
    }
    
    @objc public func setExtrusionLightnessFactor(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if (value != -2) {
            displayRule.extrusionLightnessFactor = value.doubleValue
        }
        
        return resolve(nil)
    }
    
    @objc public func getIconScale(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.iconScale)
    }
    
    @objc public func setIconScale(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if (value != -1) {
            displayRule.iconScale = value.doubleValue
        }
        
        return resolve(nil)
    }
    
    @objc public func getBadgeScale(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.badgeScale)
    }
    
    @objc public func setBadgeScale(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if (value != -1) {
            displayRule.badgeScale = value.doubleValue
        }
        
        return resolve(nil)
    }

    @objc public func getBadgeZoomFrom(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.badgeZoomFrom)
    }
    
    @objc public func setBadgeZoomFrom(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if (value != -1) {
            displayRule.badgeZoomFrom = value.doubleValue
        }
        
        return resolve(nil)
    }
    
    @objc public func getBadgeZoomTo(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.badgeZoomTo)
    }
    
    @objc public func setBadgeZoomTo(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if (value != -1) {
            displayRule.badgeZoomTo = value.doubleValue
        }
        
        return resolve(nil)
    }
    
    @objc public func isBadgeVisible(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        return resolve(displayRule.badgeVisible)
    }
    
    @objc public func setBadgeVisible(_ displayRuleId: String, value: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        displayRule.badgeVisible = value
        
        return resolve(nil)
    }

    @objc public func getModel3DModel(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        return resolve(displayRule.model3DModel)
    }

    @objc public func setModel3DModel(_ displayRuleId: String, value: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        displayRule.model3DModel = value
        
        return resolve(nil)
    }

    @objc public func getModel3DRotationX(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        return resolve(displayRule.model3DRotationX)
    }

    @objc public func setModel3DRotationX(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if (value != -1) {
            displayRule.model3DRotationX = value.doubleValue
        }
        
        return resolve(nil)
    }

    @objc public func getModel3DRotationY(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        return resolve(displayRule.model3DRotationY)
    }

    @objc public func setModel3DRotationY(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if (value != -1) {
            displayRule.model3DRotationY = value.doubleValue
        }
        
        return resolve(nil)
    }

    @objc public func getModel3DRotationZ(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        return resolve(displayRule.model3DRotationZ)
    }

    @objc public func setModel3DRotationZ(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if (value != -1) {
            displayRule.model3DRotationZ = value.doubleValue
        }
        
        return resolve(nil)
    }

    @objc public func isModel3DVisible(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        return resolve(displayRule.model3DVisible)
    }

    @objc public func setModel3DVisible(_ displayRuleId: String, value: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        displayRule.model3DVisible = value
        
        return resolve(nil)
    }

    @objc public func getModel3DZoomFrom(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        return resolve(displayRule.model3DZoomFrom)
    }

    @objc public func setModel3DZoomFrom(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if (value != -1) {
            displayRule.model3DZoomFrom = value.doubleValue
        }
        
        return resolve(nil)
    }

    @objc public func getModel3DZoomTo(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        return resolve(displayRule.model3DZoomTo)
    }

    @objc public func setModel3DZoomTo(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        if (value != -1) {
            displayRule.model3DZoomTo = value.doubleValue
        }
        
        return resolve(nil)
    }

    @objc public func getModel3DScale(_ displayRuleId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }
        
        return resolve(displayRule.model3DScale)
    }

    @objc public func setModel3DScale(_ displayRuleId: String, value: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        if (value != -1) {
            displayRule.model3DScale = value.doubleValue
        }
        
        return resolve(nil)
    }

// Start of tail

    @objc public func reset(_ displayRuleId: String,resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let displayRule = getRule(name: displayRuleId) else {
            return doReject(reject, displayRuleId: displayRuleId)
        }

        displayRule.reset()

        return resolve(nil)
    }

}