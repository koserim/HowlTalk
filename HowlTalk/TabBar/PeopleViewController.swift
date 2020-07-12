//
//  MainViewController.swift
//  HowlTalk
//
//  Created by 바보세림이 on 2020/06/24.
//  Copyright © 2020 serim. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import Kingfisher

class PeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var array: [UserModel] = []
    var tableView: UITableView = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PeopleTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view)
            make.bottom.left.right.equalTo(view)
        }
        
        Database.database().reference().child("users").observe(DataEventType.value, with: {
            (snapshot) in
            self.array.removeAll() // 중복되는 데이터 제거
            
            let myUid = Auth.auth().currentUser?.uid
            
            for child in snapshot.children {
                let fchild = child as! DataSnapshot
                let dic = fchild.value as! [String : Any]
                let userModel = UserModel(JSON: dic)
                
                // 친구 목록에 내 uid는 뜨지 않도록
                if(userModel!.uid == myUid) {
                    continue
                }
                
                self.array.append(userModel!)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        
        var selectFriendButton = UIButton()
        view.addSubview(selectFriendButton)
        selectFriendButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view).offset(-90)
            make.right.equalTo(view).offset(-20)
            make.width.height.equalTo(50)
        }
        selectFriendButton.backgroundColor = UIColor.black
        selectFriendButton.addTarget(self, action: #selector(showSelectFriendController ), for: .touchUpInside)
        selectFriendButton.layer.cornerRadius = 25
        selectFriendButton.layer.masksToBounds = true
    }
    
    @objc func showSelectFriendController() {
        self.performSegue(withIdentifier: "SelectFriendSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PeopleTableViewCell
        let imageView = cell.imageview
        imageView.snp.makeConstraints{ (make) in
            make.centerY.equalTo(cell)
            make.left.equalTo(cell).offset(10) 
            make.height.width.equalTo(50)
        }
        
        let url = URL(string: array[indexPath.row].profileImageURL!)
        imageView.layer.cornerRadius = 50/2
        imageView.clipsToBounds = true
        imageView.kf.setImage(with: url)

        let label = cell.label
        label.snp.makeConstraints{ (make) in
            make.centerY.equalTo(cell)
            make.left.equalTo(imageView.snp.right).offset(20)
        }
        label.text = array[indexPath.row].userName
        
        let statusLabel = cell.statusLabel
        statusLabel.snp.makeConstraints{ (make) in
            make.centerX.equalTo(cell.statusBackground)
            make.centerY.equalTo(cell.statusBackground)
        }
        if let status = array[indexPath.row].status {
            statusLabel.text = status
        }
        
        cell.statusBackground.snp.makeConstraints { (make) in
            make.right.equalTo(cell).offset(-10)
            make.centerY.equalTo(cell)
            if let count = statusLabel.text?.count {
                make.width.equalTo(count * 15)
            } else {
                make.width.equalTo(0)
            }
            make.height.equalTo(30)
        }
        cell.statusBackground.backgroundColor = UIColor(displayP3Red: 225/255, green: 242/255, blue: 252/255, alpha: 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let view = self.storyboard?.instantiateViewController(identifier: "ChatViewController") as? ChatViewController
        
        // 채팅할 대상의 uid 넘겨줌
        view?.destinationUid = self.array[indexPath.row].uid
         
        self.navigationController?.pushViewController(view!, animated: true)
    }
}

class PeopleTableViewCell: UITableViewCell {
    var imageview: UIImageView = UIImageView()
    var label: UILabel = UILabel()
    var statusLabel: UILabel = UILabel()
    var statusBackground: UIView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(imageview)
        self.addSubview(label)
        self.addSubview(statusBackground)
        self.addSubview(statusLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
