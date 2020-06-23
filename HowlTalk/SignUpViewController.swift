//
//  SignUpViewController.swift
//  HowlTalk
//
//  Created by 바보세림이 on 2020/06/23.
//  Copyright © 2020 serim. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        color = remoteConfig["splash_background"].stringValue
        signUpButton.backgroundColor = UIColor(hex: color)
        cancelButton.backgroundColor = UIColor(hex: color)
        
        signUpButton.addTarget(self, action: #selector(signUpEvent), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelEvent), for: .touchUpInside)
    }
    
    @objc func signUpEvent() {
        Auth.auth().createUser(withEmail: self.email.text!, password: password.text!) { (user, err) in
            let uid = user?.user.uid
            Database.database().reference().child("users").child(uid!).setValue(["name":self.name.text!])
        }
    }
    
    @objc func cancelEvent() {
        self.dismiss(animated: true, completion: nil)
    }

}
