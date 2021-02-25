//
//  MapLocations.swift
//  NearestDemo
//
//  Created by Amjad on 2/25/21.
//

import Foundation
import MapKit

class MapLocation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var distance: Int?
    var rating: Double?
    var openingHours: String?
    var phone: String?
    
    
    init(title: String?, coordinate: CLLocationCoordinate2D, distance: Int?, rating: Double?, openingHours: String?, phone: String?) {
        self.title = title
        self.coordinate = coordinate
        self.distance = distance
        self.rating = rating
        self.openingHours = openingHours
        self.phone = phone
        super.init()
    }
    
    
}
