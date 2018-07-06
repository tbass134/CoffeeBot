//
//  Float+extensions.swift
//  CoffeeBot
//
//  Created by Antonio Hung on 7/6/18.
//  Copyright © 2018 Dark Bear Interactive. All rights reserved.
//

import Foundation

extension Float {
	func roundToInt() -> Int{
		let value = Int(self)
		let f = self - Float(value)
		if f < 0.5{
			return value
		} else {
			return value + 1
		}
	}
}
