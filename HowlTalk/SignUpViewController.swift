//
//  SignUpViewController.swift
//  HowlTalk
//
//  Created by 바보세림이 on 2020/06/23.
//  Copyright © 2020 serim. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker)))
        
        color = remoteConfig["splash_background"].stringValue
        signUpButton.backgroundColor = UIColor(hex: color)
        cancelButton.backgroundColor = UIColor(hex: color)
        
        signUpButton.addTarget(self, action: #selector(signUpEvent), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelEvent), for: .touchUpInside)
    }
    
    // 앨범이 열림
    @objc func imagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // 선택한 이미지가 이미지뷰에 담김
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as! UIImage
        dismiss(animated: true, completion: nil)
    }
    
    @objc func signUpEvent() {
        Auth.auth().createUser(withEmail: self.email.text!, password: password.text!) { (user, err) in
            let uid = user?.user.uid
            let image = self.imageView.image!.jpegData(compressionQuality: 0.1)
            // 폴더 이름이 userImages, 파일 이름 uid
            let fileRef = Storage.storage().reference().child("userImages").child(uid!)
            fileRef.putData(image!, metadata: nil, completion: { (data, err) in
                fileRef.downloadURL { (url, err) in
                    
//                    //유저 이름, 이미지 주소, UID값 맵으로 생성
//                    var userModel = UserModel()
//                    userModel.userName = self.name.text
//                    userModel.profileImageURL = url?.absoluteString
//                    userModel.uid = Auth.auth().currentUser?.uid
                    
                    let imageURL = url?.absoluteString
                    let values = ["userName":self.name.text!, "profileImageURL": imageURL, "uid": Auth.auth().currentUser?.uid]
                    
                    //데이터베이스에 유저정보 입력
                    Database.database().reference().child("users").child(uid!).setValue(values, withCompletionBlock: { (err, ref) in
                        if(err == nil){
                            self.cancelEvent()
                        } else {
                            print("error~~~")
                            print(err)
                        }
                    })
                }
                
            })
            
        }
    }
    
    @objc func cancelEvent() {
        self.dismiss(animated: true, completion: nil)
    }

}
