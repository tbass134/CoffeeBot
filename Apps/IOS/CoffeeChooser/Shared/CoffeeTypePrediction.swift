//
//  CoffeeTypePrediction.swift
//  CoffeeChooser
//
//  Created by Tony Hung on 8/28/18.
//  Copyright © 2018 Dark Bear Interactive. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON
import CoreML
//import Firebase
import Intents
import IntentsUI


class CoffeeTypePrediction {
    
    static let shared = CoffeeTypePrediction()

    func predict(_ location:CLLocationCoordinate2D, completion: @escaping (_ prediction: coffee_predictionOutput?, _ jsonResponse:JSON?) -> Void) {
        
        OpenWeatherAPI.sharedInstance.weatherDataFor(location: location, completion: {
            (response: JSON?) in
            
            guard let json = response else {
                return
            }
            

            
            if #available(iOS 11.0, *) {
                let model = coffee_prediction()
                guard let mlMultiArray = try? MLMultiArray(shape:[13,1], dataType:MLMultiArrayDataType.double) else {
                    fatalError("Unexpected runtime error. MLMultiArray")
                }
                var values = [json["clouds"]["all"].doubleValue,
                              json["main"]["humidity"].doubleValue,
                              round(json["main"]["temp"].doubleValue),
                              round(json["visibility"].doubleValue / 1609.344),
                              round(json["wind"]["speed"].doubleValue),
                              ]
                
                values.append(contentsOf: self.toOneHot(json["weather"][0]["main"].stringValue))
                for (index, element) in values.enumerated() {
                    mlMultiArray[index] = NSNumber(floatLiteral: element )
                }
                let input = coffee_predictionInput(input: mlMultiArray)
                guard let prediction = try? model.prediction(input: input) else {
                    return
                }
                
                let result = prediction
                
                print(result.classProbability)
                
                completion(result, json)
                
                
                
            } else {
                // Fallback on earlier versions
            }
        })
    }
    
    func toOneHot(_ string:String) -> [Double] {
        var str = string
        var items = [Double](repeating: 0.0, count: 8)
        let weather_conds:[String] = ["Clear", "Clouds", "Fog", "Haze", "Rain", "Smoke", "Snow", "Thunderstorm"]
        
        if str.lowercased().range(of:"cloud") != nil || str.lowercased().range(of:"overcast") != nil{
            str = "Clouds"
        }
        
        if str.lowercased().range(of:"snow") != nil {
            str = "Snow"
        }
        
        if str.lowercased().range(of:"rain") != nil  || str.lowercased().range(of:"drizzle") != nil || str.lowercased().range(of:"mist") != nil{
            str = "Rain"
        }
        
        if str.lowercased().range(of:"none") != nil {
            str = "Clear"
        }
        
        guard let index = weather_conds.index(of: str) else {
            items[0] = 1
            return items
        }
        
        items[index] = 1
        return items
    }
}
