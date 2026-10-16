//
//  DirectionsRendererModule.swift
//  react-native-maps-indoors
//
//  Created by Tim Mikkelsen on 01/05/2023.
//

import MapsIndoors
import MapsIndoorsCodable
import MapsIndoorsCore
import React

@objc(DirectionsRenderer)
public class DirectionsRendererModule: RCTEventEmitter {
    private var isListeningForLegChanges: Bool = false
    private var animationDuration: NSNumber = 5
    /// The custom stamp URL last applied through ``setOptions``.
    ///
    /// The SDK stores the downloaded `UIImage`, not its URL, so ``getOptions`` cannot recover it from
    /// the renderer. Without it a read-modify-write of the options would feed back a `custom` stamp
    /// type with no image and silently drop the stamp.
    ///
    /// Only ever touched on the main actor - written at the end of ``setOptions``, read in
    /// ``getOptions`` - since React Native invokes this module off the main queue
    /// (``requiresMainQueueSetup()`` is `false`) and both would otherwise race.
    @MainActor private var appliedStampImageUrl: String?

    /// Orders ``setOptions`` calls, which download a custom stamp before applying.
    private let optionsGeneration = CallGeneration()

    /// Orders the calls that replace the route: ``setRoute``, which may download URL stop icons
    /// first, and ``clear``. Without it a slow download would draw its route over a later call's.
    private let routeGeneration = CallGeneration()

    /// Orders ``setDefaultRouteStopIcon`` calls, which may download the icon first.
    private let defaultStopIconGeneration = CallGeneration()

    @objc public override static func requiresMainQueueSetup() -> Bool { return false }

    /// Base overide for RCTEventEmitter.
    ///
    /// - Returns: all supported events
    @objc open override func supportedEvents() -> [String] {
        return MapsIndoorsData.sharedInstance.allEvents
    }

    /// The directions renderer, created from the map control on first use.
    ///
    /// Main-actor only: creating the renderer goes through the map control, and the renderer itself is
    /// main-actor isolated in the SDK, so every method below reaches it from inside ``onMainThread``.
    @MainActor private func currentDirectionsRenderer() -> MPDirectionsRenderer? {
        let data = MapsIndoorsData.sharedInstance
        if data.directionsRenderer == nil {
            data.directionsRenderer = data.mapView?.getMapControl()?.newDirectionsRenderer()
        }
        return data.directionsRenderer
    }

    /// Applies the map's padding to the renderer, so the route is framed inside the visible map.
    @MainActor private func applyMapPadding(to directionsRenderer: MPDirectionsRenderer) {
        if let mapControl = MapsIndoorsData.sharedInstance.mapView?.getMapControl() {
            directionsRenderer.padding = mapControl.mapPadding
        }
    }

    private static let noRendererMessage = "directions renderer null. MapControl needs to have been instantiated first"

    @objc public func clear(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        // Supersedes any setRoute still downloading its icons, so that route is not drawn afterwards.
        _ = routeGeneration.next()

        onMainThread {
            let isNewRenderer = MapsIndoorsData.sharedInstance.directionsRenderer == nil
            guard let directionsRenderer = self.currentDirectionsRenderer() else {
                return doReject(reject, message: Self.noRendererMessage)
            }
            if isNewRenderer {
                self.animationDuration = 5
            }

            directionsRenderer.clear()
            directionsRenderer.route = nil
            resolve(nil)
        }
    }

    @objc public func getSelectedLegFloorIndex(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        onMainThread {
            guard let directionsRenderer = self.currentDirectionsRenderer() else {
                return doReject(reject, message: Self.noRendererMessage)
            }

            self.applyMapPadding(to: directionsRenderer)

            guard let legIndex = directionsRenderer.route?.legs[directionsRenderer.routeLegIndex].end_location.zLevel.int32Value else {
                return doReject(reject, message: "No current floor available")
            }

            resolve(legIndex)
        }
    }

