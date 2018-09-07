//
//  C.swift
//  CoffeeChooser
//
//  Created by Tony Hung on 8/29/18.
//  Copyright © 2018 Dark Bear Interactive. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON
import CoreML
import Firebase
import SwiftLocation

class CoffeeTypeTrain {

    static let shared = CoffeeTypeTrain()
    
    func train(_ location:CLLocation, coffeeType:Coffee, completion: @escaping (_ success:Bool) -> Void) {
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        OpenWeatherAPI.sharedInstance.weatherDataFor(location: location.coordinate, completion: {
            (response: JSON?) in
        
            guard let json = response else {
                return
            }
			
			LocationManager.shared.geocodeLocation(location.coordinate, completion: { (place) in
				guard let p = place, let postalCode = p.postalCode else {
					return
				}
				
				var item = CoffeeOrder(userId: nil,
									   type: coffeeType.rawValue,
									   date: Date.init(),
									   temp: json["main"]["temp"].intValue,
									   humidity: json["main"]["humidity"].floatValue,
									   location: json["name"].stringValue,
									   lat:json["coord"]["lat"].floatValue,
									   lon:json["coord"]["lon"].floatValue,
									   weatherCond: json["weather"][0]["main"].stringValue,
									   clouds: json["clouds"]["all"].intValue,
									   visibility: json["visibility"].intValue,
									   windSpeed: json["wind"]["speed"].intValue,
									   windDeg: json["wind"]["deg"].floatValue,
									   pressure:  json["main"]["pressure"].floatValue,
									   zipcode:postalCode)
				
				if let user = Auth.auth().currentUser {
					
					item.userId = user.uid
					var ref = Database.database().reference()
					let coffeeSelectionRef = ref.child(UUID().uuidString)
					coffeeSelectionRef.setValue(item.toAnyObject())
					completion(true)
				}
			})
        })
    }

}
