//
//  TaskCreateViewController.swift
//  EEH
//
//  Created by nawin on 4/2/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TaskCreateViewController: UIViewController {
    
    @IBAction func dismissPopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var createTaskButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    private let taskService = TaskService()
    private let disposeBag = DisposeBag()
    private var viewModel: TaskCreateViewModel!
    private let taskTypes = ["Regular", "Important", "Urgent", "Important+Urgent"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configBinding()
    }
    
    // MARK: Config binding
    func configBinding() {
        viewModel = TaskCreateViewModel(taskService: taskService)
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
                self.createTaskButton.isEnabled = isValid
                self.createTaskButton.backgroundColor = isValid ? UIColor.init(red: 255.0/255, green: 185.0/255, blue: 55.0/255, alpha: 0.9) : .gray
            })
            .disposed(by: disposeBag)
        
        viewModel
            .isLoading
            .subscribe(onNext: { [unowned self] loading in
                print("loading ", loading)
                if loading {
                    SwiftLoader.show(title: "Loading...", animated: true)
                } else {
                    SwiftLoader.hide()
                    self.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
        
        (createTaskButton.rx.tap)
            .bind(to: viewModel.createButtonDidTap)
            .disposed(by: disposeBag)
        
        Observable
            .of(taskTypes)
            .bind(to: pickerView.rx.itemTitles) { (row, element) in
                return element
            }
            .disposed(by: disposeBag)
        
        pickerView
            .rx
            .modelSelected(String.self)
            .map({ $0[0] == "Important" || $0[0] == "Important+Urgent" })
            .bind(to: viewModel.importantBool)
            .disposed(by: disposeBag)

        pickerView
            .rx
            .modelSelected(String.self)
            .map({ $0[0] == "Urgent" || $0[0] == "Important+Urgent" })
            .bind(to: viewModel.urgentBool)
            .disposed(by: disposeBag)
    }
    
}

