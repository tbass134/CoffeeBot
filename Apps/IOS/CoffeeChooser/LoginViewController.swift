//
//  LoginViewController.swift
//  CoffeeBot
//
//  Created by Antonio Hung on 6/23/18.
//  Copyright © 2018 Dark Bear Interactive. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

	@IBOutlet weak var usernameTextField: LoginTextField!
	@IBOutlet weak var passwordTextField: LoginTextField!
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	@IBAction func loginAction(_ sender: Any) {
		guard let email = usernameTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
			self.presentAlert(title: "One of the fields are empty")
			return
		}
		
		
		Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
			
			if (error != nil) {
				self.presentAlert(title: "Login Error", message: error?.localizedDescription)
				return
			}
			self.performSegue(withIdentifier: "didLogin", sender: self)
		}
	}
	
	@IBAction func signupAction(_ sender: Any) {
		guard let email = usernameTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
			self.presentAlert(title: "One of the fields are empty")
			return
		}
		
		Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
			if (error != nil) {
				self.presentAlert(title: "Signup Error", message: error?.localizedDescription)
				return
			}
			self.performSegue(withIdentifier: "didLogin", sender: self)

		}
	}
	@IBAction func forgotPasswordAction(_ sender: Any) {
		let alert = UIAlertController(title: "Forgot Password?", message: "Enter your email to reset your password", preferredStyle: .alert)
		
		alert.addTextField { textField in
			textField.placeholder = "Email Address"
		}
		
		let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak alert] _ in
			guard let alert = alert, let text = alert.textFields?.first?.text else { return }
			
			Auth.auth().sendPasswordReset(withEmail: text) { error in
				// Your code here
				self.presentAlert(title: "Password Reset", message: "Please check your email")
			}
			
		}
		alert.addAction(confirmAction)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alert.addAction(cancelAction)
		present(alert, animated: true, completion: nil)
		
	}
	@IBAction func skipAction(_ sender: Any) {
		Auth.auth().signInAnonymously() { (authResult, error) in
			print("signInAnonymously", error)
			if (error == nil) {
				self.performSegue(withIdentifier: "didLogin", sender: self)
			}

		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
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

let kLoginButtonBackgroundColor = UIColor(displayP3Red: 31/255, green: 75/255, blue: 164/255, alpha: 1)
let kLoginButtonTintColor = UIColor.white
let kLoginButtonCornerRadius: CGFloat = 13.0

class LoginButton: UIButton {
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.configureUI()
	}
	
	private func configureUI() {
		self.backgroundColor = kLoginButtonBackgroundColor
		self.layer.cornerRadius = kLoginButtonCornerRadius
		self.tintColor = kLoginButtonTintColor
		self.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 14)
	}
	
}

class LoginTextField: UITextField {
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.configureUI()
	}
	
	private func configureUI() {
		self.layer.borderColor = UIColor.gray.cgColor
		self.layer.borderWidth = 0.5
		self.layer.cornerRadius = 4.0
	}
}

