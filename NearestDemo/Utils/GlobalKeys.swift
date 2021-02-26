//
//  GlobalKeys.swift
//  NearstDemo
//
//  Created by Amjad on 2/24/21.
//

import Foundation


///this class holds all Webservice constants and keys
struct WebService {
    static let baseURL = "https://places.demo.api.here.com/"
    static let nearbyURL = "places/v1/discover/search"
    static let placesAppId = "DemoAppId01082013GAL"
    static let placesAppCode = "AJKnXv84fjrb0KIHawS0Tg"
    static let searchSizeLimit = 10
}

///this class holds all Webservice parameter keys which are used in requests
struct WebServiceParameters {
    static let searchTextParameterKey = "q"
    static let currentLocationParameterKey = "at"
    static let placesAppIdParameterKey = "app_id"
    static let placesAppCodeParameterKey = "app_code"
    static let resultSizeParameterKey = "size"
}

///this class holds all Userdefaults keys  which are used to store to and retrieve values from local storage
struct UserDefaultsKeys {
    static let lastUserLongitudeKey = "lastLong"
    static let lastUserLatitudeKey = "lastLat"
}
