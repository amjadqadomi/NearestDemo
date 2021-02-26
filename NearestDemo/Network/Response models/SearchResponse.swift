//
//  SearchResponse.swift
//  NearstDemo
//
//  Created by Amjad on 2/24/21.
//

import Foundation
import MapKit

///This is the search response upper level class, this class is built according to the response coming back from the places API.
struct SearchResponse: Codable {
    var results: SearchResults?
}

struct SearchResults: Codable {
    var items: [SearchResultItem]?
}

///This is the search result item response class, this class represents a single place nearby on the map and has all the information that is returned from the backend stored in it.
struct SearchResultItem: Codable {
    var position: [Double]?
    var distance: Int?
    var title: String?
    var averageRating: Double?
    var category: SearchResultCategory?
    var icon: String?
    var vicnity: String?
    var address: SearchResultAddress?
    var contacts: SearchResultContactInfo?
    var tags: [SearchResultTag]?
    var id: String?
    var openingHours: SearchResultOpeningHours?
    var alternativeNames: [AlternativeNames]?
    
    var coordinates : CLLocationCoordinate2D? {
        guard let latitude = position?.first, let longitude = position?.last else {return nil}
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct SearchResultCategory: Codable {
    var id: String?
    var title: String?
}

struct SearchResultAddress: Codable {
    var text: String?
    var house: String?
    var street: String?
    var postalCode: String?
    var district: String?
    var city: String?
    var state: String?
    var stateCode: String?
    var country: String?
    var countryCode: String?
}

struct SearchResultContactInfo: Codable {
    var phone: [SearchResultContactInfoItem]?
    var website: [SearchResultContactInfoItem]?
}

struct SearchResultContactInfoItem: Codable {
    var value: String?
    var label: String?
}

struct SearchResultTag: Codable {
    var id: String?
    var title: String?
    var group: String?
}

struct SearchResultOpeningHours: Codable {
    var text: String?
    var label: String?
    var isOpen: Bool?
}

struct AlternativeNames: Codable {
    var name: String?
    var language: String?
}

