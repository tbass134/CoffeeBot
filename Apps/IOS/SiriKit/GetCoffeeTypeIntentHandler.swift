/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Intent handler for `OrderSoupIntent`.
 */

import UIKit
import SwiftLocation

public class GetCoffeeTypeIntentHandler: NSObject, GetCoffeeTypeIntentHandling {
    
    @available(iOS 12.0, *)
    public func handle(intent: GetCoffeeTypeIntent, completion: @escaping (GetCoffeeTypeIntentResponse) -> Void) {
        
        OperationQueue.main.addOperation{
            guard let lastLoc = LocationManager.shared.lastLocation() else {
                let response = GetCoffeeTypeIntentResponse(code: .failure, userActivity: nil)
                completion(response)
                return
            }
            
            CoffeeTypePrediction.shared.predict(lastLoc.coordinate) { (result, json) in
                guard let result = result else {
                    let response = GetCoffeeTypeIntentResponse(code: .failure, userActivity: nil)
                    completion(response)
                    return
                }
                
                print("classLabel \(result.classLabel)")
                let response = GetCoffeeTypeIntentResponse(code: .success, userActivity: nil)

                if result.classLabel == 1 {
                    response.drink_type = "Hot Coffee"
                } else {
                    response.drink_type = "Iced Coffee"
                }
                completion(response)
            }
        }
    }
}
    

