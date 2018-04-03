//
//  TaskDetailViewController.swift
//  EEH
//
//  Created by nawin on 4/1/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TaskDetailViewController: UIViewController {
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var importantImageView: UIImageView!
    @IBOutlet weak var urgentImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var saveTaskButton: UIButton!
    @IBOutlet weak var deleteTaskButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private let taskService = TaskService()
    private var viewModel: TaskDetailViewModel!
    
    var taskId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configBinding()
    }
    
    func configBinding() {
        viewModel = TaskDetailViewModel(taskService: taskService, taskId: taskId)
        
        titleTextView.rx.text
            .orEmpty
            .bind(to: viewModel.titleText)
            .disposed(by: disposeBag)
        
        descriptionTextView.rx.text
            .orEmpty
            .bind(to: viewModel.descriptionText)
            .disposed(by: disposeBag)
        
        viewModel.titleText
            .asObservable()
            .bind(to: titleTextView.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.descriptionText
            .asObservable()
            .bind(to: descriptionTextView.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.importantBool
            .asObservable()
            .subscribe(onNext: { important in
                self.importantImageView.image = important ? #imageLiteral(resourceName: "ic-important-white") : #imageLiteral(resourceName: "ic-important-fade")
            })
            .disposed(by: disposeBag)
        
        viewModel.urgentBool
            .asObservable()
            .subscribe(onNext: { urgent in
                self.urgentImageView.image = urgent ? #imageLiteral(resourceName: "ic-urgent-white") : #imageLiteral(resourceName: "ic-urgent-fade")
            })
            .disposed(by: disposeBag)
        
        viewModel.dateTimeInterval
            .asObservable()
            .map({ $0.getStrDate() })
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.isValid
            .subscribe(onNext: { [unowned self] isValid in
                self.saveTaskButton.isEnabled = isValid
                self.saveTaskButton.backgroundColor = isValid ? UIColor.init(red: 255.0/255, green: 185.0/255, blue: 55.0/255, alpha: 0.9) : .gray
            })
            .disposed(by: disposeBag)
        
        (saveTaskButton.rx.tap)
            .bind(to: viewModel.saveButtonDidTap)
            .disposed(by: disposeBag)
        
        (deleteTaskButton.rx.tap)
            .bind(to: viewModel.deleteButtonDidTap)
            .disposed(by: disposeBag)
        
        viewModel
            .isLoading
            .subscribe(onNext: { loading in
                if loading {
                    SwiftLoader.show(title: "Loading...", animated: true)
                } else {
                    SwiftLoader.hide()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel
            .isSuccessful
            .subscribe(onNext: { [unowned self] success in
                if success {
                    self.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        let importantTapGesture = UITapGestureRecognizer()
        importantImageView.addGestureRecognizer(importantTapGesture)
        importantImageView.isUserInteractionEnabled = true
        importantTapGesture
            .rx
            .event
            .bind(onNext: { [unowned self] recognizer in
                if self.importantImageView.image == #imageLiteral(resourceName: "ic-important-fade") {
                    self.importantImageView.image = #imageLiteral(resourceName: "ic-important-white")
                } else {
                    self.importantImageView.image = #imageLiteral(resourceName: "ic-important-fade")
                }
            })
            .disposed(by: disposeBag)
        
        importantTapGesture
            .rx
            .event
            .map({ recognizer in
                return self.importantImageView.image == #imageLiteral(resourceName: "ic-important-white")
            })
            .bind(to: viewModel.importantBool)
            .disposed(by: disposeBag)
        
        let urgentTapGesture = UITapGestureRecognizer()
        urgentImageView.addGestureRecognizer(urgentTapGesture)
        urgentImageView.isUserInteractionEnabled = true
        urgentTapGesture
            .rx
            .event
            .bind(onNext: { [unowned self] recognizer in
                if self.urgentImageView.image == #imageLiteral(resourceName: "ic-urgent-fade") {
                    self.urgentImageView.image = #imageLiteral(resourceName: "ic-urgent-white")
                } else {
                    self.urgentImageView.image = #imageLiteral(resourceName: "ic-urgent-fade")
                }
            })
            .disposed(by: disposeBag)
        
        urgentTapGesture
            .rx
            .event
            .map({ recognizer in
                return self.urgentImageView.image == #imageLiteral(resourceName: "ic-urgent-white")
            })
            .bind(to: viewModel.urgentBool)
            .disposed(by: disposeBag)
        
        viewModel.callToFetchTask(taskId: taskId)
    }
    
}
