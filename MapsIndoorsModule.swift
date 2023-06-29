import Foundation
import MapsIndoors
import MapsIndoorsCore
import MapsIndoorsCodable

import React

@objc(MapsIndoorsModule)
public class MapsIndoorsModule: NSObject {
    @objc static func requiresMainQueueSetup() -> Bool { return false }

    @objc public func test() {
        print("%@.test()", String(describing: self));
    }

    private var positionProvider: ReactPositionProvider?

    @objc
    public func loadMapsIndoors(_ apiKey: String,
                                resolver resolve: @escaping RCTPromiseResolveBlock,
                                rejecter reject: @escaping RCTPromiseRejectBlock)
    {
        Task {
            do {
                try await MPMapsIndoors.shared.load(apiKey: apiKey)
                MapsIndoorsData.sharedInstance.isInitialized = true
                return resolve([])
            } catch let e /*as MPError*/ {
                return doReject(reject, error: e)
            }
        }
    }

    @objc public func getVenues(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        Task {
            let venues = await MPMapsIndoors.shared.venues()

            return resolve(toJSON(venues.map {
                MPVenueCodable(withVenue: $0)
            }))
        }
    }

    @objc public func getBuildings(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        Task {
            let buildings = await MPMapsIndoors.shared.buildings()

            return resolve(toJSON(buildings.map {
                MPBuildingCodable(withBuilding: $0)
            }))
        }
    }

    @objc public func getCategories(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        Task {
            let categories = await MPMapsIndoors.shared.categories()

            return resolve(toJSON(categories.map {
                MPDataFieldCodable(withDataField: $0)
            }))
        }
    }

    @objc public func getLocations(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        Task {
            let locations = await MPMapsIndoors.shared.locationsWith(query: MPQuery(), filter: MPFilter())
            return resolve(toJSON(locations.map {
                MPLocationCodable(withLocation: $0)
            }))
        }
    }

    @objc public func disableEventLogging(_ disable: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        MPMapsIndoors.shared.eventLoggingDisabled = disable
        return resolve(nil)
    }

    @objc public func getApiKey(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        let apiKey = MPMapsIndoors.shared.apiKey
        return resolve(apiKey)
    }

    @objc public func getAvailableLanguages(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if let solution = MPMapsIndoors.shared.solution {
            let languages = solution.availableLanguages
            return resolve(languages)
        } else {
            reject("1", "getAvailableLanguages: solution is not available. Try loading first", nil)
        }
    }

    @objc public func getDefaultLanguage(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if let solution = MPMapsIndoors.shared.solution {
            let defaultLanguage = solution.defaultLanguage
            return resolve(defaultLanguage)
        } else {
            reject("1", "getDefaultLanguage: solution is not available. Try loading first", nil)
        }
    }

    @objc public func getLanguage(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        let language = MPMapsIndoors.shared.language
        return resolve(language)
    }

    @objc public func getLocationById(_ id: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if let location = MPMapsIndoors.shared.locationWith(locationId: id) {
            return resolve(toJSON(MPLocationCodable(withLocation: location)))
        } else {
            return reject("1", "Could not find location with id \(id)", nil)
        }
    }

    @objc public func getLocationsByExternalIds(_ ids: [String], resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        let locs = MPMapsIndoors.shared.locationsWith(externalIds: ids)
        let locations = locs.map({
            MPLocationCodable(withLocation: $0)
        })
        return resolve(toJSON(locations))
    }

    @objc public func getMapStyles(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        guard let mapControl = MapsIndoorsData.sharedInstance.mapControl else {
            return doReject(reject, message: "getMapStyles: Must create MapControl first")
        }
        guard let venue = mapControl.currentVenue else {
            return doReject(reject, message: "getMapStyles: No current venue")
        }
        guard let styles = venue.styles else {
            return doReject(reject, message: "getMapStyles: Got no styles")
        }

        let mapStyles = styles.map({ MPMapStyleCodable(withMapStyle:$0) })
        return resolve(toJSON(mapStyles))
    }

    @objc public func getSolution(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if let solution = MPMapsIndoors.shared.solution {
            return resolve(toJSON(MPSolutionCodable(withSolution: solution)))
        } else {
            return reject("1", "getSolution: solution is not available. Try loading first", nil)
        }
    }

