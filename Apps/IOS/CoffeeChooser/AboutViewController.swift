//
//  AboutViewController.swift
//  CoffeeBot
//
//  Created by Antonio Hung on 7/6/18.
//  Copyright © 2018 Dark Bear Interactive. All rights reserved.
//

import UIKit

class AboutViewController: SuperViewController {

	@IBOutlet weak var textView: UITextView! {
		didSet {
			textView.text = "Coffee Choose uses Machine Learning to be able to tell you what type of coffee you should drink, whether it is hot or iced coffee.\n\nTapping on the Train tab will allow you to enter what coffee you are drinking right now. This will help the app better predict what you should have next time."
		}
	}
	@IBAction func viewPP(_ sender: Any) {
		
		
	}
	override func viewDidLoad() {
        super.viewDidLoad()

		//
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	

}

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate {
	
	var webView: WKWebView!
	
	@IBAction func close(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	override func loadView() {
		super.loadView()
		let webConfiguration = WKWebViewConfiguration()
		webView = WKWebView(frame: .zero, configuration: webConfiguration)
		webView.uiDelegate = self
		view = webView
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		
		var url = URL(string:"https://s3.amazonaws.com/coffee-chooser-app/privacy_policy.html")

		let myRequest = URLRequest(url: url!)
		webView.load(myRequest)
	}}
