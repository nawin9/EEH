//
//  ProfileViewController.swift
//  EEH
//
//  Created by nawin on 4/1/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logoutCurrentUser(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "uid")
            defaults.removeObject(forKey: "email")
            self.navigationController?.popViewController(animated: false)
        } catch let err {
            print(err)
        }
    }
    
}
