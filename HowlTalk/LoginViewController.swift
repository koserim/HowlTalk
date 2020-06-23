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

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let statusBar = UIView()
//        self.view.addSubview(statusBar)
//        statusBar.snp.makeConstraints{ (make) in
//            make.right.top.left.equalTo(self.view)
//            make.height.equalTo(20)
//        }
        color = remoteConfig["splash_background"].stringValue
//        statusBar.backgroundColor = UIColor(hex: color)
        loginButton.backgroundColor = UIColor(hex: color)
        signUpButton.backgroundColor = UIColor(hex: color)
        
        signUpButton.addTarget(self, action: #selector(presentSignUp), for: .touchUpInside)
    }
    
    @objc func presentSignUp() {
        let view = self.storyboard?.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
        self.present(view, animated: true, completion: nil)
        
    }

}
