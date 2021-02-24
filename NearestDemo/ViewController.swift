//
//  ViewController.swift
//  NearstDemo
//
//  Created by Amjad on 2/24/21.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    
    let locationManager = CLLocationManager()
    var location: LocationObject?

    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        initLocation()
    }
    
    func search() {
        guard let searchText = searchTextField.text, !searchText.isEmpty else {
            handleEmptySearchText()
            return
        }
        
        guard let location = self.location else {
            handleNoLocationData()
            return
        }
        
        
        NetworkUtils.searchNearby(searchText: searchText, location: location.address) { (result) in
            switch result {
            case .success(let response):
                print(response.results?.items?.first?.title)
            case .failure(let error):
                print("error" , error)
                break
            }
        } networkIssue: { (error) in
            print(error.localizedDescription)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    func initUI() {
        searchButton.setTitle("searchButtonTitle".localized, for: .normal)
        searchButton.setRoundedCorners(cornerRadius: 16)
    }
    
    func initLocation() {
        // Ask for Authorisation from the User.
//        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func handleEmptySearchText() {
        
    }
    
    func handleNoLocationData() {
        
    }


}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = LocationObject.init(name: nil, location: manager.location, placemark: nil)
        self.locationManager.stopUpdatingLocation()
        search()
    }

}

