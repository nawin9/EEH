//
//  Date.swift
//  EEH
//
//  Created by nawin on 4/2/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import Foundation

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}
