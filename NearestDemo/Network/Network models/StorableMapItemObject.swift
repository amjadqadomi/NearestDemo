//
//  StorableMapItemObject.swift
//  NearestDemo
//
//  Created by Amjad on 2/25/21.
//

import Foundation

public class StorableMapItemObject: NSObject, NSCoding {
    
    public var longitude: Double
    public var latitude: Double
    public var title: String?
    public var averageRating: Double?
    public var id: String
    public var isOpen: Bool?
    public var openingHours: String?
    public var alternativeNames: StorableAlternativeNames?

    
    enum EncodingKeys: String {
        case longitude = "longitude"
        case latitude = "latitude"
        case title = "title"
        case averageRating = "averageRating"
        case id = "id"
        case isOpen = "isOpen"
        case openingHours = "openingHours"
        case alternativeNames = "alternativeNames"

    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(longitude, forKey: EncodingKeys.longitude.rawValue)
        coder.encode(latitude, forKey: EncodingKeys.latitude.rawValue)
        coder.encode(title, forKey: EncodingKeys.title.rawValue)
        coder.encode(averageRating, forKey: EncodingKeys.averageRating.rawValue)
        coder.encode(id, forKey: EncodingKeys.id.rawValue)
        coder.encode(isOpen, forKey: EncodingKeys.isOpen.rawValue)
        coder.encode(openingHours, forKey: EncodingKeys.openingHours.rawValue)
        coder.encode(alternativeNames, forKey: EncodingKeys.alternativeNames.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        let longitude = coder.decodeObject(forKey: EncodingKeys.longitude.rawValue) as! Double
        let latitude = coder.decodeObject(forKey: EncodingKeys.latitude.rawValue) as! Double
        let title = coder.decodeObject(forKey: EncodingKeys.title.rawValue) as! String
        let averageRating = coder.decodeObject(forKey: EncodingKeys.averageRating.rawValue) as! Double
        let id = coder.decodeObject(forKey: EncodingKeys.id.rawValue) as! String
        let isOpen = coder.decodeObject(forKey: EncodingKeys.isOpen.rawValue) as! Bool
        let openingHours = coder.decodeObject(forKey: EncodingKeys.openingHours.rawValue) as! String
        let alternativeNames = coder.decodeObject(forKey: EncodingKeys.alternativeNames.rawValue) as! StorableAlternativeNames


        self.init(longitude: longitude, latitude: latitude, title: title, averageRating: averageRating, id: id, isOpen: isOpen, openingHours: openingHours, alternativeNames: alternativeNames)
    }
    
    init (longitude: Double, latitude: Double, title: String, averageRating: Double?, id: String, isOpen: Bool?, openingHours: String?, alternativeNames: StorableAlternativeNames?) {
        self.longitude = longitude
        self.latitude = latitude
        self.title = title
        self.averageRating = averageRating
        self.id = id
        self.isOpen = isOpen
        self.openingHours = openingHours
        self.alternativeNames = alternativeNames
    }
    
}

public class StorableAlternativeNames: NSObject, NSCoding {
    public var alternativeNames: [StorableAlternativeName]?
    enum EncodingKeys: String {
        case alternativeNames = "alternativeNames"
    }
    public func encode(with coder: NSCoder) {
        coder.encode(alternativeNames, forKey: EncodingKeys.alternativeNames.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        let alternativeNames = coder.decodeObject(forKey: EncodingKeys.alternativeNames.rawValue) as! [StorableAlternativeName]
        self.init(alternativeNames: alternativeNames)
    }
    
    init(alternativeNames: [StorableAlternativeName]?) {
        self.alternativeNames = alternativeNames
    }
    
}

public class StorableAlternativeName: NSObject, NSCoding {
    
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
