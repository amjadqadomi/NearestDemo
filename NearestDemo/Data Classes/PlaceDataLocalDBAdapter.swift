//
//  PlaceDataLocalDBAdapter.swift
//  NearestDemo
//
//  Created by Amjad on 2/25/21.
//

import Foundation
/// This class is an adapter (wrapper) to help store custom attributes -non premitive- of "Place Data" in Core data, this class implements encode function to store them.
public class PlaceDataLocalDBAdapter: NSObject, NSCoding {
    
    public var longitude: Double
    public var latitude: Double
    public var distance: Int
    public var title: String?
    public var averageRating: Double
    public var id: String
    public var phoneNumber: String?
    public var openingHours: String?
    public var alternativeNames: PlaceAlternativeNamesLocalDBAdapter?

    
    enum EncodingKeys: String {
        case longitude = "longitude"
        case latitude = "latitude"
        case distance = "distance"
        case title = "title"
        case averageRating = "averageRating"
        case id = "id"
        case phoneNumber = "phoneNumber"
        case openingHours = "openingHours"
        case alternativeNames = "alternativeNames"
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(longitude, forKey: EncodingKeys.longitude.rawValue)
        coder.encode(latitude, forKey: EncodingKeys.latitude.rawValue)
        coder.encode(distance, forKey: EncodingKeys.distance.rawValue)
        coder.encode(title, forKey: EncodingKeys.title.rawValue)
        coder.encode(averageRating, forKey: EncodingKeys.averageRating.rawValue)
        coder.encode(id, forKey: EncodingKeys.id.rawValue)
        coder.encode(phoneNumber, forKey: EncodingKeys.phoneNumber.rawValue)
        coder.encode(openingHours, forKey: EncodingKeys.openingHours.rawValue)
        coder.encode(alternativeNames, forKey: EncodingKeys.alternativeNames.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        let longitude = coder.decodeObject(forKey: EncodingKeys.longitude.rawValue) as! Double
        let latitude = coder.decodeObject(forKey: EncodingKeys.latitude.rawValue) as! Double
        let distance = coder.decodeObject(forKey: EncodingKeys.distance.rawValue) as! Int
        let title = coder.decodeObject(forKey: EncodingKeys.title.rawValue) as! String
        let averageRating = coder.decodeObject(forKey: EncodingKeys.averageRating.rawValue) as! Double
        let id = coder.decodeObject(forKey: EncodingKeys.id.rawValue) as! String
        let phoneNumber = coder.decodeObject(forKey: EncodingKeys.phoneNumber.rawValue) as! String
        let openingHours = coder.decodeObject(forKey: EncodingKeys.openingHours.rawValue) as! String
        let alternativeNames = coder.decodeObject(forKey: EncodingKeys.alternativeNames.rawValue) as! PlaceAlternativeNamesLocalDBAdapter


        self.init(longitude: longitude, latitude: latitude, distance: distance, title: title, averageRating: averageRating, id: id, phoneNumber: phoneNumber, openingHours: openingHours, alternativeNames: alternativeNames)
    }
    
    init (longitude: Double, latitude: Double, distance: Int ,title: String, averageRating: Double, id: String, phoneNumber: String?, openingHours: String?, alternativeNames: PlaceAlternativeNamesLocalDBAdapter?) {
        self.longitude = longitude
        self.latitude = latitude
        self.distance = distance
        self.title = title
        self.averageRating = averageRating
        self.id = id
        self.phoneNumber = phoneNumber
        self.openingHours = openingHours
        self.alternativeNames = alternativeNames
    }
    
}

/// This class is an adapter (wrapper) to help store custom attributes -non premitives- of "Place Alternative Names" in Core data, this class implements encode function to store them.
public class PlaceAlternativeNamesLocalDBAdapter: NSObject, NSCoding {
    public var alternativeNames: [PlaceAlternativeNameLocalDBAdapter]?
    enum EncodingKeys: String {
        case alternativeNames = "alternativeNames"
    }
    public func encode(with coder: NSCoder) {
        coder.encode(alternativeNames, forKey: EncodingKeys.alternativeNames.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        let alternativeNames = coder.decodeObject(forKey: EncodingKeys.alternativeNames.rawValue) as! [PlaceAlternativeNameLocalDBAdapter]
        self.init(alternativeNames: alternativeNames)
    }
    
    init(alternativeNames: [PlaceAlternativeNameLocalDBAdapter]?) {
        self.alternativeNames = alternativeNames
    }
    
}

/// This class is an adapter (wrapper) to help store custom attributes -non premitives- of "Place Alternative Name" in Core data, this class implements encode function to store them.
public class PlaceAlternativeNameLocalDBAdapter: NSObject, NSCoding {
    
    public var name: String?
    public var language: String?

    enum EncodingKeys: String {
        case name = "name"
        case language = "language"
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(name, forKey: EncodingKeys.name.rawValue)
        coder.encode(language, forKey: EncodingKeys.language.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        let name = coder.decodeObject(forKey: EncodingKeys.name.rawValue) as! String
        let language = coder.decodeObject(forKey: EncodingKeys.language.rawValue) as! String
        self.init(name: name, language: language)
        
    }
    
    init (name: String?, language: String?) {
        self.name = name
        self.language = language
    }
    
}
