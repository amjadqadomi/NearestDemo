//
//  ViewController.swift
//  NearstDemo
//
//  Created by Amjad on 2/24/21.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var location: LocationObject? {
        didSet {
            guard location != nil else {return}
            if let currentLocation = location?.coordinate {
                mapView.centerToLocation(currentLocation)
            }
            preCache()
        }
    }
    
    var preCachedLocations: [String: [SearchResultItem]] = [:]
    
    let predictedCommonSearches = ["hotel","cafe","gas","supermarket"]
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        CoreDataUtils.getMapItems()
        guard let searchText = searchTextField.text, !searchText.isEmpty else {
            handleEmptySearchText()
            return
        }
        
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
    
    func search(showLoading: Bool = true,searchText: String, completionHandler: @escaping (_ items: [SearchResultItem])->()) {
        if showLoading {
            enterLodingState()
        }
        var initialLocation = location
        #if targetEnvironment(simulator)
        if location == nil {
        initialLocation = LocationObject.init(name: nil, location: CLLocation(latitude: 32.227970, longitude: 35.217105), placemark: nil)
        }else {
            initialLocation = location
        }
        #else
        let initialLocation = location
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


    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initLocation()
    }
    
    func initUI() {
        self.view.backgroundColor = AppColors.MainAppColor
        searchButton.setTitle("searchButtonTitle".localized, for: .normal)
        searchButton.backgroundColor = AppColors.MainButtonsBackgroundColor
        searchButton.tintColor = .white
        searchButton.titleEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
        searchButton.setRoundedCorners(cornerRadius: 8)
        
        mapView.setRoundedCorners(cornerRadius: 8)
        mapView.delegate = self
        
        searchTextField.placeholder = "searchHere".localized

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
    
    func handleEmptySearchText() {
        
    }
    
    func handleNoLocationData() {
        
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

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.tintColor = .gray
        loadingIndicator.startAnimating()

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)

    }
    
    func exitLodingState() {
        self.mapView.isUserInteractionEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    
    func showItemsOnMap(items: [SearchResultItem]) {
        if let currentLocation = location?.coordinate {
            mapView.centerToLocation(currentLocation)
        }
        var ss = [StorableMapItemObject]()
        for item in items {
            if let longitude = item.coordinates?.longitude, let latitude = item.coordinates?.latitude, let title = item.title, let id = item.id, let coordinates = item.coordinates {
               
                let mapLocation = MapLocation.init(title: title, coordinate: coordinates, distance: item.distance, rating:  item.averageRating, openingHours: item.openingHours?.text, phone: item.contacts?.phone?.first?.value)
                self.mapView.addAnnotation(mapLocation)
                
                var storableAlternativeNames = [StorableAlternativeName]()
                if let alternativeNames = item.alternativeNames {
                    for alternativeName in alternativeNames {
                        let storableAlternativeName = StorableAlternativeName(name: alternativeName.name, language: alternativeName.language)
                        storableAlternativeNames.append(storableAlternativeName)
                    }
                }
               
                let storableAlternativeNamesObject = StorableAlternativeNames(alternativeNames: storableAlternativeNames)
                let storabale = StorableMapItemObject(longitude: longitude, latitude: latitude, title: title, averageRating: item.averageRating, id: id, isOpen: item.openingHours?.isOpen, openingHours: item.openingHours?.text, alternativeNames: storableAlternativeNamesObject)
                ss.append(storabale)
            }
        }
        CoreDataUtils.deleteAllMapItems()
        CoreDataUtils.saveMapItems(items: ss)
    }


}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = LocationObject.init(name: nil, location: manager.location, placemark: nil)
        self.locationManager.stopUpdatingLocation()
    }

}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MapLocation else {
            return nil
        }
        
        let identifier = String(describing: MapLocation.self)
        
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
        guard let annotation = view.annotation as? MapLocation else { return }
        let vc = PlaceDetailsViewControlelr.instantiate(fromAppStoryboard: .Main)
        self.present(vc, animated: true, completion: nil)
        vc.mapLocation = annotation
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
