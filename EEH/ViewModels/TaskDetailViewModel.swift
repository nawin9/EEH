//
//  TaskDetailViewModel.swift
//  EEH
//
//  Created by nawin on 3/24/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import RxSwift
import RxCocoa

class TaskDetailViewModel {

    private var taskService: TaskService!
    private let disposeBag = DisposeBag()
    
    init(taskService: TaskService) {
        self.taskService = taskService
    }
}

