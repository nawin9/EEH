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
    
    var registerViewModel: RegisterViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerViewModel = RegisterViewModel(disposeBag: disposeBag)
        configBinding()
    }
    
    func configBinding() {
        emailTextField.rx.text
            .orEmpty
            .bind(to: registerViewModel.emailText)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text
            .orEmpty
            .bind(to: registerViewModel.passwordText)
            .disposed(by: disposeBag)
        
        rePasswordTextField.rx.text
            .orEmpty
            .bind(to: registerViewModel.rePasswordText)
            .disposed(by: disposeBag)
        
        (registerButton.rx.tap)
            .bind(to: registerViewModel.registerButtonTap)
            .disposed(by: disposeBag)
        
        registerViewModel.isValid
            .bind(to: registerButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
