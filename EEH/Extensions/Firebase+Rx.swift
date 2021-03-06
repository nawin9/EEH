//
//  Firebase+Rx.swift
//  EEH
//
//  Created by nawin on 3/25/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import RxSwift
import FirebaseAuth
import FirebaseDatabase

extension Auth {
    var rx_authStateDidChange: Observable<(Auth, User?)> {
        get {
            return Observable.create { observer in
                let listener = self.addStateDidChangeListener({ (auth, user) in
                    observer.onNext((auth, user))
                })
                return Disposables.create {
                    self.removeStateDidChangeListener(listener)
                }
            }
        }
    }
    
    func rx_signinWithEmail(email: String, password: String) -> Observable<User?> {
        return Observable.create { (observer) -> Disposable in
            self.signIn(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(user)
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        }
    }
    
    func rx_createUserWithEmail(email: String, password: String) -> Observable<User?> {
        return Observable.create { (observer) -> Disposable in
            self.createUser(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    if let user = user {
                        let ref: DatabaseReference = Database.database().reference().child("profiles").child(user.uid)
                        var values = [String: AnyObject]()
                        values["email"] = user.email as AnyObject
                        ref.updateChildValues(values, withCompletionBlock: { (error, _) in
                            if let error = error {
                                observer.onError(error)
                            } else {
                                observer.onNext(user)
                                observer.onCompleted()
                            }
                        })
                    }
//                    observer.onCompleted()
                }
            })
            return Disposables.create()
        }
    }
    
}
extension DatabaseReference {
    func rx_updateChildValues(values: [String : AnyObject]) -> Observable<DatabaseReference> {
        return Observable.create { observer in
            self.updateChildValues(values, withCompletionBlock: { (error, databaseReference) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(databaseReference)
                    observer.onCompleted()
                }
            })            
            return Disposables.create()
        }
    }
    
    func rx_setValue(value: AnyObject!, priority: AnyObject? = nil) -> Observable<DatabaseReference> {
        return Observable.create { observer in
            self.setValue(value, andPriority: priority, withCompletionBlock: { (error, databaseReference) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(databaseReference)
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        }
    }
    
    func rx_removeValue() -> Observable<DatabaseReference> {
        return Observable.create { observer in
            self.removeValue(completionBlock: { (error, databaseReference) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(databaseReference)
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        }
    }
    
    func rx_addValue(value: AnyObject, autoId: Bool = false, uid: String, taskId: String) -> Observable<DatabaseReference> {
        return Observable.create { observer -> Disposable in
            let ref = autoId ? self.childByAutoId() : self
            ref.setValue(value, withCompletionBlock: { (error, databaseReference) in
                if let error = error {
                    observer.onError(error)
                } else {
                    let profileRef = Database.database().reference().child("profiles").child(uid).child("tasks").child(taskId)
                    profileRef.setValue(true as AnyObject, withCompletionBlock: { (error, _) in
                        if let error = error {
                            observer.onError(error)
                        } else {
                            observer.onNext(databaseReference)
                            observer.onCompleted()
                        }
                    })
//                    observer.onNext(databaseReference)
//                    observer.onCompleted()
                }
            })
            return Disposables.create()
        }
    }
}

extension DatabaseQuery {
    func rx_observeSingleEvent(of event: DataEventType) -> Observable<DataSnapshot> {
        return Observable.create({ (observer) -> Disposable in
            self.observeSingleEvent(of: event, with: { (snapshot) in
                observer.onNext(snapshot)
                observer.onCompleted()
            }, withCancel: { (error) in
                observer.onError(error)
            })
            return Disposables.create()
        })
    }
    
    func rx_observeEvent(event: DataEventType) -> Observable<DataSnapshot> {
        return Observable.create({ (observer) -> Disposable in
            let handle = self.observe(event, with: { (snapshot) in
                observer.onNext(snapshot)
            }, withCancel: { (error) in
                observer.onError(error)
            })
            return Disposables.create {
                self.removeObserver(withHandle: handle)
            }
        })
    }
}
