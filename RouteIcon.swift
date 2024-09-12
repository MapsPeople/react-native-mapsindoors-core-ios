//
//  RouteIcon.swift
//  react-native-maps-indoors-mapbox
//
//  Created by Tim Mikkelsen on 15/05/2024.
//

import MapsIndoorsCore
import Foundation

struct RouteIcon: Codable {
    let numbered: Bool
    let label: String
    let color: String
    
    public func getIcon() -> MPRouteStopIconConfig {
        return MPRouteStopIconConfig(numbered: numbered, label: label, color: try! colorFromHexString(hex: color))
    }
    
    private func colorFromHexString(hex: String) throws -> UIColor {
        let regex = try! NSRegularExpression(pattern: "^#[0-9A-Fa-f]{6}$|^#[0-9A-Fa-f]{8}$")
        let range = NSRange(location: 0, length: hex.utf16.count)

        if (regex.matches(in: hex, range: range).count == 1) {
            return UIColor(hex: hex)!
        } else {
           throw HexParsingError.invalidHexString(hex)
        }
    }
    
    enum HexParsingError: Error {
        case invalidHexString(String)
    }
}
