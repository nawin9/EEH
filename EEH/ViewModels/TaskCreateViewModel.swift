//
//  TaskCreateViewModel.swift
//  EEH
//
//  Created by nawin on 4/2/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import RxSwift
import RxCocoa

class TaskCreateViewModel {
    
    // MARK: Input
    let titleText = BehaviorRelay<String>(value: "")
    let descriptionText = BehaviorRelay<String>(value: "")
    let importantBool = BehaviorRelay<Bool>(value: false)
    let urgentBool = BehaviorRelay<Bool>(value: false)
    let createButtonDidTap = PublishSubject<Void>()
    private let isLoadingVariable = BehaviorRelay<Bool>(value: false)
    
    // MARK: Output
    let isValid: Observable<Bool>
    var isLoading: Observable<Bool> {
        return self.isLoadingVariable.asObservable()
    }
    
    private var taskService: TaskService!
    private let disposeBag = DisposeBag()
    
    init(taskService: TaskService) {
        self.taskService = taskService
        let uid = UserDefaults.standard.string(forKey: "uid")!
        isValid = Observable.combineLatest(titleText.asObservable(), descriptionText.asObservable()) { $0.count >= 1 && $1.count >= 1 }
        let result = Observable.combineLatest(
            titleText.asObservable(),
            descriptionText.asObservable(),
            importantBool.asObservable(),
            urgentBool.asObservable()) { ($0, $1, $2, $3) }
        createButtonDidTap
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
                return self.taskService.create(params: params)
            })
            .subscribe(onNext: { done in
                print("done: ", done)
                self.isLoadingVariable.accept(false)
            })
            .disposed(by: disposeBag)
    }
}
