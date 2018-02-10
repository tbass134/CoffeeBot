//
//  OpenWeatherAPI.swift
//  CoffeeChooser
//
//  Created by Antonio Hung on 5/26/17.
//  Copyright © 2017 Dark Bear Interactive. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation
import SwiftyJSON

class OpenWeatherAPI {
    
    let baseURL = "http://api.openweathermap.org/data/2.5"
    let apiKey = OPEN_WEATHER_API_KEY

    static let sharedInstance = OpenWeatherAPI()

    func weatherDataFor(location:CLLocationCoordinate2D, completion: @escaping (_ response: JSON?) -> Void) {
        let url = "\(baseURL)/weather?lat=\(location.latitude)&lon=\(location.longitude)&appid=\(apiKey)&units=imperial"
        print(url)
        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success:
                
                guard let value = response.result.value else {
                    completion(nil)
                    return
                }
                let responseJSON = JSON(value)
                
                completion(responseJSON)
    
            case .failure(let error):
                print(error)
            }
        }
    }
}
