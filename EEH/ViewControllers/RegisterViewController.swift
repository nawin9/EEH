//
//  RegisterViewController.swift
//  EEH
//
//  Created by nawin on 3/30/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rePasswordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var returnLoginButton: UIButton!
    
    @IBAction func dismissRegisterView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    var viewModel: RegisterViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configBinding()
    }
    
    func configBinding() {
        viewModel = RegisterViewModel()
        
        emailTextField.rx.text
            .orEmpty
            .bind(to: viewModel.emailText)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text
            .orEmpty
            .bind(to: viewModel.passwordText)
            .disposed(by: disposeBag)
        
        rePasswordTextField.rx.text
            .orEmpty
            .bind(to: viewModel.rePasswordText)
            .disposed(by: disposeBag)
        
        (registerButton.rx.tap)
            .bind(to: viewModel.registerButtonTap)
            .disposed(by: disposeBag)
        
        viewModel.isValid
            .bind(to: registerButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel
            .userObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] user in
                if user != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
        
    }
}
