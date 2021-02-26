//
//  MapViewModel.swift
//  NearestDemo
//
//  Created by Amjad on 2/26/21.
//

import Foundation
import CoreLocation

protocol MapViewModelDelegate: AnyObject {
    func updatedLocation(currentLocation: LocationObject?)
    func startedFetchingPlaces()
    func finishedFetchingPlaces()
    func showItemsOnMapFromPersistantStore(placesData: [PlaceDataEntity], location: LocationObject)
    func showItemsOnMapFromNetwork(items: [SearchResultItem], currentLocation: LocationObject?)
    func errorFetchingPlaces(errorMessage: String)
}

class MapViewModel: NSObject {
    
    weak var mapViewDelegate: MapViewModelDelegate?
    let locationManager = CLLocationManager()
    var preCachedLocations: [String: [SearchResultItem]] = [:]
    let predictedCommonSearches = ["hotel".localized,"cafe".localized,"gas".localized,"supermarket".localized]
    let coreDataManager = CoreDataManager()
    var currentLocation: LocationObject? {
        didSet {
            guard let currentLocation = currentLocation else {return}
            mapViewDelegate?.updatedLocation(currentLocation: currentLocation)
            preCache()
        }
    }
    
    
    override init() {
        super.init()
        coreDataManager.setup(completion: nil)
        initLocation()
    }
    
    
    func initLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func handleNoLocationData() {
        initLocation()
    }
    
    func savePlacesDataToPersistantStore(placesData: [PlaceDataLocalDBAdapter]) {
        coreDataManager.deleteAllPlaces()
        coreDataManager.savePlaces(places: placesData)
    }
    
    func saveLastLocationToPersistantStorage() {
        UserDefaults.standard.set(currentLocation?.coordinate.longitude, forKey: UserDefaultsKeys.lastUserLongitudeKey)
        UserDefaults.standard.set(currentLocation?.coordinate.latitude, forKey: UserDefaultsKeys.lastUserLatitudeKey)
    }
    
    func preCache() {
        for commonSearch in predictedCommonSearches {
            self.fetchPlacesFromServer(showLoading: false, searchText: commonSearch) { (items) in
                self.preCachedLocations[commonSearch] = items
            } networkIssue: { error in
                //handle error
                self.mapViewDelegate?.errorFetchingPlaces(errorMessage: "tryAgain".localized)
            }
        }
    }
    
    func startSearch(searchText: String) {
        if (predictedCommonSearches.contains(searchText)) {
            if preCachedLocations.hasKey(key: searchText), let items = preCachedLocations[searchText] {
                self.mapViewDelegate?.showItemsOnMapFromNetwork(items: items, currentLocation: self.currentLocation)
            }
        }else {
            fetchPlacesFromServer(showLoading: true,searchText: searchText, completionHandler: { items in
                self.mapViewDelegate?.showItemsOnMapFromNetwork(items: items, currentLocation: self.currentLocation)
            }, networkIssue: { error in
                // handle error
                self.mapViewDelegate?.errorFetchingPlaces(errorMessage: "tryAgain".localized)
            })
        }
    }
    
    func checkPresistantStore() {
        let oldPlacesData = coreDataManager.getPlace()
        if  oldPlacesData.count > 0 {
            let lastLongitude = UserDefaults.standard.double(forKey: UserDefaultsKeys.lastUserLongitudeKey)
            let lastLatitude = UserDefaults.standard.double(forKey: UserDefaultsKeys.lastUserLatitudeKey)
            let lastLocation = LocationObject(name: nil, location: CLLocation(latitude: lastLatitude, longitude: lastLongitude), placemark: nil)
            self.mapViewDelegate?.showItemsOnMapFromPersistantStore(placesData: oldPlacesData, location: lastLocation)
        }
    }
    
    
    
    func fetchPlacesFromServer(showLoading: Bool = true, searchText: String, completionHandler: @escaping (_ items: [SearchResultItem])->(), networkIssue: @escaping (_ error: Error) -> Void) {
        if showLoading {
            mapViewDelegate?.startedFetchingPlaces()
        }
        var initialLocation = currentLocation
        #if targetEnvironment(simulator)
        if currentLocation == nil {
        initialLocation = LocationObject.init(name: nil, location: CLLocation(latitude: 32.227970, longitude: 35.217105), placemark: nil)
        }else {
            initialLocation = currentLocation
        }
        #else
        let initialLocation = currentLocationCoordinates
        #endif
                
                
        guard let currentLocation = initialLocation else {
            handleNoLocationData()
            return
        }
        
        
        NetworkUtils.searchNearby(searchText: searchText, location: currentLocation.address) { (result) in
            self.mapViewDelegate?.finishedFetchingPlaces()
            switch result {
            case .success(let response):
                if let items = response.results?.items {
                    completionHandler(items)
                }
            case .failure(let error):
                print("error" , error)
                break
            }
        } networkIssue: { (error) in
            print(error.localizedDescription)
            networkIssue(error)
            self.mapViewDelegate?.finishedFetchingPlaces()
        }
    }
    
    
    

}

extension MapViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = LocationObject.init(name: nil, location: manager.location, placemark: nil)
        self.locationManager.stopUpdatingLocation()
    }
}
