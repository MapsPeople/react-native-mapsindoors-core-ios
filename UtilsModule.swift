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
    @objc static func requiresMainQueueSetup() -> Bool { return false }
    
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
    
    @objc public func geometryIsInside(_ point: String, geometry: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let it = try? JSONDecoder().decode(MPPoint.self, from: Data(point.utf8)) as MPPoint else {
            return reject("Utils error", "Venue not found for current Solution", MPError.unknownError)
        }
        
        guard let geo = try? JSONDecoder().decode(MPGeometry.self, from: Data(geometry.utf8)) as MPGeometry else {
            return reject("Utils error", "Venue not found for current Solution", MPError.unknownError)
        }
        
        if (geo is MPPolygonGeometry) {
            let poly = geo.mp_polygon
            return resolve(poly?.containsCoordinate(it.coordinate))
        }else if (geo is MPMultiPolygonGeometry) {
            let multiPoly = geo.mp_multiPolygon
            resolve(multiPoly?.containsCoordinate(it.coordinate))
        }else {
            resolve(false)
        }
    }
    
    @objc public func geometryArea(_ geometry: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        
        guard let geo = try? JSONDecoder().decode(MPGeometry.self, from: Data(geometry.utf8)) as MPGeometry else {
            return reject("Utils error", "Venue not found for current Solution", MPError.unknownError)
        }
        
        if (geo is MPPolygonGeometry) {
            let poly = geo.mp_polygon
            return resolve(poly?.area)
        }else if (geo is MPMultiPolygonGeometry) {
            let multiPoly = geo.mp_multiPolygon
            return resolve(multiPoly?.area)
        }else {
            return resolve(0)
        }
    }
    
    @objc public func polygonDistanceToClosestEdge(_ point: String, geometry: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        
        guard let it = try? JSONDecoder().decode(MPPoint.self, from: Data(point.utf8)) as MPPoint else {
            return reject("Utils error", "Venue not found for current Solution", MPError.unknownError)
        }
        
        guard let geo = try? JSONDecoder().decode(MPGeometry.self, from: Data(geometry.utf8)) as MPGeometry else {
            return reject("Utils error", "Venue not found for current Solution", MPError.unknownError)
        }
        
        if(geo is MPPolygonGeometry){
            
            guard let outerRing = (geo.mp_polygon.coordinates.first?.map {CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)}) else {
                return reject("Utils error", "Venue not found for current Solution", MPError.unknownError)
            }
            
            var shortestDistance = Double.greatestFiniteMagnitude
            for i in 1 ..< outerRing.count {
                let p1 = outerRing[i-1]
                let p2 = outerRing[i]
                
                let distanceToLine = MPGeometryUtils.distancePointToLine(point: it.coordinate, lineStart: p1, lineEnd: p2)
                if( distanceToLine < shortestDistance) {
                    shortestDistance = distanceToLine
                }
            }
            
            return resolve(shortestDistance)
        }
        return resolve(nil)
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
}
