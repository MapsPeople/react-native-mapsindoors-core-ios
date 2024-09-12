//
//  DirectionsRendererModule.swift
//  react-native-maps-indoors
//
//  Created by Tim Mikkelsen on 01/05/2023.
//

import MapsIndoorsCore
import MapsIndoors
import MapsIndoorsCodable
import React

@objc(DirectionsRenderer)
public class DirectionsRendererModule: RCTEventEmitter {
    private var isListeningForLegChanges: Bool = false
    private var animationDuration: NSNumber = 5

    @objc public override static func requiresMainQueueSetup() -> Bool { return false }

    /// Base overide for RCTEventEmitter.
    ///
    /// - Returns: all supported events
    @objc open override func supportedEvents() -> [String] {
        return MapsIndoorsData.sharedInstance.allEvents
    }

    @objc public func clear(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (MapsIndoorsData.sharedInstance.directionsRenderer == nil) {
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
        if (MapsIndoorsData.sharedInstance.directionsRenderer == nil) {
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
        if (MapsIndoorsData.sharedInstance.directionsRenderer == nil) {
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
                if (self.isListeningForLegChanges) {
                    self.sendEvent(withName: MapsIndoorsData.Event.onLegSelected.rawValue, body: ["leg": directionsRenderer.routeLegIndex])
                }
            }
        }
        return resolve(nil)
    }

    @objc public func previousLeg(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (MapsIndoorsData.sharedInstance.directionsRenderer == nil) {
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
                if (self.isListeningForLegChanges) {
                    self.sendEvent(withName: MapsIndoorsData.Event.onLegSelected.rawValue, body: ["leg": directionsRenderer.routeLegIndex])
                }
            }
        }

        return resolve(nil)
    }

    @objc public func selectLegIndex(_ legIndex: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (MapsIndoorsData.sharedInstance.directionsRenderer == nil) {
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
        if (MapsIndoorsData.sharedInstance.directionsRenderer == nil) {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.newDirectionsRenderer()
        }
        
        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer


        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }

        if (animated) {
            animationDuration = duration
        }else {
            animationDuration = 0
        }

        return resolve(nil)
    }

    @objc public func showRouteLegButtons(_ value: Bool, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (MapsIndoorsData.sharedInstance.directionsRenderer == nil) {
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
        if (MapsIndoorsData.sharedInstance.directionsRenderer == nil) {
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
        if (MapsIndoorsData.sharedInstance.directionsRenderer == nil) {
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
        if (MapsIndoorsData.sharedInstance.directionsRenderer == nil) {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapView?.getMapControl()?.newDirectionsRenderer()
        }
        
        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer
        
        guard let directionsRenderer else  {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }
        
        Task {
            if (isValidUrl(defaultIcon)) {
                let test = IconStopUrl(image: try await downloadImage(from: URL(string: defaultIcon)!))
                directionsRenderer.defaultRouteStopIcon = IconStopUrl(image: try await downloadImage(from: URL(string: defaultIcon)!))
            }else {
                do {
                    var deficon = defaultIcon
                    deficon.removeLast()
                    let iconConfig = try JSONDecoder().decode(RouteIcon.self, from: deficon.data(using: .utf8)!)
                    if (iconConfig != nil) {
                        directionsRenderer.defaultRouteStopIcon = iconConfig.getIcon()
                    }else {
                        directionsRenderer.defaultRouteStopIcon = nil
                    }
                }catch {
                    print(error)
                }
                
            }
            
            resolve(nil)
        }
    }

    @objc public func setOnLegSelectedListener(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        isListeningForLegChanges = true
        return resolve(nil)
    }

    @objc public func setPolyLineColors(_ foregroundString: String, backgroundString: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        return resolve(nil)
    }

    @objc public func setRoute(_ routeString: String, stopIcons: String, legIndex: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (MapsIndoorsData.sharedInstance.directionsRenderer == nil) {
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
            
            var icons: [Int : any MPRouteStopIconProvider] = [:]
            if (stopIconss != nil) {
                for icon in stopIconss! {
                    if (isValidUrl(icon.value)) {
                        icons[icon.key] = IconStopUrl(image: try await downloadImage(from: URL(string: icon.value)!))
                    }else {
                        var ic = icon.value
                        ic.removeLast()
                        let iconConfig = try? JSONDecoder().decode(RouteIcon.self, from: ic.data(using: .utf8)!)
                        if (iconConfig != nil) {
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
    
    
    func downloadImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)!
    }
    
    func isValidUrl(_ urlString: String) -> Bool {
        if let url = URL(string: urlString) {
            return url.scheme != nil && url.host != nil
        }
        return false
    }

}
