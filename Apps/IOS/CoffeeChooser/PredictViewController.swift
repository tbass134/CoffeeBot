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
    

    @IBOutlet weak var siriView: UIView!
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
        
        guard let lastLoc = LocationManager.shared.lastLocation() else {
            return
        }
        predict(lastLoc.coordinate)
    }
    
	override func viewDidLoad() {
        super.viewDidLoad()
        
		if (Int((UIApplication.shared.windows.first?.frame.size.height)!) < 600) {
			iconHeightConstraint.constant = 200
		}
        
        _ = LocationManager.shared.startReceivingSignificantLocationChanges()
        

        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdated(notification:)), name: .locationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationStatusChanged(notification:)), name: Notification.Name.locationStatusChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationError(notification:)), name: Notification.Name.locationDidFail, object: nil)
       
        if #available(iOS 12.0, *) {
            INPreferences.requestSiriAuthorization { (status) in
                
            
            let intent = GetCoffeeTypeIntent()
//            let interaction = INInteraction(intent: intent, response: nil)
//            
//            // The order identifier is used to match with the donation so the interaction
//            // can be deleted if a soup is removed from the menu.
//            interaction.identifier = UUID().uuidString
//            
//            interaction.donate { (error) in
//                if error != nil {
//                    if let error = error as NSError? {
//                        print("Interaction donation failed: %@",  error)
//                    }
//                } else {
//                    print("Successfully donated interaction")
//                }
//            }
            
                let button = INUIAddVoiceShortcutButton(style: .white)
                button.translatesAutoresizingMaskIntoConstraints = false
                
                self.siriView.addSubview(button)
                self.siriView.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
                self.siriView.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
                button.addTarget(self, action: #selector(self.addToSiri(_:)), for: .touchUpInside)
            }

		
        } else {
            // Fallback on earlier versions
        }
        
//        button.addTarget(self, action: #selector(addToSiri(_:)), for: .touchUpInside)

    }
    
    @objc func addToSiri(_ sender: Any) {
        
//        //TODO remove after testing
        let fileManager = FileManager.default
        let documentsDirectoryPath:String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        let logPath = documentsDirectoryPath + "/log.txt"
        if(fileManager.fileExists(atPath: logPath)) {
            let c  = try! NSString(contentsOfFile: logPath, encoding: String.Encoding.utf8.rawValue)
            presentAlert(title: "logs",message: c as String)
        }
//        if #available(iOS 12.0, *) {
//            let getCoffeeTypeIntent = GetCoffeeTypeIntent()
//
//            if let shortcut = INShortcut(intent: getCoffeeTypeIntent) {
//                let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
//                viewController.modalPresentationStyle = .formSheet
//                viewController.delegate = self as? INUIAddVoiceShortcutViewControllerDelegate // Object conforming to `INUIAddVoiceShortcutViewControllerDelegate`.
//                present(viewController, animated: true, completion: nil)
//            }
//        } else {
//            // Fallback on earlier versions
//        }
    }
    
	func locationUpdated(notification: NSNotification) {
		guard let location = notification.userInfo!["location"] as? CLLocation else {
			return
		}
		lastLocation = location.coordinate
		predict(location.coordinate)
 	}
	
	func locationStatusChanged(notification: NSNotification) {
		guard let status = notification.userInfo!["status"] as? CLAuthorizationStatus else {
			return
		}
		
		if status == .denied {
			presentAlert(title: "Location Access required", message: "Access to your current location is required")
			self.predict_label.text = "Location Not Determined"
			self.class_image.image = self.class_image.image?.Noir()
			
		}
	}
	
	func locationError(notification:Notification) {
		presentAlert(title: "Unable to aquire location", message: "Please try again.")
		self.predict_label.text = "Location Not Determined"
	}
	
	@IBAction func predictAction(_ sender: Any) {
		_ = LocationManager.shared.startReceivingSignificantLocationChanges()
	}
	
	func predict(_ location:CLLocationCoordinate2D) {
	
		self.class_image.image = nil
		self.predict_label.text = ""
		
        CoffeeTypePrediction.shared.predict(location) { (result, json) in
            guard let result = result, let json = json else {
                return
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
            self.predict_label.text = self.predict_label.text! + "\n(\(percent)% probability)"
            
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
