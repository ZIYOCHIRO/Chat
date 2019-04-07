//
//  LoginViewControllerExtension.swift
//  Chat
//
//  Created by 10.12 on 2019/4/6.
//  Copyright © 2019 Rui. All rights reserved.
//

import UIKit
import Firebase

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func hangleSelectProfileImageView() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            self.profileImageView.image = image
        } else if let image = info[.originalImage] as? UIImage {
            self.profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("form is not valid")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error!)
                return
            }
            
            // successfully logged in
            self.dismiss(animated: true, completion: nil)
        })
        
        
    }
    
    func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("form is not valid")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            guard let uid = user?.user.uid  else {
                return
            }
            
            // successfully authenticated user
            
              // upload image to firebase storage
            let imageName = NSUUID().uuidString  // create unique string for imageName
            let rootStorageRef = Storage.storage().reference()
            let profileImageStorageRef = rootStorageRef.child("profile-image").child("\(imageName).png")
            if let uploadImageData = self.profileImageView.image!.pngData() {
                profileImageStorageRef.putData(uploadImageData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    profileImageStorageRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error!.localizedDescription)
                            return
                        }
                        // no error
                        if let profileImageUrl = url?.absoluteString {
                            // save user basic information to database
                            let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                            self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject] )
                        }
                    })
            
                })
            }
        })
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let usersReference = self.rootRef.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err!)
                return
            }
            print("Saved user successfully into firebase db")
            self.dismiss(animated: true, completion: nil)
        })
    }
    

}
