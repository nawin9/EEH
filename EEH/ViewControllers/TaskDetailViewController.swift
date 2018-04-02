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
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var importantImageView: UIImageView!
    @IBOutlet weak var urgentImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var saveTaskButton: UIButton!
    @IBOutlet weak var deleteTaskButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private let taskService = TaskService()
    private var viewModel: TaskDetailViewModel!
    
    var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configBinding()
    }
    
    func configBinding() {
        viewModel = TaskDetailViewModel(taskService: taskService, taskId: (task?.id)!)
        
        titleTextField.rx.text
            .orEmpty
            .bind(to: viewModel.titleText)
            .disposed(by: disposeBag)
        
        descriptionTextView.rx.text
            .orEmpty
            .bind(to: viewModel.descriptionText)
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
    }
    
    func setupViews() {
        titleTextField.text = task?.title
        descriptionTextView.text = task?.description
        importantImageView.image = (task?.important)! ? #imageLiteral(resourceName: "ic-important-white") : #imageLiteral(resourceName: "ic-important-fade")
        urgentImageView.image = (task?.urgent)! ? #imageLiteral(resourceName: "ic-urgent-white") : #imageLiteral(resourceName: "ic-urgent-fade")
        dateLabel.text = task?.createdAt.getStrDate()
    }
}
