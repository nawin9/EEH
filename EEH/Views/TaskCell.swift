//
//  TaskCell.swift
//  EEH
//
//  Created by nawin on 4/1/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import UIKit

class TaskCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var importantImageView: UIImageView!
    @IBOutlet weak var urgentImageView: UIImageView!
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "ic-addtask-white"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    var element: Task?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupDefaultCell() {
        titleLabel.isHidden = true
        dateLabel.isHidden = true
        importantImageView.isHidden = true
        urgentImageView.isHidden = true
        imageView.isHidden = false
        backgroundColor = .clear
        
        let horizontalConstraint = imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        let verticalConstraint = imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        let widthConstraint = imageView.widthAnchor.constraint(equalToConstant: 40)
        let heightConstraint = imageView.heightAnchor.constraint(equalToConstant: 40)
        addSubview(imageView)
        addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    
    func setupCell(task: Task) {
        element = task
        imageView.isHidden = true
        titleLabel.isHidden = false
        dateLabel.isHidden = false
        importantImageView.isHidden = false
        urgentImageView.isHidden = false
        titleLabel.text = task.title
        dateLabel.text = task.createdAt.getStrDate()
        importantImageView.image = task.important ? #imageLiteral(resourceName: "ic-important-white") : #imageLiteral(resourceName: "ic-important-fade")
        urgentImageView.image = task.urgent ? #imageLiteral(resourceName: "ic-urgent-white") : #imageLiteral(resourceName: "ic-urgent-fade")
        changeBackground(priority: task.priority)
    }
    
    private func changeBackground(priority: Int) {
        switch priority {
        case 0:
            backgroundColor = UIColor.init(red: 248.0/255, green: 232.0/255, blue: 28.0/255, alpha: 0.4)
        case 1:
            backgroundColor = UIColor.init(red: 13.0/255, green: 160.0/255, blue: 178.0/255, alpha: 0.8)
        case 2:
            backgroundColor = UIColor.init(red: 126.0/255, green: 211.0/255, blue: 33.0/255, alpha: 0.8)
        case 3:
            backgroundColor = UIColor.init(red: 255.0/255, green: 58.0/255, blue: 7.0/255, alpha: 0.8)
        default:
            break
        }
    }
    
}
