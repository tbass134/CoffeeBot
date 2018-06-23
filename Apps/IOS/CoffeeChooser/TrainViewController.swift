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


class TrainViewController: UIViewController  {

	var ref: DatabaseReference!

    var jsonData:JSON?
	var lastlocation:CLLocationCoordinate2D?
	var locationLoaded = false
	let hotCoffeeImage = UIImage.init(named: "coffee_hot")
	let icedCoffeeImage = UIImage.init(named: "coffee_iced")
    
	@IBOutlet weak var collectionView: UICollectionView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
		
		_ = LocationManager.shared.getLocation()
		
		NotificationCenter.default.addObserver(self, selector: #selector(locationUpdated(notification:)), name: .locationDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(locationStatusChanged(notification:)), name: Notification.Name.locationStatusChanged, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(locationError(notification:)), name: Notification.Name.locationDidFail, object: nil)
		
		
		self.collectionView.reloadData()
		
		// Create the info button
		let infoButton = UIButton(type: .infoLight)
		infoButton.addTarget(self, action: #selector(aboutBtnSelected), for: .touchUpInside)
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
    }
	
   override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
	
	func locationUpdated(notification: NSNotification) {
		guard let location = notification.userInfo!["location"] as? CLLocationCoordinate2D else {
			return
		}
		
		print("locations = \(location.latitude) \(location.longitude)")
		self.lastlocation = nil
		self.collectionView.reloadData()
		OpenWeatherAPI.sharedInstance.weatherDataFor(location: location, completion: {
			(response: JSON?) in
			self.jsonData = response
			self.lastlocation = location
			self.collectionView.reloadData()
			
		})
	}
	
	func locationStatusChanged(notification: NSNotification) {
		guard let status = notification.userInfo!["status"] as? CLAuthorizationStatus else {
			return
		}
		
		if status == .denied {
			presentAlert(title: "Location Access required", message: "Access to your current location is required")
		}
	}
	
	func locationError(notification:Notification) {
		presentAlert(title: "Unable to aquire location", message: "Please try again.")
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
		
        // Dispose of any resources that can be recreated.
    }

    @IBAction func aboutBtnSelected(_ sender: Any) {
        
        let alert = UIAlertController(title: "About this app.", message: "Whenever you reach for a cup of coffee, open this app and select the type of coffee your are drinking (hot or iced) This will help the application be able to perdict what type of coffee you will have in the future", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }));
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveItem(_ coffeeType:Coffee) {
		
//		#if (arch(i386) || arch(x86_64))
//		return
//		#endif
		
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
			
			
			if let user = Auth.auth().currentUser {
				
				item.userId = user.uid
				
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

extension TrainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 2
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
		
		if (indexPath.row == 0) {
			cell.imageView.image = hotCoffeeImage
			cell.label.text = "Hot Coffee"
		} else if (indexPath.row == 1) {
			cell.imageView.image = icedCoffeeImage
			cell.label.text = "Iced Coffee"
		}
		
		if (self.lastlocation == nil) {
			cell.imageView.image = self.Noir(image: cell.imageView.image!)
		} else {
			if (indexPath.row == 0) {
				cell.imageView.image = hotCoffeeImage
			} else if (indexPath.row == 1) {
				cell.imageView.image = icedCoffeeImage
			}
		}
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		switch kind {
		case UICollectionElementKindSectionHeader:
			let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
																			 withReuseIdentifier: "header",
																			 for: indexPath) as! HeaderView
			headerView.label.text = "Select the type of coffee you are currently having"
			return headerView
		default:
			assert(false, "Unexpected element kind")
		}
	}
	
	func Noir(image:UIImage) -> UIImage {
		let context = CIContext(options: nil)
		let currentFilter = CIFilter(name: "CIPhotoEffectNoir")
		currentFilter!.setValue(CIImage(image: image), forKey: kCIInputImageKey)
		let output = currentFilter!.outputImage
		let cgimg = context.createCGImage(output!,from: output!.extent)
		let processedImage = UIImage(cgImage: cgimg!)
		return processedImage
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if (self.lastlocation == nil) {
			return
		}
		
		if (indexPath.row == 0) {
			saveItem(Coffee.Hot)
		} else if (indexPath.row == 1) {
			saveItem(Coffee.Iced)
		}
	}
}

class CollectionViewCell:UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var label: UILabel!
}

class HeaderView: UICollectionReusableView {
	@IBOutlet weak var label: UILabel!
	
}
