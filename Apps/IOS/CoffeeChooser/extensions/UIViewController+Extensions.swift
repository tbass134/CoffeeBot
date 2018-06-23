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
	
	func presentAlert(title:String, message:String? = nil) {
		let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
			alert.dismiss(animated: true, completion: nil)
		}));
		self.present(alert, animated: true, completion: nil)
	}
}
