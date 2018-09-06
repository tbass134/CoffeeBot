import Foundation
import KeychainAccess //https://github.com/kishikawakatsumi/KeychainAccess
import Firebase

//Requires shared Keychain with the same group name

class ApplicationBuilder {
    
    enum Target {
        case app
        case appExtension
    }
    
    private static let appKeychain = Keychain(service: "firebase_auth_1:840563329678:ios:38db3db282892523") //need replace　with　GOOGLE_APP_ID from GoogleService-Info.plist
    private static let extensionKeychain = Keychain(service: "firebase_auth_1:840563329678:ios:38db3db282892523") //need replace　with　GOOGLE_APP_ID from GoogleService-Info.plist
    private static let userKeychainKey = "firebase_auth_1___FIRAPP_DEFAULT_firebase_user" //__FIRAPP_DEFAULT is FirebaseApp.name
    
    private static var target: Target = .app
    
    static func setup(target: Target, completion: @escaping () -> Void) {
        ApplicationBuilder.target = target
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        if target == .appExtension {
            syncFirebaseKeychain()
        }
    }
    
    private static func syncFirebaseKeychain() {
        guard let data = (try? appKeychain.getData(userKeychainKey)) as? Data else {
            try! extensionKeychain.remove(userKeychainKey)
            return
        }
        
        try? extensionKeychain.set(data, key: userKeychainKey)
    }
}
