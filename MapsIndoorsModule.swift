import Foundation
import MapsIndoors
import MapsIndoorsCodable
import MapsIndoorsCore
import React

@objc(MapsIndoorsModule)
public class MapsIndoorsModule: RCTEventEmitter {
    @objc public override static func requiresMainQueueSetup() -> Bool { return false }

    /// Base override for RCTEventEmitter.
    ///
    /// - Returns: all supported events
    @objc open override func supportedEvents() -> [String] {
        return MapsIndoorsData.sharedInstance.allEvents
    }

    /// Whether JavaScript currently has a listener attached to this emitter.
    ///
    /// Base-map cache progress is only emitted while this is true: `synchronizeBaseMapTiles` is
    /// callable without a progress listener, and RCTEventEmitter logs a warning for every event sent
    /// with nothing listening.
    private var hasListeners = false

    public override func startObserving() { hasListeners = true }

    public override func stopObserving() { hasListeners = false }

    @objc public func test() {
        print("%@.test()", String(describing: self))
    }

    private var positionProvider: ReactPositionProvider?

    /// Keeps the `cacheData` delegate alive while a dataset sync runs - see the note in `cacheData`.
    private var datasetDelegate: DatasetDelegate?

    @objc(loadMapsIndoors:optionalStrings:resolver:rejecter:)
    func loadMapsIndoors(apiKey: String, optionalStrings: [String]?, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        Task {
            do {
                if optionalStrings != nil {
                    try await MPMapsIndoors.shared.load(apiKey: apiKey, venueIds: optionalStrings!)
                } else {
                    try await MPMapsIndoors.shared.load(apiKey: apiKey)
                }
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

            return resolve(
                toJSON(
                    venues.map {
                        MPVenueCodable(withVenue: $0)
                    }))
        }
    }

    @objc public func getBuildings(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        Task {
            let buildings = await MPMapsIndoors.shared.buildings()

            return resolve(
                toJSON(
                    buildings.map {
                        MPBuildingCodable(withBuilding: $0)
                    }))
        }
    }

    @objc public func getCategories(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        Task {
            let categories = await MPMapsIndoors.shared.categories()

            return resolve(
                toJSON(
                    categories.map {
                        MPDataFieldCodable(withDataField: $0)
                    }))
        }
    }

    @objc public func getLocations(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        Task {
            let locations = await MPMapsIndoors.shared.locationsWith(query: MPQuery(), filter: MPFilter())
            return resolve(
                toJSON(
                    locations.map {
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
            return doReject(reject, message: "getAvailableLanguages: solution is not available. Try loading first")
        }
    }

    @objc public func getDefaultLanguage(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if let solution = MPMapsIndoors.shared.solution {
            let defaultLanguage = solution.defaultLanguage
            return resolve(defaultLanguage)
        } else {
            return doReject(reject, message: "getDefaultLanguage: solution is not available. Try loading first")
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
        guard let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() else {
            return doReject(reject, message: "getMapStyles: Must create MapControl first")
        }
        guard let venue = mapControl.currentVenue else {
            return doReject(reject, message: "getMapStyles: No current venue")
        }
        guard let styles = venue.styles else {
            return doReject(reject, message: "getMapStyles: Got no styles")
        }

        let mapStyles = styles.map({ MPMapStyleCodable(withMapStyle: $0) })
        return resolve(toJSON(mapStyles))
    }

    @objc public func getSolution(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if let solution = MPMapsIndoors.shared.solution {
            return resolve(toJSON(MPSolutionCodable(withSolution: solution)))
        } else {
            return doReject(reject, message: "getSolution: solution is not available. Try loading first")
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
            if MPMapsIndoors.shared.displayRuleFor(location: location) != nil {
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
        MPMapsIndoors.shared.positionProvider = positionProvider

        return resolve(nil)
    }

    @objc public func removePositionProvider(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        positionProvider = nil
        MPMapsIndoors.shared.positionProvider = nil

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
                return doReject(reject, message: "getDefaultVenue: no venues exist. Make sure MapsIndoors is ready")
            }
            return resolve(toJSON(MPVenueCodable(withVenue: defaultVenue)))
        }
    }

    @objc public func checkOfflineDataAvailability(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        Task {
            guard let key = MPMapsIndoors.shared.apiKey else {
                return doReject(reject, message: "checkOfflineDataAvailability: API key not set")
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

    /// Sets the SDK language and reports whether the write was accepted.
    ///
    /// `MILanguage.setLanguage` and the `MPMapsIndoors.shared.language` setter it replaces here
    /// reach the same storage: the setter routes through `MapsIndoorsLegacy.setLanguage` to
    /// `MILanguage.language`, which is the same provider property `setLanguage` assigns after
    /// normalizing the tag. Same UserDefaults write, same `MILanguage` change notification, same
    /// `languageChanged` log event - the only new thing is the return value, which a property
    /// setter had no way to surface. JavaScript has always declared `Promise<boolean>` here and
    /// always received `null`.
    @objc public func setLanguage(_ language: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        return resolve(MILanguage.setLanguage(language))
    }

    @objc public func synchronizeContent(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        Task {
            do {
                try await MPMapsIndoors.shared.synchronize()
                return resolve(nil)
            } catch let e {
                return doReject(reject, error: e)
            }
        }
    }

    @objc(addVenuesToSync:resolver:rejecter:)
    func addVenuesToSync(venues: [String], resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        Task {
            do {
                try await MPMapsIndoors.shared.addVenuesToSync(venueIds: venues)
                return resolve(nil)
            } catch let e {
                return doReject(reject, error: e)
            }
        }
    }

    @objc(removeVenuesToSync:resolver:rejecter:)
    func removeVenuesToSync(venues: [String], resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        Task {
            do {
                try await MPMapsIndoors.shared.removeVenuesToSync(venueIds: venues)
                return resolve(nil)
            } catch let e {
                return doReject(reject, error: e)
            }
        }
    }

    @objc(getSyncedVenues:rejecter:)
    func getSyncedVenues(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        return resolve(MPMapsIndoors.shared.venuesToSync)
    }

    @objc public func cacheData(_ apiKey: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let datasetCacheManager = MPMapsIndoors.shared.datasetCacheManager
        var dataSet = datasetCacheManager.dataSetWithId(apiKey)
        if dataSet == nil {
            dataSet = datasetCacheManager.addDataSet(apiKey, cachingScope: .full)
        }
        guard let dataSet else {
            return resolve(false)
        }

        // Rejected rather than queued or run alongside. The manager's delegate is a single slot, so a
        // second call overwrote it, deallocated the first delegate - the slot is `weak` - and stranded
        // the first promise forever: the same silent hang this delegate exists to fix, narrowed from
        // always to on overlap. Holding the slot until the running call settles also keeps that call's
        // completion from nilling a later call's delegate.
        guard datasetDelegate == nil else {
            return doReject(reject, message: "A cacheData call is already running; wait for it to finish before starting another")
        }

        // Held by the module for the length of the sync. MPDataSetCacheManager.delegate is `weak`, so a
        // delegate constructed inline in this statement is deallocated before the download it is waiting
        // on can finish - the callback never arrives and the promise never settles, leaving the caller
        // waiting forever with no error (SPEX-2481).
        let delegate = DatasetDelegate(dataset: dataSet.cacheItem) { [weak self] success in
            self?.datasetDelegate = nil
            resolve(success)
        }
        datasetDelegate = delegate
        datasetCacheManager.delegate = delegate

        datasetCacheManager.synchronizeCacheItems([dataSet.cacheItem])
    }

    @objc(isBaseMapCachingSupported:rejecter:)
    func isBaseMapCachingSupported(resolve: RCTPromiseResolveBlock, reject _: RCTPromiseRejectBlock) {
        // Answered from which provider this package is built against, not from the SDK: the provider
        // seam that knows is SPI, and the SDK only registers an implementation once a map provider has
        // been constructed - so asking it would report false before the first map view exists, which is
        // exactly when an app wants to decide whether to offer offline base maps at all.
        //
        // The module is MapsIndoorsMapbox; the *pod* is MapsIndoorsMapbox11. canImport takes the module
        // name, and naming the pod here silently compiles to the unsupported branch on every build -
        // which is what a `#if` gets you when it is wrong. MapsIndoorsViewManager.swift in the Mapbox
        // package imports this same name.
        #if canImport(MapsIndoorsMapbox)
            return resolve(true)
        #else
            return resolve(false)
        #endif
    }

    @objc(setBaseMapTilesEnabled:apiKey:resolver:rejecter:)
    func setBaseMapTilesEnabled(enabled: Bool, apiKey: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        let datasetCacheManager = MPMapsIndoors.shared.datasetCacheManager

        if let dataSet = datasetCacheManager.dataSetWithId(apiKey) {
            datasetCacheManager.setBaseMapTilesEnabled(enabled, cacheItem: dataSet.cacheItem)
        } else if datasetCacheManager.addDataSet(apiKey, cachingScope: .full, baseMapTilesEnabled: enabled) == nil {
            // Managed from here on with the same `.full` scope cacheData uses: there is nothing to flag
            // otherwise, and base-map caching needs the dataset's venues to know what to cache around.
            return doReject(reject, message: "Unable to manage dataset '\(apiKey)'")
        }

        return resolve(nil)
    }

    @objc(synchronizeBaseMapTiles:resolver:rejecter:)
    func synchronizeBaseMapTiles(apiKeys: [String]?, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        let datasetCacheManager = MPMapsIndoors.shared.datasetCacheManager
        var dataSets = [MPDataSetCache]()

        if let apiKeys {
            for apiKey in apiKeys {
                guard let dataSet = datasetCacheManager.dataSetWithId(apiKey) else {
                    // Rejected rather than skipped: an explicit list is an explicit instruction, and
                    // silently caching nothing for a key the caller named is the harder failure to spot.
                    return doReject(reject, message: "No dataset is managed for '\(apiKey)', so base-map tiles cannot be cached for it")
                }

                dataSets.append(dataSet)
            }
        }

        let progress: @Sendable (Double) -> Void = { [weak self] fraction in
            guard let self, self.hasListeners else { return }
            self.sendEvent(withName: MapsIndoorsData.Event.onBaseMapCacheProgress.rawValue, body: ["progress": fraction])
        }

        Task {
            do {
                if apiKeys == nil {
                    try await datasetCacheManager.synchronizeBaseMapTiles(progress: progress)
                } else {
                    try await datasetCacheManager.synchronizeBaseMapTiles(dataSets, progress: progress)
                }
                return resolve(nil)
            } catch let e {
                return doRejectBaseMapCache(reject, error: e)
            }
        }
    }
}

/// Rejects a base-map caching call, preserving the one error code the React Native API documents.
///
/// 9000 is the third copy of that value: Android's `MIError.BASEMAP_CACHE_NOT_SUPPORTED`, this
/// literal, and core's `MPError.baseMapCachingNotSupported` in TypeScript. Nothing links them, so a
/// change to one has to be made to all three.
///
/// The shared `doReject` reports everything as `unknownError`, which would leave JavaScript unable to
/// tell "this map provider cannot cache base-map tiles" - the expected outcome on a Google Maps build,
/// and the one an app should handle - apart from a download that failed. The code matches the Android
/// SDK's `MIError.BASEMAP_CACHE_NOT_SUPPORTED`, so one check in JavaScript works on both platforms.
private func doRejectBaseMapCache(_ reject: RCTPromiseRejectBlock, error: Error) {
    guard let mpError = error as? MPError, mpError == .baseMapCachingNotSupported else {
        return doReject(reject, error: error)
    }

    struct BaseMapCacheError: Codable {
        let code: Int
        let message: String
    }

    let err = BaseMapCacheError(code: 9000, message: String(describing: mpError))

    return reject("NativeError", toJSON(err), error)
}

class DatasetDelegate: NSObject, MPDataSetCacheManagerDelegate {
    private let dataset: MPDataSetCacheItem
    private let completion: (Bool) -> Void
    private var hasCompleted = false

    init(dataset: MPDataSetCacheItem, completion: @escaping (Bool) -> Void) {
        self.dataset = dataset
        self.completion = completion
    }

    func dataSetManager(_ dataSetManager: MPDataSetCacheManager, didFinishSynchronizingItem item: MPDataSetCacheItem) {
        // Only this dataset settles the promise. Any other item finishing first used to resolve it
        // `false` and then let this one resolve it a second time.
        guard item.cachingItemId == dataset.cachingItemId else { return }

        settle(success: item.syncResult == nil)
    }

    func dataSetManagerDidFinishSynchronizing(_ dataSetManager: MPDataSetCacheManager) {
        // Backstop. didFinishSynchronizingItem is the precise signal, but nothing guarantees it fires
        // for this item, and this whole class exists because a promise hung silently when its callback
        // never arrived. The manager-level completion settles anything still outstanding, so that
        // failure mode cannot recur in a different shape.
        settle(success: dataset.syncResult == nil)
    }

    private func settle(success: Bool) {
        guard !hasCompleted else { return }

        hasCompleted = true
        // The manager reports a failed sync on the item rather than through a separate callback, so
        // without this a failure would resolve `true` exactly like a success.
        completion(success)
    }
}
