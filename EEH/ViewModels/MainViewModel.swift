//
//  MainViewModel.swift
//  EEH
//
//  Created by nawin on 3/25/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import RxSwift
import RxCocoa

struct MainViewModel {
    
    // MARK: Public
    var tasks: Observable<[Task]> {
        return self.tasksVariable.asObservable()
    }
    var isLoading: Observable<Bool> {
        return self.isLoadingVariable.asObservable()
    }
    var error: Observable<Error> {
        return self.errorSubject.asObservable()
    }
    
    // MARK: Private
    
    private let tasksVariable = BehaviorRelay<[Task]>(value: [])
    private let isLoadingVariable = BehaviorRelay<Bool>(value: false)
    private let errorSubject = PublishSubject<Error>()
    
    private var taskService: TaskService!
    private let disposeBag = DisposeBag()
    
    init(taskService: TaskService) {
        self.taskService = taskService
    }
    
}

extension MainViewModel {
    
    // MARK: Public
    func bindObservableToFetchTasks(_ observable: Observable<Void>) {
        observable
            .do(onNext: { self.isLoadingVariable.accept(true) })
            .flatMap(self.fetchTasksObservable)
            .do(onNext: { _ in self.isLoadingVariable.accept(false) })
            .bind(to: self.tasksVariable)
            .disposed(by: self.disposeBag)
    }
    
    // MARK: Private
    
    private func fetchTasksObservable() -> Observable<[Task]> {
        return self.taskService.fetchTasks()
        
    }
}
