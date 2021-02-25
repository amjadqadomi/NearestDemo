//
//  GlobalKeys.swift
//  NearstDemo
//
//  Created by Amjad on 2/24/21.
//

import Foundation


/*****  Please Add Any Global Keys Here *****/
struct WebService {
    static let baseURL = "https://places.demo.api.here.com/"
    static let nearbyURL = "places/v1/discover/search"
    static let placesAppId = "DemoAppId01082013GAL"
    static let placesAppCode = "AJKnXv84fjrb0KIHawS0Tg"
    static let searchSizeLimit = 10
}

struct WebServiceParameters {
    static let searchTextParameterKey = "q"
    static let currentLocationParameterKey = "at"
    static let placesAppIdParameterKey = "app_id"
    static let placesAppCodeParameterKey = "app_code"
    static let resultSizeParameterKey = "size"
}

struct UserDefaultsKeys {
    static let lastUserLongitudeKey = "lastLong"
    static let lastUserLatitudeKey = "lastLat"
}
