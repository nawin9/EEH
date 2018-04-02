//
//  LoginViewController.swift
//  EEH
//
//  Created by nawin on 3/24/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth
//import JTMaterialTransition


class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var tkLoginButton: TKTransitionSubmitButton!
    
    var bottomConstraint: NSLayoutConstraint!
    var loginViewModel: LoginViewModel!
    let disposeBag = DisposeBag()
//    var transition: JTMaterialTransition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        self.tkLoginButton.layer.cornerRadius = 5
        loginViewModel = LoginViewModel()
        configBinding()
    }
    
    
    // MARK: Config Binding
    
    func configBinding() {
        emailTextField.rx.text
            .orEmpty
            .bind(to: loginViewModel.emailText)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text
            .orEmpty
            .bind(to: loginViewModel.passwordText)
            .disposed(by: disposeBag)
        
        (tkLoginButton.rx.tap)
            .bind(to: loginViewModel.loginButtonDidTap)
            .disposed(by: disposeBag)
        
        loginViewModel.isValid
            .subscribe(onNext: { [unowned self] isValid in
                self.tkLoginButton.isEnabled = isValid
                self.tkLoginButton.backgroundColor = isValid ? .green : .gray
            })
            .disposed(by: disposeBag)
        
        loginViewModel.userObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (user) in
                self.tkLoginButton.startLoadingAnimation()
                if user != nil {
                    let defaults = UserDefaults.standard
                    defaults.set(user?.uid, forKey: "uid")
                    defaults.set(user?.email, forKey: "email")
                    self.tkLoginButton.startFinishAnimation(1.5, completion: {
                        self.tkLoginButton.setOriginalState()
                        self.tkLoginButton.layer.cornerRadius = 5
                        self.dismiss(animated: false, completion: nil)
                    })
                }
            })
            .disposed(by: disposeBag)
    }
}

extension LoginViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TKFadeInAnimator(transitionDuration: 0.5, startingAlpha: 0.8)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideKeyboard()
    }
    
    func hideKeyboard() {
        [emailTextField, passwordTextField].forEach {
            $0.resignFirstResponder()
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo as Dictionary! else { return }
        guard let keyboardHeight = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
        guard let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        guard let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber else { return }
        print("keyboard")
        UIView.animate(withDuration: duration.doubleValue) {
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve.intValue)!)
            self.updateViewConstraintsForKeyboardHeight(keyboardHeight)
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo as Dictionary! else { return }
        guard let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        guard let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber else { return }
        
        UIView.animate(withDuration: duration.doubleValue) {
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve.intValue)!)
            self.updateViewConstraintsForKeyboardHeight(0)
        }
        
    }
    
    func updateViewConstraintsForKeyboardHeight(_ keyboardHeight: CGFloat) {
        if bottomConstraint != nil {
            self.view.removeConstraints([bottomConstraint!])
            bottomConstraint = nil
        }
        
        if keyboardHeight != 0 {
            bottomConstraint = NSLayoutConstraint(item: self.view,
                                                  attribute: NSLayoutAttribute.bottom,
                                                  relatedBy: NSLayoutRelation.equal,
                                                  toItem: self.tkLoginButton,
                                                  attribute: NSLayoutAttribute.bottom,
                                                  multiplier: 1.0,
                                                  constant: keyboardHeight)
            self.view.addConstraints([bottomConstraint!])
        }
        self.view.layoutIfNeeded()
    }
    
}
