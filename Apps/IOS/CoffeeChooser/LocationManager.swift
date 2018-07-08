//
//  LocationManager.swift
//  CoffeeChooser
//
//  Created by Antonio Hung on 12/28/17.
//  Copyright © 2017 Dark Bear Interactive. All rights reserved.
//

import UIKit
import CoreLocation

extension Notification.Name {
	static let locationDidChange = Notification.Name("locationDidChange")
	static let locationStatusChanged = Notification.Name("locationStatusChanged")
	static let locationDidFail = Notification.Name("locationDidFail")
}

class LocationManager: NSObject, CLLocationManagerDelegate {

	static let shared = LocationManager()
	let locationManager = CLLocationManager()
	var currentLocation:CLLocationCoordinate2D?
	
	private override init() {
		super.init()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
	}
	func getLocation() {
		locationManager.requestWhenInUseAuthorization()

		if CLLocationManager.locationServicesEnabled() {
			locationManager.startUpdatingLocation()
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		guard let location:CLLocationCoordinate2D = locations.first?.coordinate else {
			return
		}
		let userInfo : [String : CLLocationCoordinate2D] = ["location" : location]
		
		DispatchQueue.main.async() { () -> Void in
			self.locationManager.stopUpdatingLocation()
			NotificationCenter.default.post(name: .locationDidChange, object: nil, userInfo: userInfo)
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		
		if (status != .denied && status != .notDetermined) {
			locationManager.startUpdatingLocation()
		}
		
		let userInfo : [String : CLAuthorizationStatus] = ["status" : status]
		DispatchQueue.main.async() { () -> Void in
			NotificationCenter.default.post(name: .locationStatusChanged, object: nil, userInfo: userInfo)
		}
		
	}
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("error", error)
		DispatchQueue.main.async() { () -> Void in
			NotificationCenter.default.post(name: .locationDidFail, object: nil, userInfo: nil)
		}
	}
}

protocol LocationManagerDelegate {
	func locationUpdated(location:CLLocationCoordinate2D)
	func didChangeAuthorization(status:CLAuthorizationStatus)
}
