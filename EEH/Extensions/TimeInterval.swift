//
//  Firebase+String.swift
//  EEH
//
//  Created by nawin on 4/1/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    func getStrDate() -> String {
        let date = Date(timeIntervalSince1970: self/1000)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MMMM dd yyyy"
        return dateFormatter.string(from: date)
    }
    
}
