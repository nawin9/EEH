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
    var refreshControl: UIRefreshControl!

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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "uid") {
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "idLoginViewController") as! LoginViewController
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initialize()
    }
    
    // MARK: Config binding
    func configBinding() {
        viewModel = MainViewModel(taskService: taskService)
        
        viewModel
            .tasks
            .bind(to: self.collectionView.rx.items(cellIdentifier: "idTaskCell", cellType: TaskCell.self)) { row , element, cell in
                if row > 0 {
                    cell.setupCell(task: element)
                } else {
                    cell.setupDefaultCell()
                }
            }
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
        
        collectionView
            .rx
            .itemHighlighted
            .subscribe(onNext: { [unowned self] indexPath in
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
            .subscribe(onNext: { [unowned self] indexPath in
                UIView.animate(withDuration: 0.5) {
                    if let cell = self.collectionView.cellForItem(at: indexPath) as? TaskCell {
                        cell.transform = .identity
                        cell.contentView.backgroundColor = .clear
                    }
                }
            })
            .disposed(by: disposeBag)
        
        collectionView
            .rx
            .itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                if indexPath.row > 0 {
                    self.performSegue(withIdentifier: "segueTaskDetail", sender: indexPath)
                } else {
                    self.performSegue(withIdentifier: "segueTaskCreate", sender: indexPath)
                }
            })
            .disposed(by: disposeBag)
        
        refreshControl
            .rx
            .controlEvent(.valueChanged)
            .map { _ in self.refreshControl.isRefreshing }
            .filter { $0 == true }
            .subscribe(onNext: { [unowned self] _ in
                self.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        viewModel.bindObservableToFetchTasks(refreshControl.rx.controlEvent(.valueChanged).asObservable())
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
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 150
        config.spinnerColor = .red
        config.foregroundColor = .black
        config.foregroundAlpha = 0.5
        SwiftLoader.setConfig(config: config)
        collectionView.delegate = nil
        collectionView.dataSource = nil
        let flowLayout = UICollectionViewFlowLayout()
        let padding: CGFloat =  20
        let collectionViewSize = collectionView.frame.size.width - padding
        flowLayout.itemSize = CGSize(width: collectionViewSize/2, height: 100)
        flowLayout.minimumLineSpacing = 20
        flowLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20)
        collectionView.setCollectionViewLayout(flowLayout, animated: true)
        
        refreshControl = UIRefreshControl()
        collectionView.alwaysBounceVertical = true
        refreshControl.tintColor = .green
        collectionView.addSubview(refreshControl)
    }
    
}

extension MainViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueTaskDetail" {
            if let destinationVC = segue.destination as? TaskDetailViewController {
                if let cell = self.collectionView.cellForItem(at: sender as! IndexPath) as? TaskCell, let task = cell.element {
                    destinationVC.taskId = task.id
                }
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
