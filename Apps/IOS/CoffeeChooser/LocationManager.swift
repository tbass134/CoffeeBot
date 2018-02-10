//
//  LocationManager.swift
//  CoffeeChooser
//
//  Created by Antonio Hung on 12/28/17.
//  Copyright © 2017 Dark Bear Interactive. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {

	let locationManager = CLLocationManager()
	var delegate:LocationManagerDelegate?
	
	override init() {
		super.init()
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		guard let locValue:CLLocationCoordinate2D = locations.first?.coordinate else {
			return
		}
		locationManager.stopUpdatingLocation()
		print("locations = \(locValue.latitude) \(locValue.longitude)")
		delegate?.locationUpdated(location: locValue)
	}
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		delegate?.didChangeAuthorization(status: status)
	}
}

protocol LocationManagerDelegate {
	func locationUpdated(location:CLLocationCoordinate2D)
	func didChangeAuthorization(status:CLAuthorizationStatus)
}
