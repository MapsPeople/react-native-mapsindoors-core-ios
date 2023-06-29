//
//  RCMapView.swift
//  react-native-maps-indoors-mapbox
//
//  Created by Tim Mikkelsen on 14/06/2023.
//

import MapsIndoors

protocol RCMapView {
    func animateCamera(cameraUpdate: CameraUpdate, duration: Int) throws
    func moveCamera(cameraUpdate: CameraUpdate) throws
    func getConfig() -> MPMapConfig
}
