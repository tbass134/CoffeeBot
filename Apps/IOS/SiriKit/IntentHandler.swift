import Intents

class IntentHandler: INExtension {
    

    
    override func handler(for intent: INIntent) -> Any? {
        

        if intent is GetCoffeeTypeIntent {
            return GetCoffeeTypeIntentHandler()
        } else if intent is SelectHotCoffeeIntent {
            return SelectHotCoffeeIntentHandler()
        } else if intent is SelectIcedCoffeeIntent {
            return SelectIcedCoffeeIntentHandler()
        }
        return .none
    }
}
