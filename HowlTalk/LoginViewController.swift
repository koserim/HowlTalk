//
//  LoginViewController.swift
//  HowlTalk
//
//  Created by 바보세림이 on 2020/06/23.
//  Copyright © 2020 serim. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try! Auth.auth().signOut()
        color = remoteConfig["splash_background"].stringValue
        loginButton.backgroundColor = UIColor(hex: color)
        signUpButton.backgroundColor = UIColor(hex: color)
        loginButton.addTarget(self, action: #selector(loginEvent), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(presentSignUp), for: .touchUpInside)
        
        Auth.auth().addStateDidChangeListener{ (auth, user) in
            if(user != nil) {
                let view = self.storyboard?.instantiateViewController(identifier: "MainViewTabBarController") as! UITabBarController
                self.present(view, animated: true, completion: nil)
            }
            
        }
    }
    
    @objc func loginEvent() {
        Auth.auth().signIn(withEmail: email.text!, password: password.text!, completion: {
            (user, err) in
            if(err != nil) {
                let alert = UIAlertController(title: "error", message: err.debugDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    @objc func presentSignUp() {
        let view = self.storyboard?.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
        self.present(view, animated: true, completion: nil)
        
    }

}
