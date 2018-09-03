//
//  SelectHotCoffeeIntentHandler.swift
//  SiriKit
//
//  Created by Tony Hung on 8/29/18.
//  Copyright © 2018 Dark Bear Interactive. All rights reserved.
//

import Foundation
import Firebase

public class SelectHotCoffeeIntentHandler:NSObject, SelectHotCoffeeIntentHandling {
    public func handle(intent: SelectHotCoffeeIntent, completion: @escaping (SelectHotCoffeeIntentResponse) -> Void) {
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        guard let lastLoc = LocationManager.shared.lastLocation() else {
            let response = SelectHotCoffeeIntentResponse(code: .failure, userActivity: nil)
            completion(response)
            return
        }
        
        
        CoffeeTypeTrain.shared.train(lastLoc, coffeeType: .Hot) { (success) in
            if success {
                let response = SelectHotCoffeeIntentResponse(code: .success, userActivity: nil)
                completion(response)
            } else {
                let response = SelectHotCoffeeIntentResponse(code: .failure, userActivity: nil)
                completion(response)
            }
        }
       
        
    }
    
    
}
