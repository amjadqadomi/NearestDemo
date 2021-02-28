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
    
    ///this method tells the delegate to show places on the map
    ///- Parameters:
    /// - placesData: `[PlaceDataLocalDBAdapter]` the places that should be shown on map
    /// - location: `LocationObject?` the user's location
    func showPlacesOnMap(placesData: [PlaceDataLocalDBAdapter], location: LocationObject?)
    
    ///this method tells the delegate to show an error message to the user
    /// - Parameter errorMessage: `String` the error message that should be displayed
    func errorFetchingPlaces(errorMessage: String)
    
}

///MapViewModel class is the class responsible for holding the data of the map view
class MapViewModel: NSObject {
    
    weak var mapViewDelegate: MapViewModelDelegate?
    let locationManager = CLLocationManager()
    var preCachedLocations: [String: [PlaceDataLocalDBAdapter]] = [:]
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
    
    
    private func initLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func handleNoLocationData() {
        initLocation()
    }
    
    ///this method will save the latest places shown on map to core data and will also save user's last location
    ///- Parameters:
    /// - placesData: `[PlaceDataLocalDBAdapter]` the places that should be saved to core data
    private func savePlacesToCoreData(placesData: [PlaceDataLocalDBAdapter]) {
        savePlacesDataToPersistentStore(placesData: placesData)
        saveLastLocationToPersistentStorage()
    }
    
    ///this method saves the user's latest search results to persistent storage
    private func savePlacesDataToPersistentStore(placesData: [PlaceDataLocalDBAdapter]) {
        coreDataManager.deleteAllPlaces()
        coreDataManager.savePlaces(places: placesData)
    }
    
    ///this method saves the user's latest location to persistent storage
    private func saveLastLocationToPersistentStorage() {
        UserDefaults.standard.set(currentLocation?.coordinate.longitude, forKey: UserDefaultsKeys.lastUserLongitudeKey)
        UserDefaults.standard.set(currentLocation?.coordinate.latitude, forKey: UserDefaultsKeys.lastUserLatitudeKey)
    }
    ///this method calls the Places API for anticipated words the user will search for and caches the response to avoid loading UI
    private func preCache() {
        for commonSearch in predictedCommonSearches {
            self.fetchPlacesFromServer(showLoading: false, searchText: commonSearch) { (items) in
                let placesDataCoreDataFormat = self.convertDataFromNetworkFormatToLocalFormat(places: items)
                self.preCachedLocations[commonSearch] = placesDataCoreDataFormat
            } networkIssue: { error in
                //handle errors
                self.mapViewDelegate?.errorFetchingPlaces(errorMessage: "tryAgain".localized)
            }
        }
    }
    
    ///this method calls fetche the Places API and searches for places around the user current location
    /// - Parameter searchText: `String` the text which will be used to search for places around the user location
    func startSearch(searchText: String) {
        if (predictedCommonSearches.contains(searchText)) {
            if preCachedLocations.hasKey(key: searchText), let items = preCachedLocations[searchText] {
                self.savePlacesToCoreData(placesData: items)
                self.mapViewDelegate?.showPlacesOnMap(placesData: items, location: self.currentLocation)
            }
        }else {
            fetchPlacesFromServer(showLoading: true,searchText: searchText, completionHandler: { items in
                let placesDataCoreDataFormat = self.convertDataFromNetworkFormatToLocalFormat(places: items)
                self.savePlacesToCoreData(placesData: placesDataCoreDataFormat)
                self.mapViewDelegate?.showPlacesOnMap(placesData: placesDataCoreDataFormat, location: self.currentLocation)
            }, networkIssue: { error in
                // handle error
                self.mapViewDelegate?.errorFetchingPlaces(errorMessage: "tryAgain".localized)
            })
        }
    }
    
