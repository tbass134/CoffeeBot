//
//  INIntent+extensions.swift
//  CoffeeChooser
//
//  Created by Antonio Hung on 9/7/18.
//  Copyright © 2018 Dark Bear Interactive. All rights reserved.
//

import Foundation
import Intents

extension INIntent {
	
	func donate(_ identifier:String) {
		let interaction = INInteraction(intent: self, response: nil)
		// The order identifier is used to match with the donation so the interaction
		// can be deleted
		interaction.identifier = identifier
		interaction.donate { (error) in
			if error != nil {
				if let error = error as NSError? {
					print("Interaction donation failed: %@", error)
				}
			} else {
				print("Successfully donated interaction")
			}
		}
	}
}
