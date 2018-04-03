//
//  TaskService.swift
//  EEH
//
//  Created by nawin on 3/24/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import FirebaseDatabase
import RxSwift

protocol TaskServiceType {
    func fetchTasks() -> Observable<[Task]>
    func create(params: [String: AnyObject]) -> Observable<Bool>
    func update(taskId: String, params: [String: AnyObject]) -> Observable<Bool>
    func delete(taskId: String) -> Observable<Bool>
}

final class TaskService: TaskServiceType {
    func update(taskId: String, params: [String: AnyObject]) -> Observable<Bool> {
        guard let uid = UserDefaults.standard.string(forKey: "uid") else {
            return Observable.just(false)
        }
        let ref = Database.database().reference().child("tasks").child(uid).child(taskId)
        return ref.rx_setValue(value: params as AnyObject).map({ _ in true })
    }
    
    func delete(taskId: String) -> Observable<Bool> {
        guard let uid = UserDefaults.standard.string(forKey: "uid") else {
            return Observable.just(false)
        }
        let ref = Database.database().reference().child("tasks").child(uid).child(taskId)
        return ref.rx_removeValue().map({ _ in true })
    }
    
    func create(params: [String: AnyObject]) -> Observable<Bool> {
        let uuid = UUID().uuidString
        guard let uid = UserDefaults.standard.string(forKey: "uid") else {
            return Observable.just(false)
        }
        let ref = Database.database().reference().child("tasks").child(uid).child(uuid)
        return ref.rx_addValue(value: params as AnyObject, uid: uid, taskId: uuid).map({ _ in true })
    }
    
    func fetchTasks() -> Observable<[Task]> {
        guard let uid = UserDefaults.standard.string(forKey: "uid") else {
            let tasks: [Task] = [Task()]
            return Observable.just(tasks)
        }
        let ref = Database.database().reference().child("tasks").child(uid)
        return ref.rx_observeSingleEvent(of: .value).map({ snapshot in
            var tasks: [Task] = [Task()]
            guard let snapshots = snapshot.children.allObjects as? [DataSnapshot] else {
                return tasks
            }
            for snap in snapshots {
                if let task = Task(snapshot: snap) {
                    tasks.append(task)
                }
            }
            return tasks.sorted(by: { $0.priority > $1.priority })
        })
    }
    
    func fetchTaskById(taskId: String) -> Observable<Task> {
        guard let uid = UserDefaults.standard.string(forKey: "uid") else {
            return Observable.just(Task())
        }
        let ref = Database.database().reference().child("tasks").child(uid).child(taskId)
        return ref.rx_observeSingleEvent(of: .value).map({ snapshot in
            guard let task = Task(snapshot: snapshot) else {
                return Task()
            }
            return task
        })
    }

}

