//
//  BaseViewController.swift
//  CoffeeBot
//
//  Created by Antonio Hung on 6/23/18.
//  Copyright © 2018 Dark Bear Interactive. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

		_ = LocationManager.shared.getLocation()
		
		NotificationCenter.default.addObserver(self, selector: #selector(locationUpdated(notification:)), name: .locationDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(locationStatusChanged(notification:)), name: Notification.Name.locationStatusChanged, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(locationError(notification:)), name: Notification.Name.locationDidFail, object: nil)
		
		
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
