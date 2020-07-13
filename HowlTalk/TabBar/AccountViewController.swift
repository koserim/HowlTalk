//
//  AccountViewController.swift
//  HowlTalk
//
//  Created by 바보세림이 on 2020/07/07.
//  Copyright © 2020 serim. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class AccountViewController: UIViewController {

    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var statusMessageLabel: UILabel!
    @IBOutlet weak var statusMessageButton: UIButton!
    
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uid = Auth.auth().currentUser?.uid
        statusMessageButton.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
        setInfo()
    }
    
    func setInfo() {
        Database.database().reference().child("users").child(self.uid).observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
            let dic = datasnapshot.value as! [String:Any]
            let userModel = UserModel(JSON: dic)
            let url = URL(string: (userModel?.profileImageURL)!)
            self.profileImageView.kf.setImage(with: url)
            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width/2
            self.profileImageView.layer.masksToBounds = true
            self.nameLabel.text = userModel?.userName
            if (userModel?.status == nil || userModel?.status == "") {
                self.statusMessageLabel.text = "상태메세지가 없습니다."
                self.statusMessageLabel.textColor = UIColor.gray
            } else {
                self.statusMessageLabel.text = userModel?.status
                self.statusMessageLabel.textColor = UIColor.black
            }
            self.mailLabel.text = Auth.auth().currentUser?.email
        }
        
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
                Database.database().reference().child("users").child(self.uid).updateChildValues(dic)
            }
            self.setInfo()
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
            
        }))
        self.present(alertController, animated: true, completion: nil)
    }

}
