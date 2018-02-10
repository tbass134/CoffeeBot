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

class PredictViewController: UIViewController, LocationManagerDelegate {

	var locationManager:LocationManager?
	var lastLocation:CLLocationCoordinate2D?

	@IBOutlet weak var class_image: UIImageView!
	@IBOutlet weak var location_txt: UILabel!
	@IBOutlet weak var predict_label: UILabel!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		locationManager = LocationManager()
		locationManager?.delegate = self
        // Do any additional setup after loading the view.
    }

	func locationUpdated(location: CLLocationCoordinate2D) {

		lastLocation = location
		predict()
 	}
	
	func didChangeAuthorization(status: CLAuthorizationStatus) {
		if status == .denied {
			let alert = UIAlertController(title: "Location Access required", message: "Access to your current location is required", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
				alert.dismiss(animated: true, completion: nil)
			}));
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	@IBAction func predictAction(_ sender: Any) {
		predict()
	}
	
	func predict() {
		
		self.class_image.image = nil
		self.predict_label.text = ""
		self.location_txt.text = ""
		
		guard let location = self.lastLocation else {
			return
		}
		
			
		OpenWeatherAPI.sharedInstance.weatherDataFor(location: location, completion: {
			(response: JSON?) in
			
			guard let json = response else {
				return
			}
			
			if #available(iOS 11.0, *) {
				let model = coffee_prediction()
				guard let mlMultiArray = try? MLMultiArray(shape:[9,1], dataType:MLMultiArrayDataType.double) else {
					fatalError("Unexpected runtime error. MLMultiArray")
				}
				let values = [json["clouds"]["all"].doubleValue,
							  json["main"]["humidity"].doubleValue,
							  json["coord"]["lat"].doubleValue,
							  json["coord"]["lon"].doubleValue,
							  json["main"]["pressure"].doubleValue,
							  round(json["main"]["temp"].doubleValue),
							  round(json["visibility"].doubleValue),
							  json["wind"]["deg"].doubleValue,
							  round(json["wind"]["speed"].doubleValue)]
				
				print(values)
				for (index, element) in values.enumerated() {
					mlMultiArray[index] = NSNumber(floatLiteral: element )
				}
				let input = coffee_predictionInput(input: mlMultiArray)
				guard let prediction =  try? model.prediction(input: input) else {
					return
				}
				let result = prediction.classLabel
				print("result \(result)")
				
				if result == 1 {
					self.class_image.image = #imageLiteral(resourceName: "Hot Coffee")
					self.predict_label.text = "Hot Coffee"
				} else {
					self.class_image.image = #imageLiteral(resourceName: "Iced Coffee")
					self.predict_label.text = "Iced Coffee"
				}
				
				let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
				
				CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) -> Void in
					print(loc)
					
					if error != nil {
						print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
						return
					}
					
					guard let pm = placemarks?.first, let locality = pm.locality, let administrativeArea = pm.administrativeArea,  let country = pm.country else {
						return
					}
					
					self.location_txt.text = locality + ", " + administrativeArea + " " + country
					
				})
			} else {
				// Fallback on earlier versions
			}
		})
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