    @objc public func nextLeg(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        onMainThread {
            guard let directionsRenderer = self.currentDirectionsRenderer() else {
                return doReject(reject, message: Self.noRendererMessage)
            }

            self.applyMapPadding(to: directionsRenderer)

            if directionsRenderer.nextLeg() {
                directionsRenderer.animate(duration: self.animationDuration.doubleValue)
                if self.isListeningForLegChanges {
                    self.sendEvent(withName: MapsIndoorsData.Event.onLegSelected.rawValue, body: ["leg": directionsRenderer.routeLegIndex])
                }
            }
            resolve(nil)
        }
    }

    @objc public func previousLeg(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        onMainThread {
            guard let directionsRenderer = self.currentDirectionsRenderer() else {
                return doReject(reject, message: Self.noRendererMessage)
            }

            self.applyMapPadding(to: directionsRenderer)

            if directionsRenderer.previousLeg() {
                directionsRenderer.animate(duration: self.animationDuration.doubleValue)
                if self.isListeningForLegChanges {
                    self.sendEvent(withName: MapsIndoorsData.Event.onLegSelected.rawValue, body: ["leg": directionsRenderer.routeLegIndex])
                }
            }
            resolve(nil)
        }
    }

    @objc public func selectLegIndex(_ legIndex: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        onMainThread {
            guard let directionsRenderer = self.currentDirectionsRenderer() else {
                return doReject(reject, message: Self.noRendererMessage)
            }

            guard let route = directionsRenderer.route else {
                return doReject(reject, message: "No route is set")
            }

            guard legIndex.intValue >= 0 else {
                return doReject(reject, message: "Tried to select negative route leg index \(legIndex.intValue)")
            }

            guard legIndex.intValue < (route.legs.count) else {
                return doReject(reject, message: "Tried to select route leg index \(legIndex.intValue) outside of range 0..\((route.legs.count)-1)")
            }

            self.applyMapPadding(to: directionsRenderer)

            directionsRenderer.routeLegIndex = legIndex.intValue
            directionsRenderer.animate(duration: self.animationDuration.doubleValue)

            if self.isListeningForLegChanges {
                self.sendEvent(withName: MapsIndoorsData.Event.onLegSelected.rawValue, body: ["leg": directionsRenderer.routeLegIndex])
            }
            resolve(nil)
        }
    }

    @objc public func setAnimatedPolyline(_ animated: Bool, repeated: Bool, duration: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        onMainThread {
            guard self.currentDirectionsRenderer() != nil else {
                return doReject(reject, message: Self.noRendererMessage)
            }

            self.animationDuration = animated ? duration : 0
            resolve(nil)
        }
    }

    @objc public func showRouteLegButtons(_ value: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        onMainThread {
            guard let directionsRenderer = self.currentDirectionsRenderer() else {
                return doReject(reject, message: Self.noRendererMessage)
            }

            directionsRenderer.showRouteLegButtons = value
            resolve(nil)
        }
    }

    @objc public func setCameraAnimationDuration(_ duration: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        onMainThread {
            guard self.currentDirectionsRenderer() != nil else {
                return doReject(reject, message: Self.noRendererMessage)
            }

            self.animationDuration = duration
            resolve(nil)
        }
    }

    @objc public func setCameraViewFitMode(_ cameraFitMode: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let camFitMode: MPCameraViewFitMode
        switch cameraFitMode {
        case 0:
            camFitMode = .northAligned
        case 1:
            camFitMode = .firstStepAligned
        case 2:
            camFitMode = .startToEndAligned
        case 3:
            camFitMode = .none
        default:
            camFitMode = .northAligned
        }

        onMainThread {
            guard let directionsRenderer = self.currentDirectionsRenderer() else {
                return doReject(reject, message: Self.noRendererMessage)
            }

            directionsRenderer.fitMode = camFitMode
            resolve(nil)
        }
    }

