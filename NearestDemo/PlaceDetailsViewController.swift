//
//  PlaceDetailsViewController.swift
//  NearestDemo
//
//  Created by Amjad on 2/25/21.
//

import Foundation
import UIKit

class PlaceDetailsViewControlelr: UIViewController {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
        
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var openingHoursLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var dismissButton : UIButton!
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    var placeAnnotationObject: PlaceAnnotationObject?  = nil {
        didSet {
            guard let placeAnnotationObject = placeAnnotationObject else {
                return
            }
            updateUI(placeAnnotationObject: placeAnnotationObject)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    func updateUI(placeAnnotationObject: PlaceAnnotationObject) {
        nameLabel.text = placeAnnotationObject.title
        distanceLabel.text = String(format:"%@: %d", "distanceLabel".localized, placeAnnotationObject.distance ?? 0)
        if (placeAnnotationObject.rating == nil || placeAnnotationObject.rating == 0) {
            ratingLabel.isHidden = true
        }else {
            ratingLabel.text = String(format:"%@: %.1f", "ratingLabel".localized, placeAnnotationObject.rating ?? 0.0)
        }
        let openingHoursCleaned = placeAnnotationObject.openingHours?.replacingOccurrences(of: "<br/>", with: ",")
        openingHoursLabel.text = String(format: "%@: %@", "openingHoursLabel".localized, openingHoursCleaned ?? "")
        phoneLabel.text = String(format: "%@: %@", "phoneNumberLabel".localized, placeAnnotationObject.phone ?? "")
    }
    
    func initUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        popUpView.setRoundedCorners(cornerRadius: 8)
        
        dismissButton.imageView?.image = UIImage(named: "xmark.circle.fill")
        dismissButton.tintColor = AppColors.MainButtonsBackgroundColor
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        distanceLabel.font = UIFont.systemFont(ofSize: 14)
        distanceLabel.textColor = AppColors.SecondaryTextColor
        ratingLabel.font = UIFont.systemFont(ofSize: 14)
        ratingLabel.textColor = AppColors.SecondaryTextColor
        openingHoursLabel.font = UIFont.systemFont(ofSize: 14)
        openingHoursLabel.textColor = AppColors.SecondaryTextColor
        phoneLabel.font = UIFont.systemFont(ofSize: 14)
        phoneLabel.textColor = AppColors.SecondaryTextColor
        
        let gestureRecognizer = UITapGestureRecognizer(target: self,
                                           action: #selector(closeButtonTapped))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
    }
}

extension PlaceDetailsViewControlelr: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    return (touch.view === self.view)
  }
}
