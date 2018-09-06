	//
//  PredictViewController.swift
//  CoffeeChooser
//
//  Created by Antonio Hung on 12/27/17.
//  Copyright © 2017 Dark Bear Interactive. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import CoreML
import Firebase
import Intents
import IntentsUI
import SwiftLocation

class PredictViewController: SuperViewController {

	var lastLocation:CLLocationCoordinate2D?
    

    @IBOutlet weak var iconHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var class_image: UIImageView!
	@IBOutlet weak var predict_label: UILabel!
	var weatherView:WeatherViewController? {
		didSet {
			weatherView?.view.isHidden = true
		}
	}
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !LocationManager.shared.hasAccess() {
            locationError(notification: Notification.init(name: Notification.Name(rawValue: "")))
        }
        
        guard let lastLoc = LocationManager.shared.lastLocation() else {
            return
        }
        predict(lastLoc.coordinate)
    }
    
    
	override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdated(notification:)), name: .locationDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationError(notification:)), name: Notification.Name.locationDidFail, object: nil)
        
		if (Int((UIApplication.shared.windows.first?.frame.size.height)!) < 600) {
			iconHeightConstraint.constant = 200
		}
        
        if #available(iOS 12.0, *) {
            INPreferences.requestSiriAuthorization { (status) in

                if status != .authorized {
                    return
                }
                let intent = GetCoffeeTypeIntent()
                intent.suggestedInvocationPhrase = "What coffee should I drink?"

                let addShortcutButton = INUIAddVoiceShortcutButton(style: .whiteOutline)
                addShortcutButton.shortcut = INShortcut(intent: intent)
                addShortcutButton.delegate = self

                addShortcutButton.translatesAutoresizingMaskIntoConstraints = false
                self.weatherView?.siriView.addSubview(addShortcutButton)
                self.weatherView?.siriView.centerXAnchor.constraint(equalTo: addShortcutButton.centerXAnchor).isActive = true
                self.weatherView?.siriView.centerYAnchor.constraint(equalTo: addShortcutButton.centerYAnchor).isActive = true
                
            }

        }

    }
    
	func locationUpdated(notification: NSNotification) {
		guard let location = notification.userInfo!["location"] as? CLLocation else {
			return
		}
		lastLocation = location.coordinate
		predict(location.coordinate)
 	}
	
	func locationError(notification:Notification) {
		presentAlert(title: "Unable to aquire location", message: "Please try again.")
		self.predict_label.text = "Location Not Determined"
        self.weatherView?.view.isHidden = true
        self.class_image.image = UIImage.init(named: "unknown")

	}
	
	@IBAction func predictAction(_ sender: Any) {
       LocationManager.shared.getCurrentLocation()
	}
	
	func predict(_ location:CLLocationCoordinate2D) {
	
		self.class_image.image = nil
		self.predict_label.text = ""
		
        CoffeeTypePrediction.shared.predict(location) { (result, json) in
            guard let result = result, let json = json else {
                return
            }
            
            if #available(iOS 12.0, *) {
                let getCoffeeTypeIntent = GetCoffeeTypeIntent()
                getCoffeeTypeIntent.suggestedInvocationPhrase = "What coffee should I drink?"

                let interaction = INInteraction(intent: getCoffeeTypeIntent, response: nil)
                // The order identifier is used to match with the donation so the interaction
                // can be deleted if a soup is removed from the menu.
                interaction.identifier = "predict"
                interaction.donate { (error) in
                    if error != nil {
                        if let error = error as NSError? {
                            print("Interaction donation failed: %@", error)
                        }
                    } else {
                        print("Successfully donated interaction")
                    }
                }
            }

            self.weatherView?.weatherData = json
            self.weatherView?.view.isHidden = false
            
            print("classLabel \(result.classLabel)")
            
            if result.classLabel == 1 {
                self.class_image.image = UIImage.init(named: "coffee_hot")
                self.predict_label.text = "Hot Coffee"
            } else {
                self.class_image.image = UIImage.init(named: "coffee_iced")
                self.predict_label.text = "Iced Coffee"
            }
            
            let percent = Int(round(result.classProbability[result.classLabel]! * 100))
            self.predict_label.text = self.predict_label.text! + "\n(\(percent)% confidence)"
            
            Locator.location(fromCoordinates: location, locale: nil, using: .apple, timeout: nil, onSuccess: { (place) -> (Void) in
                guard let pm = place.first, let locality = pm.city, let administrativeArea = pm.administrativeArea else {
                    return
                }
                self.weatherView?.locationLabel.text = locality + ", " + administrativeArea

            }, onFail: { (error) -> (Void) in
                print("Reverse geocoder failed with error",error)
            })
        }
    
	}
	
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "weatherView" {
			weatherView = segue.destination as? WeatherViewController
		}
	}
	

}
@available(iOS 12.0, *)
extension PredictViewController: INUIAddVoiceShortcutButtonDelegate {
    
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.delegate = self
        present(addVoiceShortcutViewController, animated: true, completion: nil)
    }
    
    /// - Tag: edit_phrase
    
    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.delegate = self
        present(editVoiceShortcutViewController, animated: true, completion: nil)
    }
}

@available(iOS 12.0, *)
extension PredictViewController: INUIAddVoiceShortcutViewControllerDelegate {
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController,
                                        didFinishWith voiceShortcut: INVoiceShortcut?,
                                        error: Error?) {
        if let error = error as NSError? {
            print(error)
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

@available(iOS 12.0, *)
extension PredictViewController: INUIEditVoiceShortcutViewControllerDelegate {
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController,
                                         didUpdate voiceShortcut: INVoiceShortcut?,
                                         error: Error?) {
        if let error = error as NSError? {
            print(error)
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController,
                                         didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
