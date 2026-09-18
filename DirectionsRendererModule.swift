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

    /// Guards ``setOptionsGeneration``, which is taken on React Native's method queue and read on
    /// the main actor.
    private let setOptionsGenerationLock = NSLock()

    /// Identifies the most recent ``setOptions`` call.
    ///
    /// A custom stamp has to be downloaded before the options can be applied, so two calls can finish
    /// out of order and a slow download would otherwise overwrite a newer call's result. Each call
    /// takes a token and applies its result only while it is still the newest, making last-call-wins
    /// hold regardless of how long each download took.
    ///
    /// The token has to be taken *synchronously*, before the call's `Task` is created. React Native
    /// serialises this module's methods on one queue, so taking it there makes the token follow call
    /// order. Taking it inside the `Task` would instead number the calls by whichever one the
    /// cooperative pool happened to schedule first, which is not the order they were made in - the
    /// newer call could take the lower token and then be discarded in favour of the older one.
    private var setOptionsGeneration: UInt64 = 0

    /// Takes the next token, in call order.
    private func nextSetOptionsGeneration() -> UInt64 {
        setOptionsGenerationLock.lock()
        defer { setOptionsGenerationLock.unlock() }
        setOptionsGeneration &+= 1
        return setOptionsGeneration
    }

    /// Whether `generation` is still the newest token, i.e. no later ``setOptions`` call has started.
    private func isCurrentSetOptionsGeneration(_ generation: UInt64) -> Bool {
        setOptionsGenerationLock.lock()
        defer { setOptionsGenerationLock.unlock() }
        return generation == setOptionsGeneration
    }

    @objc public override static func requiresMainQueueSetup() -> Bool { return false }

    /// Base overide for RCTEventEmitter.
    ///
    /// - Returns: all supported events
    @objc open override func supportedEvents() -> [String] {
        return MapsIndoorsData.sharedInstance.allEvents
    }

    @objc public func clear(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if MapsIndoorsData.sharedInstance.directionsRenderer == nil {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.newDirectionsRenderer()
            animationDuration = 5
        }

        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer

        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }

        DispatchQueue.main.async {
            directionsRenderer.clear()
            directionsRenderer.route = nil
        }
        return resolve(nil)
    }

    @objc public func getSelectedLegFloorIndex(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if MapsIndoorsData.sharedInstance.directionsRenderer == nil {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.newDirectionsRenderer()
        }

        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer

        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }

        directionsRenderer.padding = MapsIndoorsData.sharedInstance.mapView!.getMapControl()!.mapPadding

        guard let legIndex = directionsRenderer.route?.legs[directionsRenderer.routeLegIndex].end_location.zLevel.int32Value else {
            return doReject(reject, message: "No current floor available")
        }

        return resolve(legIndex)
    }

    @objc public func nextLeg(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if MapsIndoorsData.sharedInstance.directionsRenderer == nil {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.newDirectionsRenderer()
        }

        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer

        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }

        directionsRenderer.padding = MapsIndoorsData.sharedInstance.mapView!.getMapControl()!.mapPadding

        DispatchQueue.main.async {
            let succes = directionsRenderer.nextLeg()

            if succes {
                directionsRenderer.animate(duration: self.animationDuration.doubleValue)
                if self.isListeningForLegChanges {
                    self.sendEvent(withName: MapsIndoorsData.Event.onLegSelected.rawValue, body: ["leg": directionsRenderer.routeLegIndex])
                }
            }
        }
        return resolve(nil)
    }

    @objc public func previousLeg(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if MapsIndoorsData.sharedInstance.directionsRenderer == nil {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.newDirectionsRenderer()
        }

        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer

        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }

        directionsRenderer.padding = MapsIndoorsData.sharedInstance.mapView!.getMapControl()!.mapPadding

        DispatchQueue.main.async {
            let succes = directionsRenderer.previousLeg()

            if succes {
                directionsRenderer.animate(duration: self.animationDuration.doubleValue)
                if self.isListeningForLegChanges {
                    self.sendEvent(withName: MapsIndoorsData.Event.onLegSelected.rawValue, body: ["leg": directionsRenderer.routeLegIndex])
                }
            }
        }

        return resolve(nil)
    }

    @objc public func selectLegIndex(_ legIndex: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if MapsIndoorsData.sharedInstance.directionsRenderer == nil {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.newDirectionsRenderer()
        }

        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer

        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
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

        directionsRenderer.padding = MapsIndoorsData.sharedInstance.mapView!.getMapControl()!.mapPadding

        DispatchQueue.main.async {
            directionsRenderer.routeLegIndex = legIndex.intValue

            directionsRenderer.animate(duration: self.animationDuration.doubleValue)

            if self.isListeningForLegChanges {
                self.sendEvent(withName: MapsIndoorsData.Event.onLegSelected.rawValue, body: ["leg": directionsRenderer.routeLegIndex])
            }
        }
        return resolve(nil)
    }

    @objc public func setAnimatedPolyline(_ animated: Bool, repeated: Bool, duration: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if MapsIndoorsData.sharedInstance.directionsRenderer == nil {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.newDirectionsRenderer()
        }

        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer

        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }

        if animated {
            animationDuration = duration
        } else {
            animationDuration = 0
        }

        return resolve(nil)
    }

    @objc public func showRouteLegButtons(_ value: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if MapsIndoorsData.sharedInstance.directionsRenderer == nil {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.newDirectionsRenderer()
        }

        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer

        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }

        directionsRenderer.showRouteLegButtons = value

        return resolve(nil)
    }

    @objc public func setCameraAnimationDuration(_ duration: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if MapsIndoorsData.sharedInstance.directionsRenderer == nil {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.newDirectionsRenderer()
        }

        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer

        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }

        animationDuration = duration

        return resolve(nil)
    }

    @objc public func setCameraViewFitMode(_ cameraFitMode: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if MapsIndoorsData.sharedInstance.directionsRenderer == nil {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.newDirectionsRenderer()
        }

        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer

        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }

        var camFitMode: MPCameraViewFitMode? = nil

        switch cameraFitMode {
        case 0:
            camFitMode = MPCameraViewFitMode.northAligned
        case 1:
            camFitMode = MPCameraViewFitMode.firstStepAligned
        case 2:
            camFitMode = MPCameraViewFitMode.startToEndAligned
        case 3:
            camFitMode = MPCameraViewFitMode.none
        default:
            camFitMode = MPCameraViewFitMode.northAligned
        }

        directionsRenderer.fitMode = camFitMode!
        return resolve(nil)
    }

    @objc public func setDefaultRouteStopIcon(_ defaultIcon: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if MapsIndoorsData.sharedInstance.directionsRenderer == nil {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.newDirectionsRenderer()
        }

        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer

        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }

        Task {
            if isValidUrl(defaultIcon) {
                let test = IconStopUrl(image: try await downloadImage(from: URL(string: defaultIcon)!))
                directionsRenderer.defaultRouteStopIcon = IconStopUrl(image: try await downloadImage(from: URL(string: defaultIcon)!))
            } else {
                do {
                    var deficon = defaultIcon
                    deficon.removeLast()
                    let iconConfig = try JSONDecoder().decode(RouteIcon.self, from: deficon.data(using: .utf8)!)
                    if iconConfig != nil {
                        directionsRenderer.defaultRouteStopIcon = iconConfig.getIcon()
                    } else {
                        directionsRenderer.defaultRouteStopIcon = nil
                    }
                } catch {
                    print(error)
                }
            }

            resolve(nil)
        }
    }

    @objc public func setOptions(_ optionsString: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        if MapsIndoorsData.sharedInstance.directionsRenderer == nil {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.newDirectionsRenderer()
        }

        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer

        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }

        guard let options: DirectionsRendererOptions = try? fromJSON(optionsString) else {
            return doReject(reject, message: "Options could not be parsed")
        }

        // Taken here rather than inside the Task, so it follows the order the calls were made in.
        let generation = nextSetOptionsGeneration()

        Task {
            // The SDK takes the custom stamp as an image, so it has to be fetched before applying.
            // Immutable, because it is captured by the main-actor block below - a captured `var`
            // is a concurrency error in the Swift 6 language mode.
            let stampImage = await self.loadStampImage(urlString: options.stampImageUrl)

            let mpOptions = options.toMPDirectionsRendererOptions(stampImage: stampImage)

            let applied = await MainActor.run { () -> Bool in
                // A later call has already started, so this one is stale - its download simply took
                // longer. Dropping it keeps last-call-wins.
                guard self.isCurrentSetOptionsGeneration(generation) else { return false }

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

    @objc public func getOptions(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        if MapsIndoorsData.sharedInstance.directionsRenderer == nil {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.newDirectionsRenderer()
        }

        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer

        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }

        // Both reads have to happen on the main actor: `appliedStampImageUrl` is written there by
        // setOptions, and the SDK's own options getter resolves against renderer state that is
        // main-thread affine. React Native calls this module off the main queue.
        Task { @MainActor in
            resolve(toJSON(DirectionsRendererOptions(from: directionsRenderer.options, stampImageUrl: self.appliedStampImageUrl)))
        }
    }

    @objc public func finishGuidance(_ usagePercentage: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer

        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }

        // Resolve only once the work has run, matching setOptions - resolving first would report
        // success before the SDK had been told anything.
        Task { @MainActor in
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

    @objc public func setOnLegSelectedListener(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        isListeningForLegChanges = true
        return resolve(nil)
    }

    @objc public func setPolyLineColors(_ foregroundString: String, backgroundString: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if MapsIndoorsData.sharedInstance.directionsRenderer == nil {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.newDirectionsRenderer()
        }

        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer

        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }

        guard let foreground = try? colorFromHexString(hex: foregroundString), let background = try? colorFromHexString(hex: backgroundString) else {
            return doReject(reject, message: "Unable to parse color strings \(foregroundString), \(backgroundString)")
        }

        DispatchQueue.main.async {
            directionsRenderer.pathColor = foreground
            directionsRenderer.backgroundColor = background
        }
        return resolve(nil)
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

    @objc public func setRoute(_ routeString: String, stopIcons: String, legIndex: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if MapsIndoorsData.sharedInstance.directionsRenderer == nil {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.newDirectionsRenderer()
        }

        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer

        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }

        directionsRenderer.padding = MapsIndoorsData.sharedInstance.mapView!.getMapControl()!.mapPadding

        guard let route = try? JSONDecoder().decode(MPRouteInternal.self, from: Data(routeString.utf8)) else {
            return doReject(reject, message: "Route could not be parsed")
        }

        guard legIndex.intValue >= 0 else {
            return doReject(reject, message: "Tried to select negative route leg index \(legIndex.intValue)")
        }

        guard legIndex.intValue < (route.legs.count) else {
            return doReject(reject, message: "Tried to select route leg index \(legIndex.intValue) outside of range 0..\((route.legs.count)-1)")
        }

        Task {
            var stopIconss: [Int: String]? = nil
            stopIconss = try? JSONDecoder().decode([Int: String].self, from: Data(stopIcons.utf8))

            var icons: [Int: any MPRouteStopIconProvider] = [:]
            if stopIconss != nil {
                for icon in stopIconss! {
                    if isValidUrl(icon.value) {
                        icons[icon.key] = IconStopUrl(image: try await downloadImage(from: URL(string: icon.value)!))
                    } else {
                        var ic = icon.value
                        ic.removeLast()
                        let iconConfig = try? JSONDecoder().decode(RouteIcon.self, from: ic.data(using: .utf8)!)
                        if iconConfig != nil {
                            icons[icon.key] = iconConfig!.getIcon()
                        }
                    }
                }
            }

            DispatchQueue.main.sync {
                directionsRenderer.route = route
                directionsRenderer.routeLegIndex = legIndex.intValue
                directionsRenderer.render(stopIcons: icons)
            }

            resolve(nil)
        }
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
            return try await downloadImage(from: url)
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
