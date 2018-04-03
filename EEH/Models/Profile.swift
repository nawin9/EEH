//
//  Profile.swift
//  EEH
//
//  Created by nawin on 4/3/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Profile {
    
    var id: String = ""
    var name: String = ""
    var email: String = ""
    var description: String = ""
    var avatar: String = ""
    
    init() {}
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let email = dict["email"] as? String
            else { return nil }
        
        self.id = snapshot.key
        self.email = email
        self.name = dict["name"] as? String ?? ""
        self.description = dict["description"] as? String ?? ""
        self.avatar = dict["avatar"] as? String ?? ""
    }
}
