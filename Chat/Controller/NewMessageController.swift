//
//  NewMessageTableViewController.swift
//  Chat
//
//  Created by 10.12 on 2019/4/6.
//  Copyright © 2019 Rui. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {

    let cellReuseId = "cellId"
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellReuseId)
        
        // fetch all user information from firebase
        fetchUser()

    }
    
    func fetchUser() {
        let usersRef = Database.database().reference().child("users")
        usersRef.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: String] {
                let currentUser = User()
                print(dictionary)
                currentUser.name = dictionary["name"]
                currentUser.email = dictionary["email"]
                
                self.users.append(currentUser)
                
                // main_async to reload tableview
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                print(currentUser.name ?? "null", currentUser.email ?? "null")
                
            }

            }, withCancel: nil)
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // need to dequeue our cells for memory efficiency
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId, for: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = "wait for updating"
        return cell
    }



}


class UserCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
