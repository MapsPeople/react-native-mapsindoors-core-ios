//
//  LabelGraphic.swift
//  react-native-maps-indoors-mapbox
//
//  Created by Tim Mikkelsen on 29/05/2024.
//

import Foundation

struct LabelGraphic: Codable {
    let backgroundImage: String
    let stretchX: [[Int]]
    let stretchY: [[Int]]
    let content: [Int]
}