    @objc public func setDefaultRouteStopIcon(_ defaultIcon: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        // Only a URL icon needs work before it can be applied: it is downloaded first, and a failed
        // download rejects instead of leaving the promise unsettled. Either way the renderer is reached
        // on the main thread, and looked up there at the moment of applying.
        let generation = defaultStopIconGeneration.next()

        if isValidUrl(defaultIcon) {
            Task {
                do {
                    let icon = IconStopUrl(image: try await self.downloadImage(from: URL(string: defaultIcon)!))
                    onMainThread { self.applyDefaultRouteStopIcon(icon, generation: generation, resolve, reject) }
                } catch {
                    doReject(reject, error: error)
                }
            }
            return
        }

        var icon: MPRouteStopIconProvider? = nil
        do {
            var deficon = defaultIcon
            deficon.removeLast()
            icon = try JSONDecoder().decode(RouteIcon.self, from: deficon.data(using: .utf8)!).getIcon()
        } catch {
            // Unchanged behaviour: an icon that cannot be decoded leaves the current one in place.
            print(error)
        }

        onMainThread { self.applyDefaultRouteStopIcon(icon, generation: generation, resolve, reject) }
    }

    /// Sets the default stop icon, or leaves the current one when `icon` is nil. A call superseded by
    /// a later one while downloading resolves without applying, as ``setOptions`` does.
    @MainActor private func applyDefaultRouteStopIcon(
        _ icon: MPRouteStopIconProvider?,
        generation: UInt64,
        _ resolve: @escaping RCTPromiseResolveBlock,
        _ reject: @escaping RCTPromiseRejectBlock
    ) {
        guard defaultStopIconGeneration.isCurrent(generation) else {
            print("MapsIndoors: setDefaultRouteStopIcon was superseded by a later call, so its icon was not applied")
            return resolve(nil)
        }
        guard let directionsRenderer = currentDirectionsRenderer() else {
            return doReject(reject, message: Self.noRendererMessage, _func: "setDefaultRouteStopIcon")
        }
        if let icon {
            directionsRenderer.defaultRouteStopIcon = icon
        }
        resolve(nil)
    }

    @objc public func setOptions(_ optionsString: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        onMainThread {
            guard self.currentDirectionsRenderer() != nil else {
                return doReject(reject, message: Self.noRendererMessage)
            }

            guard let options: DirectionsRendererOptions = try? fromJSON(optionsString) else {
                return doReject(reject, message: "Options could not be parsed")
            }

            // Taken here rather than inside the Task, so it follows the order the calls were made in:
            // React Native calls this module's methods one at a time, and `onMainThread` runs them on
            // the main queue in that same order.
            let generation = self.optionsGeneration.next()

            Task {
                // The SDK takes the custom stamp as an image, so it has to be fetched before applying.
                // Immutable, because it is captured by the main-actor block below - a captured `var`
                // is a concurrency error in the Swift 6 language mode.
                let stampImage = await self.loadStampImage(urlString: options.stampImageUrl)

                let mpOptions = options.toMPDirectionsRendererOptions(stampImage: stampImage)

                let applied = await MainActor.run { () -> Bool in
                    // A later call has already started, so this one is stale - its download simply took
                    // longer. Dropping it keeps last-call-wins.
                    guard self.optionsGeneration.isCurrent(generation) else { return false }

                    // Looked up again rather than reusing the one checked above: a new map control can
                    // have replaced the renderer while the stamp was downloading.
                    guard let directionsRenderer = self.currentDirectionsRenderer() else {
                        print("MapsIndoors: setOptions found no directions renderer to apply its options to")
                        return true
                    }
                    directionsRenderer.options = mpOptions
                    // Only remember a URL that produced an image, so a failed download reads back as
                    // "no custom stamp" rather than as one the renderer is not actually drawing.
                    self.appliedStampImageUrl = stampImage != nil ? options.stampImageUrl : nil
                    return true
                }

                if !applied {
                    print("MapsIndoors: setOptions was superseded by a later call, so its options were not applied")
                }

                // Resolved either way, including when superseded. The caller's own later call is what
                // replaced this one, and that call's options are what is in force, so this is not a
                // failure to report - and rejecting would make an ordinary rapid sequence of setOptions
                // calls look broken. Leaving the promise unsettled would be worse still.
                resolve(nil)
            }
        }
    }

