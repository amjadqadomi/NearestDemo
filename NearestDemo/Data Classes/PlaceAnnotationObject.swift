//
//  MapAnnotationObject.swift
//  NearestDemo
//
//  Created by Amjad on 2/25/21.
//

import Foundation
import MapKit
/// This custom class is a subclass of MKAnnotation which holds data to be shown on the map, this represnts a place object
class PlaceAnnotationObject: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var distance: Int?
    var rating: Double?
    var openingHours: String?
    var phone: String?
    var id: String?
    
    
    init(title: String?, coordinate: CLLocationCoordinate2D, distance: Int?, rating: Double?, openingHours: String?, phone: String?, id: String?) {
        self.title = title
        self.coordinate = coordinate
        self.distance = distance
        self.rating = rating
        self.openingHours = openingHours
        self.phone = phone
        self.id = id
        super.init()
    }
    

}

/// This custom class is a subclass of MKAnnotation which holds data to be shown on the map, this represnts a user location object
class UserLocationMapAnnotationObject: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?

    init(title: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        super.init()
    }

}
