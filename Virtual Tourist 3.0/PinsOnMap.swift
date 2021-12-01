//
//  PinsOnMap.swift
//  Virtual Tourist 3.0
//
//  Created by Zakaria on 30/11/2021.
//

import Foundation
import MapKit

class PinsOnMap : NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D){
        self.coordinate = coordinate
        
        super.init()
    }
}
