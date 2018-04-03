//
//  ProfileViewModel.swift
//  EEH
//
//  Created by nawin on 3/30/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import RxSwift
import RxCocoa

class ProfileViewModel {
    
    // MARK: Input
    let nameText = BehaviorRelay<String>(value: "")
    let emailText = BehaviorRelay<String>(value: "")
    let descriptionText = BehaviorRelay<String>(value: "")
    let avatarImage = BehaviorRelay<String>(value: "")
    let saveButtonDidTap = PublishSubject<Void>()
    private let successVariable = BehaviorRelay<Bool>(value: false)
    private let isLoadingVariable = BehaviorRelay<Bool>(value: false)
    private let profileVariable = BehaviorRelay<Profile>(value: Profile())
    
    // MARK: Output
    let isValid: Observable<Bool>
    var isLoading: Observable<Bool> {
        return self.isLoadingVariable.asObservable()
    }
    var isSuccessful: Observable<Bool> {
        return self.successVariable.asObservable()
    }

    private var profileService: ProfileService!
    private let disposeBag = DisposeBag()
    
    init(profileService: ProfileService) {
        self.profileService = profileService
        isValid = Observable.combineLatest(nameText.asObservable(), descriptionText.asObservable()) { $0.count >= 1 || $1.count >= 1 }
        let result = Observable.combineLatest(
            nameText.asObservable(),
            descriptionText.asObservable()) { ($0, $1) }
        guard let email = UserDefaults.standard.string(forKey: "email") else { return }
        saveButtonDidTap
            .withLatestFrom(result)
            .flatMapLatest({ (name, description) -> Observable<Bool> in
                self.isLoadingVariable.accept(true)
                var params = [String: AnyObject]()
                params["email"] = email as AnyObject
                params["name"] = name as AnyObject
                params["description"] = description as AnyObject
                return self.profileService.update(params: params)
            })
            .subscribe(onNext: { done in
                self.isLoadingVariable.accept(false)
                self.successVariable.accept(true)
            })
            .disposed(by: disposeBag)
    }
    
}

extension ProfileViewModel {
    // MARK: Public
    func callToFetchProfile() {
        Observable.just(Void())
            .do(onNext: { self.isLoadingVariable.accept(true) })
            .flatMap(self.fetchProfileObservable)
            .do(onNext: { _ in self.isLoadingVariable.accept(false) })
            .subscribe(onNext: { profile in
                self.nameText.accept(profile.name)
                self.emailText.accept(profile.email)
                self.descriptionText.accept(profile.description)
            })
            .disposed(by: self.disposeBag)
    }
    
    // MARK: Private    
    private func fetchProfileObservable() -> Observable<Profile> {
        return self.profileService.fetchProfile()
    }
}
