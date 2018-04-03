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
    
    // MARK: Input
    let titleText = BehaviorRelay<String>(value: "")
    let descriptionText = BehaviorRelay<String>(value: "")
    let dateTimeInterval = BehaviorRelay<TimeInterval>(value: 0)
    let importantBool = BehaviorRelay<Bool>(value: false)
    let urgentBool = BehaviorRelay<Bool>(value: false)
    let saveButtonDidTap = PublishSubject<Void>()
    let deleteButtonDidTap = PublishSubject<Void>()
    private let successVariable = BehaviorRelay<Bool>(value: false)
    private let isLoadingVariable = BehaviorRelay<Bool>(value: false)
    
    // MARK: Output
    let isValid: Observable<Bool>
    var isLoading: Observable<Bool> {
        return self.isLoadingVariable.asObservable()
    }
    var isSuccessful: Observable<Bool> {
        return self.successVariable.asObservable()
    }

    private var taskService: TaskService!
    private let disposeBag = DisposeBag()
    
    init(taskService: TaskService, taskId: String) {
        self.taskService = taskService
        let uid = UserDefaults.standard.string(forKey: "uid")!
        isValid = Observable.combineLatest(titleText.asObservable(), descriptionText.asObservable()) { $0.count >= 1 && $1.count >= 1 }
        let result = Observable.combineLatest(
            titleText.asObservable(),
            descriptionText.asObservable(),
            importantBool.asObservable(),
            urgentBool.asObservable()) { ($0, $1, $2, $3) }
        saveButtonDidTap
            .withLatestFrom(result)
            .flatMapLatest({ (title, description, important, urgent) -> Observable<Bool> in
                self.isLoadingVariable.accept(true)
                var params = [String: AnyObject]()
                params["title"] = title as AnyObject
                params["description"] = description as AnyObject
                params["author"] = uid as AnyObject
                params["completed"] = false as AnyObject
                params["important"] = important as AnyObject
                params["urgent"] = urgent as AnyObject
                params["createdAt"] = Date().millisecondsSince1970 as AnyObject
                return self.taskService.update(taskId: taskId, params: params)
            })
            .subscribe(onNext: { done in
                self.isLoadingVariable.accept(false)
                self.successVariable.accept(true)
            })
            .disposed(by: disposeBag)
        
        deleteButtonDidTap
            .flatMapFirst({ _ -> Observable<Bool> in
                return self.taskService.delete(taskId: taskId)
            })
            .subscribe(onNext: { done in
                self.isLoadingVariable.accept(false)
                self.successVariable.accept(true)
            })
            .disposed(by: disposeBag)
    }
}

extension TaskDetailViewModel {
    // MARK: Public
    func callToFetchTask(taskId: String) {
        Observable.just(taskId)
            .flatMap({ self.fetchTaskByIdObservable(taskId: $0) })
            .subscribe(onNext: { task in
                self.titleText.accept(task.title)
                self.descriptionText.accept(task.description)
                self.importantBool.accept(task.important)
                self.urgentBool.accept(task.urgent)
                self.dateTimeInterval.accept(task.createdAt)
            })
            .disposed(by: self.disposeBag)
    }
    
    // MARK: Private
    private func fetchTaskByIdObservable(taskId: String) -> Observable<Task> {
        return self.taskService.fetchTaskById(taskId: taskId)
    }
}
