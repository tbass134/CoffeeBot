//
//  UIViewController+Extensions.swift
//  CoffeeBot
//
//  Created by Antonio Hung on 6/23/18.
//  Copyright © 2018 Dark Bear Interactive. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
	
	func defaultAction(_ alert:UIAlertController) -> UIAlertAction {
		return UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
			alert.dismiss(animated: true, completion: nil)
		})
	}
	
	func locationServicesAction() -> UIAlertAction {
		let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
			guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
				return
			}
			
			if UIApplication.shared.canOpenURL(settingsUrl) {
				UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
			}
		}
		
		return settingsAction
	}
	
	func presentAlert(title:String, message:String? = nil, actions:[UIAlertAction]? = nil) {
		let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
		alert.addAction(defaultAction(alert));
		if actions != nil {
			for action in actions! {
				alert.addAction(action)
			}
		}
		self.present(alert, animated: true, completion: nil)
	}
}


class SuperViewController:UIViewController {
	override func viewDidLoad() {
		self.view.backgroundColor = UIColorFromRGB(0xdcc58a)
		super.viewDidLoad()
	}
	
	func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
		return UIColor(
			red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
			alpha: CGFloat(1.0)
		)
	}
}

