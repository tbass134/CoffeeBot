//
//  SelectIcedCoffeeIntentHandler.swift
//  SiriKit
//
//  Created by Tony Hung on 8/29/18.
//  Copyright © 2018 Dark Bear Interactive. All rights reserved.
//

import Foundation
import Firebase

public class SelectIcedCoffeeIntentHandler:NSObject, SelectIcedCoffeeIntentHandling {
    public func handle(intent: SelectIcedCoffeeIntent, completion: @escaping (SelectIcedCoffeeIntentResponse) -> Void) {
      
        
        guard let lastLoc = LocationManager.shared.lastLocation() else {
            let response = SelectIcedCoffeeIntentResponse(code: .failure, userActivity: nil)
            completion(response)
            return
        }
    
        CoffeeTypeTrain.shared.train(lastLoc, coffeeType: .Iced) { (success) in
            if success {
                let response = SelectIcedCoffeeIntentResponse(code: .success, userActivity: nil)
                completion(response)
            } else {
                let response = SelectIcedCoffeeIntentResponse(code: .failure, userActivity: nil)
                completion(response)
            }
        }
    }
}
