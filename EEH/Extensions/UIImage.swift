//
//  UIImage.swift
//  EEH
//
//  Created by nawin on 4/2/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import UIKit

extension UIImage {
    static func ==(lhs: UIImage, rhs: UIImage) -> Bool {
        if let lhsData = UIImagePNGRepresentation(lhs), let rhsData = UIImagePNGRepresentation(rhs) {
            return lhsData == rhsData
        }
        return false
    }
}