    @objc public func getOptions(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        // Both reads happen on the main actor: `appliedStampImageUrl` is written there by setOptions,
        // and the renderer and its options are main-actor isolated in the SDK.
        onMainThread {
            guard let directionsRenderer = self.currentDirectionsRenderer() else {
                return doReject(reject, message: Self.noRendererMessage)
            }

            resolve(toJSON(DirectionsRendererOptions(from: directionsRenderer.options, stampImageUrl: self.appliedStampImageUrl)))
        }
    }

    @objc public func finishGuidance(_ usagePercentage: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        // Resolve only once the work has run, matching setOptions - resolving first would report
        // success before the SDK had been told anything.
        onMainThread {
            // Deliberately not `currentDirectionsRenderer()`: finishing guidance on a renderer that was
            // never used for a route would only create one to finish nothing.
            guard let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer else {
                return doReject(reject, message: Self.noRendererMessage)
            }

            // A negative value means the app did not supply a figure, so the SDK derives it from
            // the route's own progress.
            if usagePercentage.doubleValue < 0 {
                directionsRenderer.finishGuidance()
            } else {
                directionsRenderer.finishGuidance(usagePercentage: usagePercentage.doubleValue)
            }
            resolve(nil)
        }
    }

    @objc public func setOnLegSelectedListener(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        // On the main thread with the leg methods that read it.
        onMainThread {
            self.isListeningForLegChanges = true
            resolve(nil)
        }
    }

    @objc public func setPolyLineColors(_ foregroundString: String, backgroundString: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        guard let foreground = try? colorFromHexString(hex: foregroundString), let background = try? colorFromHexString(hex: backgroundString) else {
            return doReject(reject, message: "Unable to parse color strings \(foregroundString), \(backgroundString)")
        }

        onMainThread {
            guard let directionsRenderer = self.currentDirectionsRenderer() else {
                return doReject(reject, message: Self.noRendererMessage)
            }

            directionsRenderer.pathColor = foreground
            directionsRenderer.backgroundColor = background
            resolve(nil)
        }
    }

    enum HexParsingError: Error {
        case invalidHexString(String)
    }
    func colorFromHexString(hex: String) throws -> UIColor {
        let regex = try! NSRegularExpression(pattern: "^#[0-9A-Fa-f]{6}$|^#[0-9A-Fa-f]{8}$")
        let range = NSRange(location: 0, length: hex.utf16.count)

        if regex.matches(in: hex, range: range).count == 1 {
            return UIColor(hex: hex)!
        } else {
            throw HexParsingError.invalidHexString(hex)
        }
    }

