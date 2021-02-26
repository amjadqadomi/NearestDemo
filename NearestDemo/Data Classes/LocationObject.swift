//
//  LocationObject.swift
//  NearstDemo
//
//  Created by Amjad on 2/24/21.
//

import Foundation
import CoreLocation
import MapKit

///This class holds information of the location 
public class LocationObject: NSObject {
    public var name: String?
    
    // difference from placemark location is that if location was reverse geocoded,
    // then location point to user selected location
    public var location: CLLocation?
    public var placemark: CLPlacemark?
    
    public var address: String {
        return "".appendingFormat("%.4f,%.4f",coordinate.latitude, coordinate.longitude)
    }
    
    public init(name: String?, location: CLLocation? = nil, placemark: CLPlacemark?) {
        super.init()
        if name != nil {
            self.name = name
        }
        if location != nil {
            self.location = location
        }
        if placemark != nil {
            self.placemark = placemark
        }
    }
}

extension LocationObject: MKAnnotation {
    
    @objc public var coordinate: CLLocationCoordinate2D {
        if let location = location {
            return location.coordinate
        } else if let placemarkLocation = placemark?.location {
            return CLLocationCoordinate2DMake(placemarkLocation.coordinate.latitude, placemarkLocation.coordinate.longitude)
        } else {
            return CLLocationCoordinate2DMake(0, 0)
        }
    }
    
    public var title: String? {
        return name ?? address
    }
}
