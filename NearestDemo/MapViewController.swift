//
//  ViewController.swift
//  NearstDemo
//
//  Created by Amjad on 2/24/21.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var currentLocation: LocationObject? {
        didSet {
            guard currentLocation != nil else {return}
            if let currentLocationCoordinates = currentLocation?.coordinate {
                mapView.centerToLocation(currentLocationCoordinates)
            }
            preCache()
        }
    }
    
    var preCachedLocations: [String: [SearchResultItem]] = [:]
    
    let predictedCommonSearches = ["hotel".localized,"cafe".localized,"gas".localized,"supermarket".localized]
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        guard let searchText = searchTextField.text, !searchText.isEmpty else {
            handleEmptySearchText()
            return
        }
        
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        if (predictedCommonSearches.contains(searchText)) {
            if preCachedLocations.hasKey(key: searchText), let items = preCachedLocations[searchText] {
                self.showItemsOnMap(items: items)
            }
        }else {
            search(searchText: searchText, completionHandler: { items in
                self.showItemsOnMap(items: items)
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initLocation()
        checkPresistantStore()
    }
    
    func initUI() {
        self.view.backgroundColor = AppColors.MainAppColor
        searchButton.setTitle("searchButtonTitle".localized, for: .normal)
        searchButton.backgroundColor = AppColors.MainButtonsBackgroundColor
        searchButton.tintColor = .white
        searchButton.setRoundedCorners(cornerRadius: 8)
        
        mapView.setRoundedCorners(cornerRadius: 8)
        mapView.delegate = self
        
        searchTextField.placeholder = "searchHere".localized
        searchTextField.delegate = self

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
    
    func checkPresistantStore() {
        let oldPlacesData = CoreDataUtils.getMapItems()
        if  oldPlacesData.count > 0 {
            showItemsOnMapFromPresistantStore(placesData: oldPlacesData)
        }
    }
    
    func handleEmptySearchText() {
        searchTextField.shake()
    }
    
    func handleNoLocationData() {
        initLocation()
    }
    
    func search(showLoading: Bool = true,searchText: String, completionHandler: @escaping (_ items: [SearchResultItem])->()) {
        if showLoading {
            enterLodingState()
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
            self.exitLodingState()
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
            self.exitLodingState()
        }
    }
    
    func preCache() {
        for commonSearch in predictedCommonSearches {
            if (commonSearch == self.searchTextField.text) {
                continue
            }
            self.search(showLoading: false, searchText: commonSearch) { (items) in
                self.preCachedLocations[commonSearch] = items
            }
        }
    }
    
    func enterLodingState() {
        self.mapView.isUserInteractionEnabled = false
        let alert = UIAlertController(title: nil, message: "loading".localized, preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.tintColor = .gray
        loadingIndicator.startAnimating()
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        alert.view.addSubview(loadingIndicator)
        loadingIndicator.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 10).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor).isActive = true
        present(alert, animated: true, completion: nil)

    }
    
    func exitLodingState() {
        self.mapView.isUserInteractionEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    func showItemsOnMapFromPresistantStore(placesData: [PlaceDataEntity]) {
        let lastLongitude = UserDefaults.standard.double(forKey: UserDefaultsKeys.lastUserLongitudeKey)
        let lastLatitude = UserDefaults.standard.double(forKey: UserDefaultsKeys.lastUserLatitudeKey)
        let lastCoordinates = CLLocationCoordinate2D(latitude: lastLatitude, longitude: lastLongitude)
        mapView.centerToLocation(lastCoordinates)
        mapView.addAnnotation(UserLocationMapAnnotationObject(title: "myLocation".localized, coordinate: lastCoordinates))

        
        for placeData in placesData {
            let mapAnnotationObject = MapAnnotationObject.init(title: placeData.title, coordinate: CLLocationCoordinate2D(latitude: placeData.latitude, longitude: placeData.longitude), distance: Int(placeData.distance), rating: placeData.averageRating, openingHours: placeData.openingHours, phone: placeData.phoneNumber)
            self.mapView.addAnnotation(mapAnnotationObject)
        }
    }
    
    func showItemsOnMap(items: [SearchResultItem]) {
        if let currentLocationCoordinates = currentLocation?.coordinate {
            mapView.centerToLocation(currentLocationCoordinates)
            mapView.addAnnotation(UserLocationMapAnnotationObject(title: "myLocation".localized, coordinate: currentLocationCoordinates))
        }
        var placesData = [PlaceDataLocalDBAdapter]()
        for item in items {
            if let longitude = item.coordinates?.longitude, let latitude = item.coordinates?.latitude, let title = item.title, let id = item.id, let coordinates = item.coordinates {
               
                let mapAnnotationObject = MapAnnotationObject.init(title: title, coordinate: coordinates, distance: item.distance, rating:  item.averageRating, openingHours: item.openingHours?.text, phone: item.contacts?.phone?.first?.value)
                self.mapView.addAnnotation(mapAnnotationObject)
                
                var placesAlternativeNames = [PlaceAlternativeNameLocalDBAdapter]()
                if let alternativeNames = item.alternativeNames {
                    for alternativeName in alternativeNames {
                        let placeAlternativeName = PlaceAlternativeNameLocalDBAdapter(name: alternativeName.name, language: alternativeName.language)
                        placesAlternativeNames.append(placeAlternativeName)
                    }
                }
               
                let storableAlternativeNamesObject = PlaceAlternativeNamesLocalDBAdapter(alternativeNames: placesAlternativeNames)
                let placeData = PlaceDataLocalDBAdapter(longitude: longitude, latitude: latitude, distance: item.distance ?? 0, title: title, averageRating: item.averageRating ?? 0, id: id, phoneNumber: item.contacts?.phone?.first?.value, openingHours: item.openingHours?.text, alternativeNames: storableAlternativeNamesObject)
                placesData.append(placeData)
            }
        }
        CoreDataUtils.deleteAllMapItems()
        CoreDataUtils.saveMapItems(items: placesData)
        
        UserDefaults.standard.set(self.currentLocation?.coordinate.longitude, forKey: UserDefaultsKeys.lastUserLongitudeKey)
        UserDefaults.standard.set(self.currentLocation?.coordinate.latitude, forKey: UserDefaultsKeys.lastUserLatitudeKey)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = LocationObject.init(name: nil, location: manager.location, placemark: nil)
        self.locationManager.stopUpdatingLocation()
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MapAnnotationObject {
            let identifier = String(describing: MapAnnotationObject.self)
            
            var view: MKMarkerAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
              dequeuedView.annotation = annotation
              view = dequeuedView
            } else {
              view = MKMarkerAnnotationView(annotation: annotation,reuseIdentifier: identifier)
            }
            view.markerTintColor = AppColors.MainButtonsBackgroundColor

            return view
        } else if (annotation as? UserLocationMapAnnotationObject) != nil {
            let identifier = String(describing: "userLocation")
            var view: MKMarkerAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
              dequeuedView.annotation = annotation
              view = dequeuedView
            } else {
              view = MKMarkerAnnotationView(annotation: annotation,reuseIdentifier: identifier)
            }
            view.markerTintColor = .blue
            return view
        }
        
        let identifier = String(describing: MapAnnotationObject.self)
        
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
          dequeuedView.annotation = annotation
          view = dequeuedView
        } else {
          view = MKMarkerAnnotationView(annotation: annotation,reuseIdentifier: identifier)
        }
        view.markerTintColor = AppColors.MainButtonsBackgroundColor

        return view

        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MapAnnotationObject {
            let vc = PlaceDetailsViewControlelr.instantiate(fromAppStoryboard: .Main)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
            vc.mapAnnotationObject = annotation
        } else if (view.annotation as? UserLocationMapAnnotationObject) != nil {
            return
        }
    }
}

extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}


private extension MKMapView {
  func centerToLocation(
    _ location: CLLocationCoordinate2D,
    regionRadius: CLLocationDistance = 1000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}
