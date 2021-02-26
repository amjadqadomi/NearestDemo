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
    
    var mapViewModel = MapViewModel()// the model which holds all the data
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        guard let searchText = searchTextField.text, !searchText.isEmpty else {
            handleEmptySearchText()
            return
        }
        
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        mapViewModel.startSearch(searchText: searchText)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        mapView.delegate = self
        mapViewModel.mapViewDelegate = self
        mapViewModel.checkPresistantStore()
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
    
    func handleEmptySearchText() {
        searchTextField.shake()
    }
    
    /// this function shows loading UI and blocks user interactions
    private func enterLodingState() {
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
    
    /// this function hides loading UI
    private func exitLodingState() {
        self.mapView.isUserInteractionEnabled = true
        dismiss(animated: true, completion: nil)
    }
}



extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? PlaceAnnotationObject {
            let identifier = String(describing: PlaceAnnotationObject.self)
            
            var view: MKMarkerAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
              dequeuedView.annotation = annotation
              view = dequeuedView
            } else {
              view = MKMarkerAnnotationView(annotation: annotation,reuseIdentifier: identifier)
            }
            view.markerTintColor = AppColors.MainButtonsBackgroundColor
            view.accessibilityIdentifier = annotation.id
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
        
        let identifier = String(describing: PlaceAnnotationObject.self)
        
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
        if let annotation = view.annotation as? PlaceAnnotationObject {
            let vc = PlaceDetailsViewControlelr.instantiate(fromAppStoryboard: .Main)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
            vc.placeAnnotationObject = annotation
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

extension MapViewController: MapViewModelDelegate {
    func updatedLocation(currentLocation: LocationObject?) {
        if let currentLocationCoordinates = currentLocation?.coordinate {
            mapView.centerToLocation(currentLocationCoordinates)
        }
    }
    
    func startedFetchingPlaces() {
        enterLodingState()
    }
    
    func finishedFetchingPlaces() {
        exitLodingState()
    }
    
    func showItemsOnMapFromPersistantStore(placesData: [PlaceDataEntity], location: LocationObject) {
        mapView.centerToLocation(location.coordinate)
        mapView.addAnnotation(UserLocationMapAnnotationObject(title: "myLocation".localized, coordinate: location.coordinate))
        
        for placeData in placesData {
            let placeAnnotationObject = PlaceAnnotationObject.init(title: placeData.title, coordinate: CLLocationCoordinate2D(latitude: placeData.latitude, longitude: placeData.longitude), distance: Int(placeData.distance), rating: placeData.averageRating, openingHours: placeData.openingHours, phone: placeData.phoneNumber, id: placeData.id)
            self.mapView.addAnnotation(placeAnnotationObject)
        }
    }
    
    func showItemsOnMapFromNetwork(items: [SearchResultItem], currentLocation: LocationObject?) {
        if let currentLocationCoordinates = currentLocation?.coordinate {
            mapView.centerToLocation(currentLocationCoordinates)
            mapView.addAnnotation(UserLocationMapAnnotationObject(title: "myLocation".localized, coordinate: currentLocationCoordinates))
        }
        var placesData = [PlaceDataLocalDBAdapter]()
        for item in items {
            if let longitude = item.coordinates?.longitude, let latitude = item.coordinates?.latitude, let title = item.title, let id = item.id, let coordinates = item.coordinates {
               
                let placeAnnotationObject = PlaceAnnotationObject.init(title: title, coordinate: coordinates, distance: item.distance, rating:  item.averageRating, openingHours: item.openingHours?.text, phone: item.contacts?.phone?.first?.value, id: item.id)
                self.mapView.addAnnotation(placeAnnotationObject)
                
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
        
        mapViewModel.savePlacesDataToPersistantStore(placesData: placesData)
        mapViewModel.saveLastLocationToPersistantStorage()
    }
    
    func errorFetchingPlaces(errorMessage: String) {
        let alert = UIAlertController(title: "generalError".localized, message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
