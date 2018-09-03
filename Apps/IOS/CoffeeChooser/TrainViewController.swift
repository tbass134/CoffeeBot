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
import SwiftLocation
import Intents
import IntentsUI


class TrainViewController: SuperViewController, CoffeeCellDelegate  {
    

	var ref: DatabaseReference!

    var jsonData:JSON?
	var lastlocation:CLLocation?
    
	var locationLoaded = false
	let hotCoffeeImage = UIImage.init(named: "coffee_hot")
	let icedCoffeeImage = UIImage.init(named: "coffee_iced")
    
	@IBOutlet weak var collectionView: UICollectionView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
		NotificationCenter.default.addObserver(self, selector: #selector(locationUpdated(notification:)), name: .locationDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(locationStatusChanged(notification:)), name: Notification.Name.locationStatusChanged, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(locationError(notification:)), name: Notification.Name.locationDidFail, object: nil)
        
    
		self.collectionView.reloadData()
		self.collectionView.backgroundColor = UIColor.clear
		
		// Create the info button
		let infoButton = UIButton(type: .infoLight)
		infoButton.addTarget(self, action: #selector(aboutBtnSelected), for: .touchUpInside)
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
    }
	
   override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        guard let lastLoc = LocationManager.shared.lastLocation() else {
            weatherDataLoaded(nil)
            return
        }
        weatherDataLoaded(lastLoc)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
	
	func locationUpdated(notification: NSNotification) {
		guard let location = notification.userInfo!["location"] as? CLLocation else {
            weatherDataLoaded(nil)

			return
		}
        weatherDataLoaded(location)
		
	}
    
    func weatherDataLoaded(_ location:CLLocation?) {
        
        print("locations",location?.coordinate)
        self.lastlocation = location
        self.collectionView.reloadData()
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
		
		presentAlert(title: "About this app.", message: "Whenever you reach for a cup of coffee, open this app and select the type of coffee your are drinking (hot or iced) This will help the application be able to perdict what type of coffee you will have in the future")
    }
    
    func saveItem(_ coffeeType:Coffee) {
		
		print("selected")

		#if (arch(i386) || arch(x86_64))
//        return
		#endif
		
        guard let location = self.lastlocation else {
            return
        }
        
        CoffeeTypeTrain.shared.train(location, coffeeType: coffeeType) { (success) in
            
            let alert = UIAlertController(title: "Coffee Type Saved", message: "Your input was saved! Come back again to enter your enter coffee type when you order more coffee!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }));
            self.present(alert, animated: true, completion: nil)

        }
		
        
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
        cell.delegate = self
		
		if (indexPath.row == 0) {
            cell.type = Coffee.Hot
			cell.imageView.image = hotCoffeeImage
			cell.label.text = "Hot Coffee"
		} else if (indexPath.row == 1) {
            cell.type = Coffee.Iced

			cell.imageView.image = icedCoffeeImage
			cell.label.text = "Iced Coffee"
		}
		
		if (self.lastlocation == nil) {
			cell.imageView.image = cell.imageView.image!.Noir()
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
		
		return UICollectionReusableView()
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
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		if #available(iOS 11.0, *) {
			return CGSize(width: (view.safeAreaLayoutGuide.layoutFrame.width), height: 200)
		} else {
			// Fallback on earlier versions
			return CGSize(width: (collectionView.frame.size.width), height: 200)
		}
	}
    
    func siriButtonTapped(cell: CollectionViewCell) {
        print(cell.type)
        
        guard let type = cell.type else {
            return
        }
        if #available(iOS 12.0, *) {
            if type == .Hot {
                //SelectHotCoffeeIntent
                let selectHotCoffeeIntent = SelectHotCoffeeIntent()

                if let shortcut = INShortcut(intent: selectHotCoffeeIntent) {
                    let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
                    viewController.modalPresentationStyle = .formSheet
                    viewController.delegate = self as? INUIAddVoiceShortcutViewControllerDelegate // Object conforming to `INUIAddVoiceShortcutViewControllerDelegate`.
                    present(viewController, animated: true, completion: nil)
                }
            } else {
                //SelectIcedCoffeeIntent
                let selectIcedCoffeeIntent = SelectIcedCoffeeIntent()
                
                if let shortcut = INShortcut(intent: selectIcedCoffeeIntent) {
                    let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
                    viewController.modalPresentationStyle = .formSheet
                    viewController.delegate = self as? INUIAddVoiceShortcutViewControllerDelegate // Object conforming to `INUIAddVoiceShortcutViewControllerDelegate`.
                    present(viewController, animated: true, completion: nil)
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

@available(iOS 12.0, *)
extension TrainViewController: INUIAddVoiceShortcutViewControllerDelegate {
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



class CollectionViewCell:UICollectionViewCell {
    var type:Coffee?
    var delegate:CoffeeCellDelegate?
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            
        }
    }
    @IBOutlet weak var label: UILabel! {
        didSet {
            
        }
    }
    @IBOutlet weak var siriView: UIView! {
        didSet {
            if #available(iOS 12.0, *) {

                let button = INUIAddVoiceShortcutButton(style: .white)
                button.translatesAutoresizingMaskIntoConstraints = false

                siriView.addSubview(button)
                siriView.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
                siriView.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
                button.addTarget(self, action: #selector(self.addToSiri(_:)), for: .touchUpInside)
            }
        }
    }
    
    @objc func addToSiri(_ sender: Any) {
        print("here")
        delegate?.siriButtonTapped(cell: self)
        
    }

    
	override var isHighlighted: Bool {
		didSet{
			if self.isHighlighted {
				imageView.alpha = 0.5
			}
			else {
				imageView.alpha = 1
			}
		}
	}

}

class HeaderView: UICollectionReusableView {
	@IBOutlet weak var label: UILabel! {
		didSet {
			label.font = UIFont.init(name: "Helvetica Neue", size: 16)
		}
	}
	
}

protocol CoffeeCellDelegate {
    func siriButtonTapped(cell:CollectionViewCell)
}
