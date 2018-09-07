//
//  LocationManager.swift
//  CoffeeChooser
//
//  Created by Antonio Hung on 12/28/17.
//  Copyright © 2017 Dark Bear Interactive. All rights reserved.
//

import UIKit
import SwiftLocation
import CoreLocation

extension Notification.Name {
	static let locationDidChange = Notification.Name("locationDidChange")
	static let locationDidFail = Notification.Name("locationDidFail")
}

class LocationManager: NSObject {

	static let shared = LocationManager()

	private override init() {
		super.init()
	}
    
    func lastLocation() ->CLLocation? {
        
        let defaults = UserDefaults(suiteName: "group.com.tonyhung.coffeechooser")
        
        guard let archived = defaults?.object(forKey: "location") as? Data, let location = NSKeyedUnarchiver.unarchiveObject(with: archived) as? CLLocation else {
            return Locator.currentLocation
        }
        
        return location
    }
    
    func hasAccess() ->Bool {
        return Locator.authorizationStatus == .authorizedAlways || Locator.authorizationStatus == .authorizedWhenInUse
    }
    
    func startReceivingSignificantLocationChanges() {
        Locator.subscribeSignificantLocations(onUpdate: { newLocation in
            print("New location \(newLocation)")
            self.locationFound(newLocation)
        }) { (error, lastLocation) -> (Void) in
            self.locationError(error,lastLocation)
        }
    }
    
    func getCurrentLocation() {
        Locator.currentPosition(accuracy: .city, timeout: nil, onSuccess: { (location) -> (Void) in
        }) { (error, lastLoc) -> (Void) in
            print("Failed to get location: \(error)")
            self.locationError(error,lastLoc)
        }
    }
	
	func geocodeLocation(_ location:CLLocationCoordinate2D, completion:@escaping (_ place: Place?) -> Void) {
		Locator.location(fromCoordinates: location, locale: nil, using: .apple, timeout: nil, onSuccess: { (place) -> (Void) in
			
			guard let pm = place.first else {
				completion(nil)
				return
			}
			completion(pm)
	
		}, onFail: { (error) -> (Void) in
			print("Reverse geocoder failed with error",error)
		})
	}
    
    func locationFound(_ newLocation:CLLocation) {
        print("Location found: \(newLocation)")
        
        if UIApplication.shared.applicationState == .background {
			print("Saved loc to background")
        }
        
        let defaults = UserDefaults(suiteName: "group.com.tonyhung.coffeechooser")
        let archived = try! NSKeyedArchiver.archivedData(withRootObject: newLocation, requiringSecureCoding: false)
        defaults?.set(archived, forKey: "location")
        
        let userInfo : [String : CLLocation] = ["location" : newLocation]
        DispatchQueue.main.async() { () -> Void in
            NotificationCenter.default.post(name: .locationDidChange, object: nil, userInfo: userInfo)
        }
    }
    
    func locationError(_ error:Error?, _ lastLoc:CLLocation?) {
		print("Failed with err: \(String(describing: error))")
        DispatchQueue.main.async() { () -> Void in
            NotificationCenter.default.post(name: .locationDidFail, object: nil, userInfo: nil)
        }
    }
}

protocol LocationManagerDelegate {
	func locationUpdated(location:CLLocationCoordinate2D)
	func didChangeAuthorization(status:CLAuthorizationStatus)
}
