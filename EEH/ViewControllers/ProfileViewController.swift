//
//  ProfileViewController.swift
//  EEH
//
//  Created by nawin on 4/1/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBAction func logoutCurrentUser(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "uid")
            defaults.removeObject(forKey: "email")
            self.navigationController?.popViewController(animated: false)
        } catch let err {
            print(err)
        }
    }
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var saveProfileButton: UIButton!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private let profileService = ProfileService()
    private var viewModel: ProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configBinding()
    }
    
    func configBinding() {
        viewModel = ProfileViewModel(profileService: profileService)
        
        nameTextField.rx.text
            .orEmpty
            .bind(to: viewModel.nameText)
            .disposed(by: disposeBag)
        
        descriptionTextView.rx.text
            .orEmpty
            .bind(to: viewModel.descriptionText)
            .disposed(by: disposeBag)
        
        viewModel.nameText
            .asObservable()
            .bind(to: nameTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.descriptionText
            .asObservable()
            .bind(to: descriptionTextView.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.emailText
            .asObservable()
            .map { Optional($0) }
            .bind(to: emailLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.isValid
            .subscribe(onNext: { [unowned self] isValid in
                self.saveProfileButton.isEnabled = isValid
                self.saveProfileButton.backgroundColor = isValid ? UIColor.init(red: 255.0/255, green: 185.0/255, blue: 55.0/255, alpha: 0.9) : .gray
            })
            .disposed(by: disposeBag)
        
        (saveProfileButton.rx.tap)
            .bind(to: viewModel.saveButtonDidTap)
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
            
        let tapGesture = UITapGestureRecognizer()
        avatarImageView.addGestureRecognizer(tapGesture)
        avatarImageView.isUserInteractionEnabled = true
        tapGesture
            .rx
            .event
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController
                    .rx
                    .createWithParent(self) { picker in
                        picker.sourceType = .photoLibrary
                        picker.allowsEditing = false
                    }
                    .flatMap {
                        $0.rx.didFinishPickingMediaWithInfo
                    }
                    .take(1)
            }
            .map { info in
                return info[UIImagePickerControllerOriginalImage] as? UIImage
            }
            .bind(to: avatarImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.callToFetchProfile()
    }
    
}
