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
    var textLog = TextLog()
    var backgrounded = false

	private override init() {
		super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name:NSNotification.Name.UIApplicationDidBecomeActive,  object: nil)

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
    
    func locationFound(_ newLocation:CLLocation) {
        print("Location found: \(newLocation)")
        
        if self.backgrounded {
            self.textLog.write("newLocation \(newLocation)\n")
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
        print("Failed with err: \(error)")
        DispatchQueue.main.async() { () -> Void in
            NotificationCenter.default.post(name: .locationDidFail, object: nil, userInfo: nil)
        }
    }
    
    
    
    @objc func willResignActive(_ notification: Notification) {
        // code to execute
        backgrounded = true
        print("willResignActive")
    }
    @objc func didBecomeActive(_ notification: Notification) {
        // code to execute
        backgrounded = false
        print("didBecomeActive")
    }
    
}

protocol LocationManagerDelegate {
	func locationUpdated(location:CLLocationCoordinate2D)
	func didChangeAuthorization(status:CLAuthorizationStatus)
}

struct TextLog: TextOutputStream {
    
    /// Appends the given string to the stream.
    mutating func write(_ string: String) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        let documentDirectoryPath = paths.first!
        let log = documentDirectoryPath.appendingPathComponent("log.txt")
        
        do {
            let handle = try FileHandle(forWritingTo: log)
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
        } catch {
            print(error.localizedDescription)
            do {
                try string.data(using: .utf8)?.write(to: log)
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
}
