//
//  ProfileViewModel.swift
//  EEH
//
//  Created by nawin on 3/30/18.
//  Copyright © 2018 tek5. All rights reserved.
//

import RxSwift

protocol ProfileViewModelType {
    
    // MARK: - Input
    var showCommentsDidTap: PublishSubject<Void> { get }
    
    // MARK: - Output
    var image: Observable<UIImage> { get }
    var username: String { get }
//    var showComments: Observable<CommentsViewModeling> { get }
}

class ProfileViewModel {
    
//    // MARK: - Input
//    let showCommentsDidTap: PublishSubject<Void> = PublishSubject<Void>()
//
//    // MARK: - Output
//    let image: Observable<UIImage>
//    let username: String
//    let showComments: Observable<CommentsViewModeling>
//
//    init(network: Networking, user: GitHubUser, commentService: CommentServicing) {
//        let placeholder = ""
//        image = Observable.just(placeholder)
//            .concat(network.image(url: user.avatarUrl))
//            .observeOn(MainScheduler.instance)
//            .catchErrorJustReturn(placeholder)
//
//        username = user.username
//
//        showComments = showCommentsDidTap
//            .map { CommentsViewModel(
//                commentsService: commentService,
//                username: user.username) }
//    }
    
}
