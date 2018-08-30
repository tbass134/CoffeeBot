//
//  CoffeeOrder.swift
//  CoffeeChooser
//
//  Created by Tony Hung on 8/28/18.
//  Copyright © 2018 Dark Bear Interactive. All rights reserved.
//

import Foundation


enum Coffee:Int {
    case Hot = 1
    case Iced = 0
}

struct CoffeeOrder {
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
    var userId:String?
    var type:Int
    var date:Date
    var temp:Int
    var humidity:Float
    var location:String
    //    var coords:CLLocationCoordinate2D
    var lat:Float
    var lon:Float
    var weatherCond:String
    var clouds:Int
    var visibility:Int
    var windSpeed:Int
    var windDeg:Float
    var pressure:Float
    var zipcode:String
    
    func toAnyObject() -> Any {
        return [
            "type": type,
            "date": formatter.string(from: date),
            "temp": temp,
            "humidity":humidity,
            "location":location,
            "lat":lat,
            "lon":lon,
            "weatherCond":weatherCond,
            "clouds":clouds,
            "visibility":visibility,
            "windSpeed":windSpeed,
            "windDeg":windDeg,
            "pressure":pressure,
            "zipcode":zipcode,
            "userId":userId!
        ]
    }
}


@available(iOS 12.0, *)
extension CoffeeOrder {
    public var intent: GetCoffeeTypeIntent {
        let getCoffeeTypeIntent = GetCoffeeTypeIntent()
        
        getCoffeeTypeIntent.suggestedInvocationPhrase = NSString.deferredLocalizedIntentsString(with: "What coffee should i drink") as String
        
        return getCoffeeTypeIntent
    }

}