    ///this method will check if the user had searched for places in the past by checking core data records and if so it will notify the delegate about these places to show them on the map
    func checkPresistentStorage() {
        let latestPlacesData = coreDataManager.getLatestPlaces()
        if  latestPlacesData.count > 0 {
            let lastLongitude = UserDefaults.standard.double(forKey: UserDefaultsKeys.lastUserLongitudeKey)
            let lastLatitude = UserDefaults.standard.double(forKey: UserDefaultsKeys.lastUserLatitudeKey)
            let lastLocation = LocationObject(name: nil, location: CLLocation(latitude: lastLatitude, longitude: lastLongitude), placemark: nil)
            let placesData = convertDataFromCoreDataFormatToLocalFormat(places: latestPlacesData)
            self.mapViewDelegate?.showPlacesOnMap(placesData: placesData, location: lastLocation)
        }
    }
    
    ///this method will convert places data from search items response (backend) to local place objects
    /// - Parameters:
    /// - places: `[SearchResultItem]` the places records from network response
    /// - Returns: `[PlaceDataLocalDBAdapter]` array of local places objects
    private func convertDataFromNetworkFormatToLocalFormat(places: [SearchResultItem]) -> [PlaceDataLocalDBAdapter]  {
        var placesData = [PlaceDataLocalDBAdapter]()
        for place in places {
            if let longitude = place.coordinates?.longitude, let latitude = place.coordinates?.latitude, let title = place.title, let id = place.id {
                var placesAlternativeNames = [PlaceAlternativeNameLocalDBAdapter]()
                if let alternativeNames = place.alternativeNames {
                    for alternativeName in alternativeNames {
                        let placeAlternativeName = PlaceAlternativeNameLocalDBAdapter(name: alternativeName.name, language: alternativeName.language)
                        placesAlternativeNames.append(placeAlternativeName)
                    }
                }
               
                let storableAlternativeNamesObject = PlaceAlternativeNamesLocalDBAdapter(alternativeNames: placesAlternativeNames)
                let placeData = PlaceDataLocalDBAdapter(longitude: longitude, latitude: latitude, distance: place.distance ?? 0, title: title, averageRating: place.averageRating ?? 0, id: id, phoneNumber: place.contacts?.phone?.first?.value, openingHours: place.openingHours?.text, alternativeNames: storableAlternativeNamesObject)
                placesData.append(placeData)
            }
        }
        return placesData
    }
    
    
    ///this method will convert places data from coredata records to local place objects
    /// - Parameters:
    /// - places: `[PlaceDataEntity]` the places records from core data
    /// - Returns: `[PlaceDataLocalDBAdapter]` array of local places objects
    private func convertDataFromCoreDataFormatToLocalFormat(places: [PlaceDataEntity]) -> [PlaceDataLocalDBAdapter] {
        var placesData = [PlaceDataLocalDBAdapter]()
        for place in places {
            if let id = place.id {
                var placesAlternativeNames = [PlaceAlternativeNameLocalDBAdapter]()
                if let alternativeNames = place.alternativeNames?.alternativeNames {
                    for alternativeName in alternativeNames {
                        let placeAlternativeName = PlaceAlternativeNameLocalDBAdapter(name: alternativeName.name, language: alternativeName.language)
                        placesAlternativeNames.append(placeAlternativeName)
                    }
                }
                
                let storableAlternativeNamesObject = PlaceAlternativeNamesLocalDBAdapter(alternativeNames: placesAlternativeNames)
                let placeData = PlaceDataLocalDBAdapter(longitude: place.longitude, latitude: place.latitude, distance: Int(place.distance), title: place.title ?? "", averageRating: place.averageRating, id: id, phoneNumber: place.phoneNumber, openingHours: place.openingHours, alternativeNames: storableAlternativeNamesObject)
                placesData.append(placeData)
            }
        }
        return placesData
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
        #if targetEnvironment(simulator)
        if currentLocation == nil {
            currentLocation = LocationObject.init(name: nil, location: CLLocation(latitude: 32.227970, longitude: 35.217105), placemark: nil)
        }
        #endif
        
        guard let currentLocation = currentLocation else {
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
