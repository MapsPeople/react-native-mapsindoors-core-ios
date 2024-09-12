//
//  IconStopUrl.swift
//  react-native-maps-indoors-mapbox
//
//  Created by Tim Mikkelsen on 14/05/2024.
//

import Foundation
import MapsIndoors

public class IconStopUrl: MPRouteStopIconProvider {
    public var image: UIImage?
    
    init(image: UIImage) {
        self.image = image
    }
}
