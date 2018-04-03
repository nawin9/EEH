//
//  RegisterViewModel.swift
//  EEH
//
//  Created by nawin on 3/30/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import FirebaseAuth
import RxSwift
import RxCocoa

class RegisterViewModel {
    
    // MARK: Input
    let emailText = BehaviorRelay<String>(value: "")
    let passwordText = BehaviorRelay<String>(value: "")
    let rePasswordText = BehaviorRelay<String>(value: "")
    let registerButtonTap = PublishSubject<Void>()
    let loginButtonDidTap = PublishSubject<Void>()
    
    // MARK: Output
    let isValid: Observable<Bool>
    let isPasswordValid: Observable<Bool>
    let userObservable = PublishRelay<User?>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        isValid = Observable.combineLatest(emailText.asObservable(), passwordText.asObservable(), rePasswordText.asObservable()) { $0.count >= 3 && $1.count >= 3 && $2.count >= 3 && $1 == $2 }
        isPasswordValid = Observable.combineLatest(passwordText.asObservable(), rePasswordText.asObservable()) { $0 == $1 }
        
        let emailAndPassword = Observable.combineLatest(emailText.asObservable(), passwordText.asObservable()) { ($0, $1) }
        registerButtonTap
            .withLatestFrom(emailAndPassword)
            .flatMapLatest({ (email, password) -> Observable<User?> in
                return Auth.auth().rx_createUserWithEmail(email: email, password: password)
            })            
            .bind(to: self.userObservable)
            .disposed(by: disposeBag)
    }
    
}