    @objc public func setRoute(_ routeString: String, stopIcons: String, legIndex: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        // Decoded here, off the main thread: a route can be large, and none of this touches the map.
        guard let route = try? JSONDecoder().decode(MPRouteInternal.self, from: Data(routeString.utf8)) else {
            return doReject(reject, message: "Route could not be parsed")
        }

        guard legIndex.intValue >= 0 else {
            return doReject(reject, message: "Tried to select negative route leg index \(legIndex.intValue)")
        }

        guard legIndex.intValue < (route.legs.count) else {
            return doReject(reject, message: "Tried to select route leg index \(legIndex.intValue) outside of range 0..\((route.legs.count)-1)")
        }

        let iconStrings = (try? JSONDecoder().decode([Int: String].self, from: Data(stopIcons.utf8))) ?? [:]

        // Taken after validation, so a call that is rejected outright supersedes nothing.
        let generation = routeGeneration.next()

        // Without URL icons there is nothing to wait for, so the route goes straight onto the main
        // queue and keeps its place in the order of calls. URL icons are downloaded first, and a failed
        // download rejects instead of leaving the promise unsettled.
        guard iconStrings.values.contains(where: { isValidUrl($0) }) else {
            let icons = iconStrings.compactMapValues { self.decodedStopIcon($0) }
            onMainThread { self.applyRoute(route, legIndex: legIndex.intValue, stopIcons: icons, generation: generation, resolve, reject) }
            return
        }

        Task {
            do {
                var icons: [Int: any MPRouteStopIconProvider] = [:]
                for (key, value) in iconStrings {
                    if self.isValidUrl(value) {
                        icons[key] = IconStopUrl(image: try await self.downloadImage(from: URL(string: value)!))
                    } else if let icon = self.decodedStopIcon(value) {
                        icons[key] = icon
                    }
                }
                onMainThread { self.applyRoute(route, legIndex: legIndex.intValue, stopIcons: icons, generation: generation, resolve, reject) }
            } catch {
                doReject(reject, error: error)
            }
        }
    }

    /// A stop icon described as JSON (the bridge appends one trailing character), or nil if it does not
    /// decode.
    private func decodedStopIcon(_ string: String) -> (any MPRouteStopIconProvider)? {
        var json = string
        json.removeLast()
        return (try? JSONDecoder().decode(RouteIcon.self, from: json.data(using: .utf8)!))?.getIcon()
    }

    /// Shows `route` on the renderer, looked up at the moment of applying. A call superseded by a later
    /// ``setRoute`` or ``clear`` while downloading resolves without drawing, as ``setOptions`` does.
    @MainActor private func applyRoute(
        _ route: MPRouteInternal,
        legIndex: Int,
        stopIcons: [Int: any MPRouteStopIconProvider],
        generation: UInt64,
        _ resolve: @escaping RCTPromiseResolveBlock,
        _ reject: @escaping RCTPromiseRejectBlock
    ) {
        guard routeGeneration.isCurrent(generation) else {
            print("MapsIndoors: setRoute was superseded by a later setRoute or clear, so its route was not drawn")
            return resolve(nil)
        }
        guard let directionsRenderer = currentDirectionsRenderer() else {
            return doReject(reject, message: Self.noRendererMessage, _func: "setRoute")
        }

        applyMapPadding(to: directionsRenderer)
        directionsRenderer.route = route
        directionsRenderer.routeLegIndex = legIndex
        directionsRenderer.render(stopIcons: stopIcons)
        resolve(nil)
    }

    /// Fetches the custom stamp icon, or nil when there is none, the URL is malformed, or the
    /// download fails.
    ///
    /// A failure is logged rather than rejected: the rest of the options still apply, so failing the
    /// whole call would misreport it - but a silently missing stamp is otherwise undiagnosable.
    private func loadStampImage(urlString: String?) async -> UIImage? {
        guard let urlString else { return nil }
        guard let url = URL(string: urlString) else {
            print("MapsIndoors: route stamp image URL is malformed: \(urlString)")
            return nil
        }
        do {
            return try await self.downloadImage(from: url)
        } catch {
            print("MapsIndoors: could not load the route stamp image at \(urlString): \(error)")
            return nil
        }
    }

    enum ImageDownloadError: Error {
        /// The response body was fetched but is not decodable as an image - what a 404 or an error
        /// page produces. Force unwrapping here would trap instead, which no caller can catch.
        case notAnImage(URL)
    }

    func downloadImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw ImageDownloadError.notAnImage(url)
        }
        return image
    }

    func isValidUrl(_ urlString: String) -> Bool {
        if let url = URL(string: urlString) {
            return url.scheme != nil && url.host != nil
        }
        return false
    }
}
