//
//  CameraPosition.swift
//  react-native-maps-indoors-mapbox
//
//  Created by Tim Mikkelsen on 14/06/2023.
//

import MapsIndoors

public struct CameraPosition: Codable {
    let zoom: Float
    let tilt: Float // TODO: this is called viewingAngle in MPCameraPosition(Codable)
    let bearing: Float
    let target: MPPoint
}
