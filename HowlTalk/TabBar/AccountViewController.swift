//
//  AccountViewController.swift
//  HowlTalk
//
//  Created by 바보세림이 on 2020/07/07.
//  Copyright © 2020 serim. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {

    @IBOutlet weak var statusMessageButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        statusMessageButton.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
    }
    
    @objc func showAlert() {
        let alertController = UIAlertController(title: "상태 메세지", message: nil, preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField(configurationHandler: {
            (textField) in
            textField.placeholder = "상태 메세지를 입력해주세요"
        })
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            if let textfield = alertController.textFields?.first {
                let dic = ["status":textfield.text!]
                let uid = Auth.auth().currentUser?.uid
                Database.database().reference().child("users").child(uid!).updateChildValues(dic)
            }
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
            
        }))
        self.present(alertController, animated: true, completion: nil)
    }

}
