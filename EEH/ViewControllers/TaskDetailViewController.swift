//
//  TaskDetailViewController.swift
//  EEH
//
//  Created by nawin on 4/1/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TaskDetailViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let taskService = TaskService()
    private var viewModel: TaskDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configBinding()
    }
    
    func configBinding() {
        
    }
}
