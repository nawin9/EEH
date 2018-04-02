//
//  MainViewController.swift
//  EEH
//
//  Created by nawin on 3/30/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Firebase
import FirebaseAuth

class MainViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let disposeBag = DisposeBag()
    private let taskService = TaskService()
    private var viewModel: MainViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if let navCtrl = self.navigationController {
            navCtrl.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navCtrl.navigationBar.shadowImage = UIImage()
            navCtrl.navigationBar.isTranslucent = true
            navCtrl.view.backgroundColor = .clear
            navCtrl.navigationBar.tintColor = .white
            navCtrl.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }
        setupViews()
        configBinding()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "uid") { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "idLoginViewController") as! LoginViewController
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    // MARK: Config binding
    func configBinding() {
        viewModel = MainViewModel(taskService: taskService)
        viewModel
            .tasks
            .bind(to: self.collectionView.rx.items(cellIdentifier: "idTaskCell", cellType: TaskCell.self)) { row , element, cell in
                if row == 0 {
                    cell.setupDefaultCell()
                } else {
                    cell.setupCell(task: element)
                }
                
            }
            .disposed(by: disposeBag)

        collectionView
            .rx
            .itemHighlighted
            .subscribe(onNext: { indexPath in
                UIView.animate(withDuration: 0.5) {
                    if let cell = self.collectionView.cellForItem(at: indexPath) as? TaskCell {
                        cell.transform = .init(scaleX: 0.95, y: 0.95)
                        cell.contentView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        collectionView
            .rx
            .itemUnhighlighted
            .subscribe(onNext: { [weak self] indexPath in
                UIView.animate(withDuration: 0.5) {
                    if let cell = self?.collectionView.cellForItem(at: indexPath) as? TaskCell {
                        cell.transform = .identity
                        cell.contentView.backgroundColor = .clear
                    }
                }
            })
            .disposed(by: disposeBag)
        
        collectionView
            .rx
            .itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                if indexPath.row > 0 {
                    self?.performSegue(withIdentifier: "segueTaskDetail", sender: indexPath)
                } else {
                    self?.performSegue(withIdentifier: "segueTaskCreate", sender: indexPath)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func initialize() {
        let observable = Observable<Void>.create { observer -> Disposable in
            observer.on(.next(Void()))
            observer.on(.completed)
            return Disposables.create()
        }
        viewModel.bindObservableToFetchTasks(observable)
    
    }
    
    func setupViews() {
        collectionView.delegate = nil
        collectionView.dataSource = nil
        let flowLayout = UICollectionViewFlowLayout()
        let padding: CGFloat =  20
        let collectionViewSize = collectionView.frame.size.width - padding
        flowLayout.itemSize = CGSize(width: collectionViewSize/2, height: 100)
        flowLayout.minimumLineSpacing = 20
        flowLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20)
        collectionView.setCollectionViewLayout(flowLayout, animated: true)
    }
    
}

extension MainViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueTaskDetail" {
            if let _ = segue.destination as? TaskDetailViewController {
//                destinationVC.numberToDisplay = counter
                print(sender as! IndexPath)
            }
        } else if segue.identifier == "segueTaskCreate" {
            if let _ = segue.destination as? TaskCreateViewController {
                print(sender as! IndexPath)
            }
        }
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  60
        let collectionViewSize = collectionView.frame.size.width - padding
        return CGSize(width: collectionViewSize/2, height: 100)
    }

}
