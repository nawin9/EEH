//
//  Task.swift
//  EEH
//
//  Created by nawin on 3/18/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Task {
    
    var id: String = ""
    var author: String = ""
    var title: String = ""
    var description: String = ""
    var createdAt: TimeInterval = 0
    var completed: Bool = false
    var important: Bool = false
    var urgent: Bool = false
    var priority: Int = 10
    
    init() {}
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let author = dict["author"] as? String,
            let title = dict["title"] as? String,
            let description = dict["description"] as? String,
            let createdAt = dict["createdAt"] as? TimeInterval,
            let completed = dict["completed"] as? Bool,
            let important = dict["important"] as? Bool,
            let urgent = dict["urgent"] as? Bool
            else { return nil }
        
        self.id = snapshot.key
        self.author = author
        self.title = title
        self.description = description
        self.createdAt = createdAt
        self.completed = completed
        self.important = important
        self.urgent = urgent
        if important && urgent {
            self.priority = 3
        } else if !important && urgent {
            self.priority = 2
        } else if important && !urgent {
            self.priority = 1
        } else {
            self.priority = 0
        }
    }
}
