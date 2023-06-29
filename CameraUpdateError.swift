//
//  CameraUpdateError.swift
//  react-native-maps-indoors-mapbox
//
//  Created by Tim Mikkelsen on 14/06/2023.
//

public enum CameraUpdateError: Error {
    case missingField(String, String)
    case unknownMode(String)
}
