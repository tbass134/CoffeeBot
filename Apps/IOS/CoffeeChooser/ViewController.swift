//
//  ViewController.swift
//  CoffeeChooser
//
//  Created by Antonio Hung on 5/26/17.
//  Copyright © 2017 Dark Bear Interactive. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import Firebase
import FirebaseDatabase

enum Coffee:Int {
    case Hot = 1
    case Iced = 0
}

struct SelectedItem {
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
    var userId:String?
    var type:Int
    var date:Date
    var temp:Int
    var humidity:Float
    var location:String
//    var coords:CLLocationCoordinate2D
	var lat:Float
	var lon:Float
    var weatherCond:String
    var clouds:Int
    var visibility:Int
    var windSpeed:Int
    var windDeg:Float
    var pressure:Float
	var zipcode:String
	
    func toAnyObject() -> Any {
        return [
            "type": type,
            "date": formatter.string(from: date),
            "temp": temp,
            "humidity":humidity,
            "location":location,
            "lat":lat,
            "lon":lon,
            "weatherCond":weatherCond,
            "clouds":clouds,
            "visibility":visibility,
            "windSpeed":windSpeed,
            "windDeg":windDeg,
            "pressure":pressure,
			"zipcode":zipcode,
            "userId":userId!
        ]
    }
}

class ViewController: UIViewController,  LocationManagerDelegate {

    @IBOutlet weak var icedCoffeBtn: UIButton!
    @IBOutlet weak var hotCoffeeBtn: UIButton!
    var ref: DatabaseReference!

    var jsonData:JSON?
	var lastlocation:CLLocationCoordinate2D?
	var locationManager:LocationManager?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var mainView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
		locationManager = LocationManager()
		locationManager?.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
//        self.scrollView.contentSize = CGSize(width: 0, height: 1000)
    }
    
   override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.icedCoffeBtn.isEnabled = false
        self.hotCoffeeBtn.isEnabled = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
	
	func locationUpdated(location: CLLocationCoordinate2D) {

        print("locations = \(location.latitude) \(location.longitude)")
        
        OpenWeatherAPI.sharedInstance.weatherDataFor(location: location, completion: {
            (response: JSON?) in
            self.jsonData = response
			self.lastlocation = location
            self.icedCoffeBtn.isEnabled = true
            self.hotCoffeeBtn.isEnabled = true
        })
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func hotCoffeeSelected(_ sender: Any) {
        saveItem(Coffee.Hot)
    }

    @IBAction func icedCoffeeSelected(_ sender: Any) {
         saveItem(Coffee.Iced)
    }
    @IBAction func aboutBtnSelected(_ sender: Any) {
        
        let alert = UIAlertController(title: "About this app.", message: "Whenever you reach for a cup of coffee, open this app and select the type of coffee your are drinking (hot or iced) This will help the application be able to perdict what type of coffee you will have in the future", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }));
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveItem(_ coffeeType:Coffee) {
		#if (arch(i386) || arch(x86_64))
		return
		#endif
		
        guard let json = self.jsonData, let location = self.lastlocation else {
            return
        }
		
		let clLoc  = CLLocation(latitude:location.latitude, longitude:location.longitude)
		
		CLGeocoder().reverseGeocodeLocation(clLoc, completionHandler: {(placemarks, error) -> Void in
			
			if error != nil {
				print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
				return
			}
			
			guard let pm = placemarks?.first, let postalCode = pm.postalCode else {
				return
			}
			
			var item = SelectedItem(userId: nil, type: coffeeType.rawValue,
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
			
			Auth.auth().signInAnonymously() { (user, error) in
				
				item.userId = user!.uid
				
				let coffeeSelectionRef = self.ref.child(UUID().uuidString)
				coffeeSelectionRef.setValue(item.toAnyObject())
				let alert = UIAlertController(title: "Coffee Type Saved", message: "Your input was saved! Come back again to enter your enter coffee type when you order more coffee!", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
					alert.dismiss(animated: true, completion: nil)
				}));
				self.present(alert, animated: true, completion: nil)
			}
			
		})
		
		
		
        
        
    }
}

