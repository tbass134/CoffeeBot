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
	static let locationStatusChanged = Notification.Name("locationStatusChanged")
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
    
    func startReceivingSignificantLocationChanges() {
        Locator.requestAuthorizationIfNeeded(.always)
        
        Locator.subscribeSignificantLocations(onUpdate: { newLocation in
            print("New location \(newLocation)")
            
            let defaults = UserDefaults(suiteName: "group.com.tonyhung.coffeechooser")
            let archived = NSKeyedArchiver.archivedData(withRootObject: newLocation)
            defaults?.set(archived, forKey: "location")
            
            let userInfo : [String : CLLocation] = ["location" : newLocation]
            DispatchQueue.main.async() { () -> Void in
                NotificationCenter.default.post(name: .locationDidChange, object: nil, userInfo: userInfo)
            }
        }) { (err, lastLocation) -> (Void) in
            print("Failed with err: \(err)")
            DispatchQueue.main.async() { () -> Void in
                NotificationCenter.default.post(name: .locationDidFail, object: nil, userInfo: nil)
            }
        }
    }
}

protocol LocationManagerDelegate {
	func locationUpdated(location:CLLocationCoordinate2D)
	func didChangeAuthorization(status:CLAuthorizationStatus)
}
