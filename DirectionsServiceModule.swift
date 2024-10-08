//
//  DirectionsServiceModule.swift
//  react-native-maps-indoors
//
//  Created by Tim Mikkelsen on 02/05/2023.
//

import MapsIndoors
import MapsIndoorsCore
import MapsIndoorsCodable

@objc(DirectionsService)
public class DirectionsServiceModule: NSObject {
    
    var directionsVariables = [String: DirectionsVariables]()
    
    @objc static func requiresMainQueueSetup() -> Bool { return false }
    
    @objc func create(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        let uuid = UUID().uuidString
        let directionsVars = DirectionsVariables()
        directionsVariables[uuid] = directionsVars
        return resolve(uuid)
    }
    
    @objc func addAvoidWayType(_ wayType: String, id: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let directionsVars = directionsVariables[id] else {
            return doReject(reject, message: "directions service not found. Did you call create")
        }
        
        guard let avoidWayType = MPHighway(typeString: wayType) as? MPHighway else {
            return doReject(reject, message: "WayType not found")
        }
        
        directionsVars.wayTypes.append(avoidWayType)
    }
    
    @objc func clearWayType(_ id: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let directionsVars = directionsVariables[id] else {
            return doReject(reject, message: "directions service not found. Did you call create")
        }
        
        directionsVars.wayTypes.removeAll()
    }
    
    @objc func addExcludeWayType(_ wayType: String, id: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let directionsVars = directionsVariables[id] else {
            return doReject(reject, message: "directions service not found. Did you call create")
        }
        
        guard let excludeWayType = MPHighway(typeString: wayType) as? MPHighway else {
            return doReject(reject, message: "WayType not found")
        }
        
        directionsVars.excludeWayTypes.append(excludeWayType)
    }
    
    @objc func clearExcludeWayType(_ id: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let directionsVars = directionsVariables[id] else {
            return doReject(reject, message: "directions service not found. Did you call create")
        }
        
        directionsVars.excludeWayTypes.removeAll()
    }
    
    @objc func getRoute(_ originString: String, destinationString: String, stopsString: [String]?, optimize: Bool, id: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        
        guard let directionsVars = directionsVariables[id] else {
            return doReject(reject, message: "directions service not found. Did you call create")
        }
        
        var origin: MPPoint? = nil
        var destination: MPPoint? = nil
        var stops: [MPPoint]? = nil
        
        do {
            origin = try JSONDecoder().decode(MPPoint.self, from: Data(originString.utf8))
            destination = try JSONDecoder().decode(MPPoint.self, from: Data(destinationString.utf8))
            if (stopsString != nil) {
                stops = try stopsString!.map({
                    try JSONDecoder().decode(MPPoint.self, from: Data($0.utf8))
                })
            }
        } catch {
            return doReject(reject, message: "Unable to parse origin or destination point")
        }
        
        if (origin != nil && destination != nil) {
            let query = MPDirectionsQuery(originPoint: origin!, destinationPoint: destination!)
            if (!directionsVars.wayTypes.isEmpty) {
                query.avoidWayTypes = directionsVars.wayTypes
            }
            
            query.stopsPoints = stops

            if(!directionsVars.excludeWayTypes.isEmpty) {
                query.excludeWayTypes = directionsVars.excludeWayTypes
            }
            
            if (directionsVars.date != nil) {
                if (directionsVars.isDeparture) {
                    query.departure = directionsVars.date
                }else {
                    query.arrival = directionsVars.date
                }
            }

            query.optimizeRoute = optimize
            
            query.travelMode = directionsVars.travelMode
            
            Task {
                do {
                    if let route = try await MPMapsIndoors.shared.directionsService.routingWith(query: query) {
                        if let routeData = try? JSONEncoder().encode(route as? MPRouteInternal) {
                            let routeRoute = String(data: routeData, encoding: String.Encoding.utf8)
                            var map = Dictionary<String, String>()
                            map["route"] = routeRoute
                            map["error"] = "null"
                            return resolve(map)
                        } else {
                            return doReject(reject, message: "Route could not be parsed")
                        }
                    } else {
                        return resolve(nil)
                    }
                } catch {
                    return doReject(reject, message: (error as? MPError)?.description ?? error.localizedDescription)
                }
            }
        }
        else {
            return doReject(reject, message: "Origin or Destination was null")

        }
    }
    
    @objc func setTravelMode(_ travelMode: String, id: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        
        guard let directionsVars = directionsVariables[id] else {
            return doReject(reject, message: "directions service not found. Did you call create")
        }
        
        var mpTravelMode: MPTravelMode? = nil
        
        switch(travelMode) {
        case "walking":     mpTravelMode = MPTravelMode.walking;
        case "bicycling":   mpTravelMode = MPTravelMode.bicycling;
        case "driving":     mpTravelMode = MPTravelMode.driving;
        case "transit":     mpTravelMode = MPTravelMode.transit;
        default:
            return doReject(reject, message: "Travel mode not found")
        }
        
        directionsVars.travelMode = mpTravelMode!
        resolve(nil)
    }
    
    @objc func setTime(_ time: NSNumber, id: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        
        guard let directionsVars = directionsVariables[id] else {
            return doReject(reject, message: "directions service not found. Did you call create")
        }
        
        directionsVars.date = Date(timeIntervalSince1970: TimeInterval(time.intValue/1000))
        resolve(nil)
    }
    
    @objc func setIsDeparture(_ isDeparture: Bool, id: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        
        guard let directionsVars = directionsVariables[id] else {
            return doReject(reject, message: "directions service not found. Did you call create")
        }
        
        directionsVars.isDeparture = isDeparture
        resolve(nil)
    }
}

public class DirectionsVariables {
    var wayTypes: [MPHighway] = []
    var isDeparture: Bool = true
    var travelMode: MPTravelMode = MPTravelMode.walking
    var date: Date? = nil
    var excludeWayTypes: [MPHighway] = []
}
