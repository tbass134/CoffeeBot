//
//  AppDelegate.swift
//  CoffeeChooser
//
//  Created by Antonio Hung on 5/26/17.
//  Copyright © 2017 Dark Bear Interactive. All rights reserved.
//

import UIKit
import Firebase
import Fabric
import Crashlytics
import Intents
import SwiftLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var textLog = TextLog()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        
        if let _ = launchOptions?[UIApplicationLaunchOptionsKey.location] {
            print("didFinishLaunchingWithOptions",launchOptions)
            textLog.write("CoffeeChooser didFinishLaunchingWithOptions \(launchOptions)\n")

          
            Locator.subscribeSignificantLocations(onUpdate: { newLocation in
                self.textLog.write("CoffeeChooser didFinishLaunchingWithOptions got newLocation \(newLocation)\n")
                // This block will be executed with the details of the significant location change that triggered the background app launch,
                // and will continue to execute for any future significant location change events as well (unless canceled).
            }, onFail: { (err, lastLocation) in
                // Something bad has occurred
                print("didFinishLaunchingWithOptions error",err)


                self.textLog.write("CoffeeChooser didFinishLaunchingWithOptions err \(err)\n")
                self.textLog.write("CoffeeChooser didFinishLaunchingWithOptions lastLocation \(lastLocation)\n")
            })
        }
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        var vc:UIViewController?

        guard let _ = Auth.auth().currentUser else {
            vc = storyboard.instantiateViewController(withIdentifier: "Login")
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
            return true
        }

        vc = storyboard.instantiateViewController(withIdentifier: "MainView")


        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()

        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    
        
        if #available(iOS 12.0, *) {
            guard userActivity.activityType == NSStringFromClass(GetCoffeeTypeIntent.self) else {
                print("Can't continue unknown NSUserActivity type %@", userActivity.activityType)
                return false
            }
        }
        
        guard let window = window,
            let rootViewController = window.rootViewController as? UINavigationController else {
                print("Failed to access root view controller.")
                return false
        }
        
        // The `restorationHandler` passes the user activity to the passed in view controllers to route the user to the part of the app
        // that is able to continue the specific activity. See `restoreUserActivityState` in `OrderHistoryTableViewController`
        // to follow the continuation of the activity further.
        restorationHandler(rootViewController.viewControllers)
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


struct TextLog: TextOutputStream {
    
    /// Appends the given string to the stream.
    mutating func write(_ string: String) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        let documentDirectoryPath = paths.first!
        let log = documentDirectoryPath.appendingPathComponent("log.txt")
        
        do {
            let handle = try FileHandle(forWritingTo: log)
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
        } catch {
            print(error.localizedDescription)
            do {
                try string.data(using: .utf8)?.write(to: log)
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
}
