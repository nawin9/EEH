//
//  LoginViewModel.swift
//  EEH
//
//  Created by nawin on 3/24/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import FirebaseAuth
import RxSwift
import RxCocoa

class LoginViewModel {
    
    // MARK: Input
    let emailText = BehaviorRelay<String>(value: "")
    let passwordText = BehaviorRelay<String>(value: "")
    let loginButtonDidTap = PublishSubject<Void>()
    
    // MARK: Output
    let isValid: Observable<Bool>
    let userObservable = PublishRelay<User?>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        isValid = Observable.combineLatest(emailText.asObservable(), passwordText.asObservable()) { $0.count >= 3 && $1.count >= 6 }
        let emailAndPassword = Observable.combineLatest(emailText.asObservable(), passwordText.asObservable()) { ($0, $1) }
        loginButtonDidTap
            .withLatestFrom(emailAndPassword)
            .flatMapLatest({ (email, password) -> Observable<User?> in
                return Auth.auth().rx_signinWithEmail(email: email, password: password)
            })
            .bind(to: self.userObservable)
            .disposed(by: disposeBag)
    }
    
}
