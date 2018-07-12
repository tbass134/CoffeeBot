//
//  WeatherViewController.swift
//  CoffeeBot
//
//  Created by Antonio Hung on 7/1/18.
//  Copyright © 2018 Dark Bear Interactive. All rights reserved.
//

import UIKit
import SwiftSVG
import SwiftyJSON

class WeatherViewController: UIViewController {

	@IBOutlet weak var iconView: UIView!
	@IBOutlet  var tempLabel: UILabel!
	@IBOutlet weak var conditionLabel: UILabel!
	@IBOutlet weak var locationLabel: UILabel! {
		didSet {
			locationLabel.text = ""
		}
	}
	@IBOutlet weak var highLabel: UILabel!
	@IBOutlet weak var lowLabel: UILabel!

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	

	var weatherData:JSON? {
		didSet {
			loadWeatherIcon(weatherData!)
			let temp = (weatherData!["main"]["temp"].floatValue).roundToInt()
			self.tempLabel.text = String(temp) + "°F"
			self.highLabel.text = String(weatherData!["main"]["temp_max"].floatValue.roundToInt()) + "°F"
			self.lowLabel.text = String(weatherData!["main"]["temp_min"].floatValue.roundToInt()) + "°F"
			self.conditionLabel.text = weatherData!["weather"][0]["main"].stringValue
		}
	}
	
	func loadWeatherIcon(_ weatherData:JSON) {
		
		let jsonPath = Bundle.main.path(forResource: "icons", ofType: "json")
		let jsonData = try! NSData(contentsOfFile: jsonPath!, options: NSData.ReadingOptions.alwaysMapped)
		let json = JSON(data: jsonData as Data)
		
		let weatherIcon = weatherData["weather"][0]["id"]
		let weatherIconCode = weatherIcon.intValue
		let weatherIconString = weatherIcon.stringValue
		let icon = json[weatherIconString]["icon"].stringValue;
		
		let prefix = "wi-";
		var iconStr:String?
		if (!(weatherIconCode > 699 && weatherIconCode < 800) && !(weatherIconCode > 899 && weatherIconCode < 1000)) {
			iconStr = "day-" + icon;
		} else {
			iconStr = icon
		}
		
		let svgURL = Bundle.main.url(forResource: prefix + iconStr!, withExtension: "svg")!
		let _ = CALayer(SVGURL: svgURL) { (svgLayer) in
			// Set the fill color
			svgLayer.fillColor = UIColor(red:0.94, green:0.37, blue:0.00, alpha:1.00).cgColor
			// Aspect fit the layer to self.view
			svgLayer.resizeToFit(self.iconView.bounds)
			// Add the layer to self.view's sublayers
			self.iconView.layer.addSublayer(svgLayer)
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
