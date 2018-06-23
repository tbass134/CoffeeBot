//
//  Notification+Extension.swift
//  CoffeeBot
//
//  Created by Antonio Hung on 6/23/18.
//  Copyright © 2018 Dark Bear Interactive. All rights reserved.
//

import Foundation

extension Notification.Name {
	static let locationDidChange = Notification.Name("locationDidChange")
	static let locationDidFail = Notification.Name("locationDidFail")
}
