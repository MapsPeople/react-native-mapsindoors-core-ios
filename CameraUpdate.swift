//
//  CameraUpdate.swift
//  react-native-maps-indoors-mapbox
//
//  Created by Tim Mikkelsen on 14/06/2023.
//

import MapsIndoors

public struct CameraUpdate: Codable {
    let position: CameraPosition?
    let mode: String
    let point: MPPoint?
    let bounds: MPGeoBounds?
    let padding: Int?
    let width: Int?
    let height: Int?
    let zoom: Float?
}
