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
    private var directionsRenderer: MPDirectionsRenderer? = nil
    private var isListeningForLegChanges: Bool = false
    
    @objc public override static func requiresMainQueueSetup() -> Bool { return false }

    /// Base overide for RCTEventEmitter.
    ///
    /// - Returns: all supported events
    @objc open override func supportedEvents() -> [String] {
        return MapsIndoorsData.sharedInstance.allEvents
    }
    
    @objc public func clear(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (directionsRenderer == nil) {
            directionsRenderer = MapsIndoorsData.sharedInstance.mapControl?.newDirectionsRenderer()
        }
        
        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }
        DispatchQueue.main.sync {
            directionsRenderer.clear()
        }
        return resolve(nil)
    }
    
    @objc public func getSelectedLegFloorIndex(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (directionsRenderer == nil) {
            directionsRenderer = MapsIndoorsData.sharedInstance.mapControl?.newDirectionsRenderer()
        }
        
        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }
        
        guard let legIndex = directionsRenderer.route?.legs[directionsRenderer.routeLegIndex].end_location.zLevel.int32Value else {
            return doReject(reject, message: "No current floor available")
        }
        
        return resolve(legIndex)
    }
    
    @objc public func nextLeg(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (directionsRenderer == nil) {
            directionsRenderer = MapsIndoorsData.sharedInstance.mapControl?.newDirectionsRenderer()
        }
        
        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }
        
        
        DispatchQueue.main.sync {
            let succes = directionsRenderer.nextLeg()
            
            if succes {
                directionsRenderer.animate(duration: 5)
                if (isListeningForLegChanges) {
                    sendEvent(withName: MapsIndoorsData.Event.onLegSelected.rawValue, body: ["leg": directionsRenderer.routeLegIndex])
                }
            }
        }
        return resolve(nil)
    }
    
    @objc public func previousLeg(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (directionsRenderer == nil) {
            directionsRenderer = MapsIndoorsData.sharedInstance.mapControl?.newDirectionsRenderer()
        }
        
        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }
        
        let succes = directionsRenderer.previousLeg()
        
        DispatchQueue.main.sync {
            if succes {
                directionsRenderer.animate(duration: 5)
                if (isListeningForLegChanges) {
                    sendEvent(withName: MapsIndoorsData.Event.onLegSelected.rawValue, body: ["leg": directionsRenderer.routeLegIndex])
                }
            }
        }
        
        return resolve(nil)
    }
    
    @objc public func selectLegIndex(_ legIndex: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (directionsRenderer == nil) {
            directionsRenderer = MapsIndoorsData.sharedInstance.mapControl?.newDirectionsRenderer()
        }
        
        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }
        
        guard let route = directionsRenderer.route else {
            return doReject(reject, message: "No route is set")
        }
        
        if (route.legs.count) < legIndex.intValue || legIndex.intValue < 0 {
            return resolve(nil)
        }
        
        DispatchQueue.main.sync {
            directionsRenderer.routeLegIndex = legIndex.intValue
            
            directionsRenderer.animate(duration: 5)
            
            if isListeningForLegChanges {
                sendEvent(withName: MapsIndoorsData.Event.onLegSelected.rawValue, body: ["leg": directionsRenderer.routeLegIndex])
            }
        }
        return resolve(nil)
    }
    
    @objc public func setAnimatedPolyline(_ animated: Bool, repeated: Bool, duration: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (directionsRenderer == nil) {
            directionsRenderer = MapsIndoorsData.sharedInstance.mapControl?.newDirectionsRenderer()
        }
        
        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }
        
        if (animated) {
            directionsRenderer.animate(duration: duration.doubleValue)
        }
        
        return resolve(nil)
    }
    
    @objc public func setCameraViewFitMode(_ cameraFitMode: NSNumber, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (directionsRenderer == nil) {
            directionsRenderer = MapsIndoorsData.sharedInstance.mapControl?.newDirectionsRenderer()
        }
        
        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }
        
        guard let cameraViewFitMode = MPCameraViewFitMode(rawValue: cameraFitMode.intValue) else {
            return doReject(reject, message: "CameraFitMode not found")
        }
        
        directionsRenderer.fitMode = cameraViewFitMode
        return resolve(nil)
    }
    
    @objc public func setOnLegSelectedListener(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        isListeningForLegChanges = true
        return resolve(nil)
    }
    
    @objc public func setPolyLineColors(_ foregroundString: String, backgroundString: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (directionsRenderer == nil) {
            directionsRenderer = MapsIndoorsData.sharedInstance.mapControl?.newDirectionsRenderer()
        }
    }
    
    @objc public func setRoute(_ routeString: String, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if (directionsRenderer == nil) {
            directionsRenderer = MapsIndoorsData.sharedInstance.mapControl?.newDirectionsRenderer()
        }
        
        guard let directionsRenderer else {
            return doReject(reject, message: "directions renderer null. MapControl needs to have been instantiated first")
        }
        
        
        guard let route = try? JSONDecoder().decode(MPRouteCodable.self, from: Data(routeString.utf8)) else {
            return doReject(reject, message: "Route could not be parsed")
        }

        DispatchQueue.main.sync {
            directionsRenderer.route = route
            directionsRenderer.routeLegIndex = 0
            directionsRenderer.animate(duration: 5)
        }

        resolve(nil)
    }
}
