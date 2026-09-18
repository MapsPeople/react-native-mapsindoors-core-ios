//
//  UtilsModule.swift
//  react-native-maps-indoors
//
//  Created by Tim Mikkelsen on 26/04/2023.
//

import Foundation
import MapsIndoors
import MapsIndoorsCore

@objc(UtilsModule)
public class UtilsModule: NSObject {
    @objc public static func requiresMainQueueSetup() -> Bool { return false }

    @objc public func venueHasGraph(_ venueId: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        Task {
            guard let venue = await MPMapsIndoors.shared.venueWith(id: venueId) else {
                return reject("Utils error", "Venue not found for current Solution", MPError.unknownError)
            }

            return resolve(venue.hasGraph)
        }
    }

    @objc public func pointAngleBetween(_ point1: String, point2: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let it = try? JSONDecoder().decode(MPPoint.self, from: Data(point1.utf8)) as MPPoint else {
            return reject("Utils error", "Venue not found for current Solution", MPError.unknownError)
        }

        guard let other = try? JSONDecoder().decode(MPPoint.self, from: Data(point2.utf8)) as MPPoint else {
            return reject("Utils error", "Venue not found for current Solution", MPError.unknownError)
        }

        return resolve(MPGeometryUtils.bearingBetweenPoints(from: it.coordinate, to: other.coordinate))
    }

    @objc public func pointDistanceTo(_ point1: String, point2: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let it = try? JSONDecoder().decode(MPPoint.self, from: Data(point1.utf8)) as MPPoint else {
            return reject("Utils error", "Venue not found for current Solution", MPError.unknownError)
        }

        guard let other = try? JSONDecoder().decode(MPPoint.self, from: Data(point2.utf8)) as MPPoint else {
            return reject("Utils error", "Venue not found for current Solution", MPError.unknownError)
        }

        return resolve(MPGeometryUtils.distance(from: MPGeoPoint(coordinate: it.coordinate), to: MPGeoPoint(coordinate: other.coordinate)))
    }


    /// Decodes a GeoJSON geometry string into something queryable.
    ///
    /// `JSONDecoder().decode(MPGeometry.self, ...)` always produces a *base* `MPGeometry` - Swift's
    /// decoder is not polymorphic - so `geo is MPPolygonGeometry` and `geo as? MPPolygonGeometry`
    /// were always false here, and the SDK's `mp_polygon` / `mp_multiPolygon` accessors are an
    /// internal NSObject category holding associated objects that nothing sets on a freshly decoded
    /// value, so they were always nil. Every geometry helper in this file therefore fell through to
    /// its default branch: `geometryIsInside` always answered false, `geometryArea` always 0, and
    /// `polygonDistanceToClosestEdge` resolved nil.
    ///
    /// Decoding the concrete type by its GeoJSON `type` discriminator fixes all three, and mirrors
    /// how the Android module dispatches on `geometry.getType()`.
    private func decodeQueryableGeometry(_ geometry: String) -> (any MPGeometryQueryProtocol)? {
        let data = Data(geometry.utf8)

        guard let base = try? JSONDecoder().decode(MPGeometry.self, from: data) else {
            return nil
        }

        switch base.type {
        case "Polygon":
            return try? JSONDecoder().decode(MPPolygonGeometry.self, from: data)
        case "MultiPolygon":
            return try? JSONDecoder().decode(MPMultiPolygonGeometry.self, from: data)
        default:
            return nil
        }
    }

    @objc public func geometryIsInside(_ point: String, geometry: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let it = try? JSONDecoder().decode(MPPoint.self, from: Data(point.utf8)) as MPPoint else {
            return reject("Utils error", "Venue not found for current Solution", MPError.unknownError)
        }

        guard let geo = decodeQueryableGeometry(geometry) else {
            // Not a polygon or multi-polygon: nothing can be inside it.
            return resolve(false)
        }

        return resolve(geo.containsCoordinate(it.coordinate))
    }

    @objc public func geometryArea(_ geometry: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let geo = decodeQueryableGeometry(geometry) else {
            // A point or line has no area.
            return resolve(0)
        }

        return resolve(geo.area)
    }

    @objc public func polygonDistanceToClosestEdge(_ point: String, geometry: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let it = try? JSONDecoder().decode(MPPoint.self, from: Data(point.utf8)) as MPPoint else {
            return reject("Utils error", "Venue not found for current Solution", MPError.unknownError)
        }

        // Handles both Polygon and MultiPolygon, and lets the SDK do the maths. The hand-rolled
        // loop this replaces walked only the outer ring - ignoring holes - and indexed
        // `1..<outerRing.count`, which traps on an empty ring and yields
        // Double.greatestFiniteMagnitude for a single-coordinate ring.
        //
        // Like the Android module, this returns the *squared* distance.
        guard let geo = decodeQueryableGeometry(geometry) else {
            return reject(
                "Utils error",
                "Geometry is neither a Polygon nor a MultiPolygon, so it has no edges",
                MPError.unknownError
            )
        }

        // Both overloads behave identically here; use the MPPoint one, as the Android module does.
        // Note the SDK answers -1 for some geometry/point combinations even once the geometry
        // decodes correctly - that is an SDK-level question, not something this module can fix. What
        // matters here is that a number is resolved at all, honouring Promise<number>.
        return resolve(geo.squaredDistanceToClosestEdge(it))
    }

    @objc public func parseMapClientUrl(_ venueId: String, locationId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        return resolve(MPMapsIndoors.shared.solution?.getMapClientUrlFor(venueId: venueId, locationId: locationId))
    }

    @objc public func setCollisionHandling(_ collisionHandling: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let collision = MPCollisionHandling.init(rawValue: collisionHandling.intValue) else {
            return reject("Utils error", "Venue not found for current Solution", MPError.unknownError)
        }
        MPMapsIndoors.shared.solution?.config.collisionHandling = collision
        return resolve(nil)
    }

    @objc public func enableClustering(_ enableClustering: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        MPMapsIndoors.shared.solution?.config.enableClustering = enableClustering
        return resolve(nil)
    }

    @objc public func setExtrusionOpacity(_ opacity: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        MPMapsIndoors.shared.solution?.config.settings3D.extrusionOpacity = opacity
        return resolve(nil)
    }

    @objc public func setWallOpacity(_ opacity: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        MPMapsIndoors.shared.solution?.config.settings3D.wallOpacity = opacity
        return resolve(nil)
    }

    @objc public func setNewSelection(_ isNewSelection: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        MPMapsIndoors.shared.solution?.config.newSelection = isNewSelection
        return resolve(nil)
    }

    @objc public func setSelectable(_ settingsId: String, value: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if settingsId == "solution" {
            MPMapsIndoors.shared.solution?.config.locationSettings.selectable = value
        } else {
            if let location = MPMapsIndoors.shared.locationWith(locationId: settingsId) {
                if location.locationSettings == nil {
                    location.locationSettings = MPLocationSettings()
                }
                location.locationSettings?.selectable = value
            } else {
                if let type = MPMapsIndoors.shared.solution?.types.first(where: { $0.name == settingsId }) {
                    if type.locationSettings == nil {
                        type.locationSettings = MPLocationSettings()
                    }
                    type.locationSettings?.selectable = value
                }
            }
        }
        return resolve(nil)
    }

    @objc public func setAutomatedZoomLimit(_ value: Double, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if value == -1 {
            MPMapsIndoors.shared.solution?.config.automatedZoomLimit = nil
        } else {
            MPMapsIndoors.shared.solution?.config.automatedZoomLimit = value
        }
        return resolve(nil)
    }
}
