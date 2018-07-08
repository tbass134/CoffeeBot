//
//  UIImage+extension.swift
//  CoffeeBot
//
//  Created by Antonio Hung on 7/6/18.
//  Copyright © 2018 Dark Bear Interactive. All rights reserved.
//

import UIKit

extension UIImage {
	func Noir() -> UIImage {
		let context = CIContext(options: nil)
		let currentFilter = CIFilter(name: "CIPhotoEffectNoir")
		currentFilter!.setValue(CIImage(image: self), forKey: kCIInputImageKey)
		let output = currentFilter!.outputImage
		let cgimg = context.createCGImage(output!,from: output!.extent)
		let processedImage = UIImage(cgImage: cgimg!)
		return processedImage
	}
}

