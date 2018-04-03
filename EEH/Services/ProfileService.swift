//
//  ProfileService.swift
//  EEH
//
//  Created by nawin on 4/3/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import FirebaseDatabase
import RxSwift

protocol ProfileServiceType {
    func fetchProfile() -> Observable<Profile>
    func update(params: [String: AnyObject]) -> Observable<Bool>
}

final class ProfileService: ProfileServiceType {
    func update(params: [String: AnyObject]) -> Observable<Bool> {
        guard let uid = UserDefaults.standard.string(forKey: "uid") else {
            return Observable.just(false)
        }
        let ref = Database.database().reference().child("profiles").child(uid)
        return ref.rx_setValue(value: params as AnyObject).map({ _ in true })
    }
    
    func fetchProfile() -> Observable<Profile> {
        guard let uid = UserDefaults.standard.string(forKey: "uid") else {
            return Observable.just(Profile())
        }
        let ref = Database.database().reference().child("profiles").child(uid)
        return ref.rx_observeSingleEvent(of: .value).map({ snapshot in
            guard let profile = Profile(snapshot: snapshot) else {
                return Profile()
            }
            return profile
        })
    }
    
}