    @objc public func getLocationsAsync(_ query: String, filter: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {

        Task {
            do {
                let locs = await MPMapsIndoors.shared.locationsWith(query: try fromJSON(query), filter: try fromJSON(filter))
                let locations = locs.map({
                    MPLocationCodable(withLocation: $0)
                })
                return resolve(toJSON(locations))
            } catch let e {
                return doReject(reject, error: e)
            }
        }
    }

    @objc public func locationDisplayRuleExists(_ locId: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if let location = MPMapsIndoors.shared.locationWith(locationId: locId) {
            if let _ = MPMapsIndoors.shared.displayRuleFor(location: location) {
                return resolve(true)
            } else {
                return resolve(false)
            }
        } else {
            return reject("1", "locationDisplayRuleExists: no location with id \(locId)", nil)
        }
    }

    @objc public func displayRuleNameExists(_ name: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        let exists: Bool = MPMapsIndoors.shared.displayRuleFor(type: name.lowercased()) != nil
        return resolve(exists)
    }

    @objc public func setPositionProvider(_ name: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        let provider = ReactPositionProvider()
        provider.name = name

        positionProvider = provider
        MapsIndoorsData.sharedInstance.mapControl?.positionProvider = positionProvider

        return resolve(nil)
    }

    @objc public func removePositionProvider(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        positionProvider = nil
        MapsIndoorsData.sharedInstance.mapControl?.positionProvider = nil

        return resolve(nil)
    }

    @objc public func onPositionUpdate(_ positionJSON: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        do {
            let positionResult: MPPositionResult = try fromJSON(positionJSON)

            positionProvider?.setLatestPosition(positionResult: positionResult)

            return resolve(nil)
        } catch let e {
            return doReject(reject, error: e)
        }
    }

    @objc public func getUserRoles(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        let allUserRoles = MPMapsIndoors.shared.availableUserRoles
        return resolve(toJSON(allUserRoles))
    }

    @objc public func applyUserRoles(_ userRolesJSON: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        do {
            let userRoles: [MPUserRole] = try fromJSON(userRolesJSON)
            MPMapsIndoors.shared.userRoles = userRoles
            return resolve(nil)
        } catch let e {
            return doReject(reject, error: e)
        }
    }

    @objc public func getAppliedUserRoles(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        let appliedUserRoles = MPMapsIndoors.shared.userRoles
        return resolve(toJSON(appliedUserRoles))
    }

    @objc public func isApiKeyValid(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        Task {
            if let apiKey = MPMapsIndoors.shared.apiKey {
                return resolve(
                    await MPMapsIndoors.shared.isApiKeyValid(apiKey: apiKey)
                )
            } else {
                reject("1", "isApiKeyValid: API key not set", nil)
            }
        }
    }

    @objc public func isReady(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {

        return resolve(MPMapsIndoors.shared.ready)
    }
    
    @objc public func getDefaultVenue(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        Task {
            guard let defaultVenue = await MPMapsIndoors.shared.venues().first else {
                return reject("1", "no venues exist. Make sure MapsIndoors is ready", nil)
            }
            return resolve(toJSON(MPVenueCodable(withVenue: defaultVenue)))
        }
    }
    
    @objc public func checkOfflineDataAvailability(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        Task {
            guard let key = MPMapsIndoors.shared.apiKey else {
                return reject("1", "isApiKeyValid: API key not set", nil)
            }
            
            return resolve(await MPMapsIndoors.shared.isOfflineDataAvailable(apiKey: key))
        }
    }
    
    @objc public func destroy(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        Task {
            MPMapsIndoors.shared.shutdown()
            MapsIndoorsData.sharedInstance.isInitialized = false
            return resolve(nil)
        }
    }
    
    @objc public func isInitialized(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        return resolve(MapsIndoorsData.sharedInstance.isInitialized)
    }
    
    @objc public func setLanguage(_ language: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        
        MPMapsIndoors.shared.language = language
        return resolve(nil)
    }
    
    @objc public func synchronizeContent(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        Task {
            do {
                try await MPMapsIndoors.shared.synchronize()
                return resolve(nil)
            }
            catch let e {
                return doReject(reject, error: e)
            }
        }
    }

}
