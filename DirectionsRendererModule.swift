//
//  DirectionsRendererModule.swift
//  react-native-maps-indoors
//
//  Created by Tim Mikkelsen on 01/05/2023.
//

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
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapControl?.newDirectionsRenderer()
            animationDuration = 5
        }
        
        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer

        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }
        
        DispatchQueue.main.sync {
            directionsRenderer.clear()
        }
        return resolve(nil)
    }

    @objc public func getSelectedLegFloorIndex(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (MapsIndoorsData.sharedInstance.directionsRenderer == nil) {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapControl?.newDirectionsRenderer()
        }
        
        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer

        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }
        
        directionsRenderer.padding = MapsIndoorsData.sharedInstance.mapControl!.mapPadding
        
        guard let legIndex = directionsRenderer.route?.legs[directionsRenderer.routeLegIndex].end_location.zLevel.int32Value else {
            return doReject(reject, message: "No current floor available")
        }

        return resolve(legIndex)
    }

    @objc public func nextLeg(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (MapsIndoorsData.sharedInstance.directionsRenderer == nil) {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapControl?.newDirectionsRenderer()
        }
        
        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer


        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }
        
        directionsRenderer.padding = MapsIndoorsData.sharedInstance.mapControl!.mapPadding

        DispatchQueue.main.sync {
            let succes = directionsRenderer.nextLeg()

            if succes {
                directionsRenderer.animate(duration: animationDuration.doubleValue)
                if (isListeningForLegChanges) {
                    sendEvent(withName: MapsIndoorsData.Event.onLegSelected.rawValue, body: ["leg": directionsRenderer.routeLegIndex])
                }
            }
        }
        return resolve(nil)
    }

    @objc public func previousLeg(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (MapsIndoorsData.sharedInstance.directionsRenderer == nil) {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapControl?.newDirectionsRenderer()
        }
        
        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer


        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }
              
        directionsRenderer.padding = MapsIndoorsData.sharedInstance.mapControl!.mapPadding

        DispatchQueue.main.sync {
            let succes = directionsRenderer.previousLeg()

            if succes {
                directionsRenderer.animate(duration: animationDuration.doubleValue)
                if (isListeningForLegChanges) {
                    sendEvent(withName: MapsIndoorsData.Event.onLegSelected.rawValue, body: ["leg": directionsRenderer.routeLegIndex])
                }
            }
        }

        return resolve(nil)
    }

    @objc public func selectLegIndex(_ legIndex: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (MapsIndoorsData.sharedInstance.directionsRenderer == nil) {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapControl?.newDirectionsRenderer()
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
        
        directionsRenderer.padding = MapsIndoorsData.sharedInstance.mapControl!.mapPadding

        DispatchQueue.main.sync {
            directionsRenderer.routeLegIndex = legIndex.intValue

            directionsRenderer.animate(duration: animationDuration.doubleValue)

            if isListeningForLegChanges {
                sendEvent(withName: MapsIndoorsData.Event.onLegSelected.rawValue, body: ["leg": directionsRenderer.routeLegIndex])
            }
        }
        return resolve(nil)
    }

    @objc public func setAnimatedPolyline(_ animated: Bool, repeated: Bool, duration: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (MapsIndoorsData.sharedInstance.directionsRenderer == nil) {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapControl?.newDirectionsRenderer()
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
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapControl?.newDirectionsRenderer()
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
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapControl?.newDirectionsRenderer()
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
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapControl?.newDirectionsRenderer()
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
        default:
            camFitMode = MPCameraViewFitMode.northAligned
        }
        
        directionsRenderer.fitMode = camFitMode!
        return resolve(nil)
    }

    @objc public func setOnLegSelectedListener(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        isListeningForLegChanges = true
        return resolve(nil)
    }

    @objc public func setPolyLineColors(_ foregroundString: String, backgroundString: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        return resolve(nil)
    }

    @objc public func setRoute(_ routeString: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (MapsIndoorsData.sharedInstance.directionsRenderer == nil) {
            MapsIndoorsData.sharedInstance.directionsRenderer = MapsIndoorsData.sharedInstance.mapControl?.newDirectionsRenderer()
        }
        
        let directionsRenderer = MapsIndoorsData.sharedInstance.directionsRenderer


        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }
        
        directionsRenderer.padding = MapsIndoorsData.sharedInstance.mapControl!.mapPadding
                
        guard let route = try? JSONDecoder().decode(MPRouteCodable.self, from: Data(routeString.utf8)) else {
            return doReject(reject, message: "Route could not be parsed")
        }

        DispatchQueue.main.sync {
            directionsRenderer.route = route
            directionsRenderer.routeLegIndex = 0
            directionsRenderer.animate(duration: animationDuration.doubleValue)
        }

        resolve(nil)
    }
}
