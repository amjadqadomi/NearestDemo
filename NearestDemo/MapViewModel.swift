//
//  MapViewModel.swift
//  NearestDemo
//
//  Created by Amjad on 2/26/21.
//

import Foundation
import CoreLocation

protocol MapViewModelDelegate: AnyObject {
    ///this method notifies the delegate that there has been a location update
    /// - Parameter currentLocation: `LocationObject?` the latest location update
    func updatedLocation(currentLocation: LocationObject?)
    ///this method notifies the delegate that it started fetching data to show appropiate loading UI
    func startedFetchingPlaces()
    ///this method notifies the delegate that it finished fetching data to hide loading UI
    func finishedFetchingPlaces()
    ///this method tells the delegate to show items on the map
    ///- Parameters:
    /// - placesData: `[PlaceDataEntity]` the places that should be shown on map in persistent storage format
    /// - location: `LocationObject` the user's location
    func showItemsOnMapFromPersistantStore(placesData: [PlaceDataEntity], location: LocationObject)
    ///this method tells the delegate to show items on the map
    ///- Parameters:
    /// - items: `[SearchResultItem]` the places that should be shown on map in response from server format
    /// - location: `LocationObject?` the user's location
    func showItemsOnMapFromNetwork(items: [SearchResultItem], currentLocation: LocationObject?)
    ///this method tells the delegate to show an error message to the user
    /// - Parameter errorMessage: `String` the error message that should be displayed
    func errorFetchingPlaces(errorMessage: String)
}

///MapViewModel class is the class responsible for holding the data of the map view
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
    ///this method calls the Places API for anticipated words the user will search for and caches the response to avoid loading UI
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
    
    ///this method calls fetches the Places API and searches for places around the user current location
    /// - Parameter searchText: `String` the text which will be used to search for places around the user location
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
    
    ///this method will check if the user had searched for places in the past by checking core data records and if so it will notify the delegate about these places to show them on the map
    func checkPresistantStore() {
        let oldPlacesData = coreDataManager.getPlace()
        if  oldPlacesData.count > 0 {
            let lastLongitude = UserDefaults.standard.double(forKey: UserDefaultsKeys.lastUserLongitudeKey)
            let lastLatitude = UserDefaults.standard.double(forKey: UserDefaultsKeys.lastUserLatitudeKey)
            let lastLocation = LocationObject(name: nil, location: CLLocation(latitude: lastLatitude, longitude: lastLongitude), placemark: nil)
            self.mapViewDelegate?.showItemsOnMapFromPersistantStore(placesData: oldPlacesData, location: lastLocation)
        }
    }
    
    
    ///this method will fetch the places data from the Places API and notify the delegate
    /// - Parameters:
    /// - showLoading: `Bool` this parameter decides to show loading UI or not
    /// - searchText: `String` the text which will be used to search for places around the user location
    /// - completionHandler: `(_ items: [SearchResultItem])->()` the completion handler which will be called returning the fetched places once the fetch proccess is completed
    /// - networkIssue: `(_ error: Error) -> Void` failure handler that will be called in case an error occures
    private func fetchPlacesFromServer(showLoading: Bool = true, searchText: String, completionHandler: @escaping (_ items: [SearchResultItem])->(), networkIssue: @escaping (_ error: Error) -> Void) {
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
