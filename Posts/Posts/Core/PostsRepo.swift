//
//  PostsRepo.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public final class PostsRepo: PostsDataProvider {
    
    private let postsLoader: AnyItemsLoader<PostItem>
    private let commentsLoader: AnyItemsLoader<CommentItem>
    private let usersLoader: AnyItemsLoader<UserItem>

    private let disposeBag = DisposeBag()
    
    private let postsLoaderSubject = BehaviorSubject<Loadable<[PostItem]>>(value: .pending)
    private let usersLoaderSubject = BehaviorSubject<Loadable<[UserItem]>>(value: .pending)
    private let commentsLoaderSubject = BehaviorSubject<Loadable<[CommentItem]>>(value: .pending)

    public lazy var postItemsLoader = postsLoaderSubject.map { $0.transform { items in items.toPostListItems } }.asObservable()
    public let reloadBehavior = BehaviorRelay<Bool>(value: false)
    
    public init(postsLoader: AnyItemsLoader<PostItem>,
                commentsLoader: AnyItemsLoader<CommentItem>,
                usersLoader: AnyItemsLoader<UserItem>) {
        self.postsLoader = postsLoader
        self.commentsLoader = commentsLoader
        self.usersLoader = usersLoader
        
        reloadBehavior.filter { $0 == true }.subscribe(onNext: { [weak self] _ in
            self?.loadPosts()
        }).disposed(by: disposeBag)
    }
    
    public func loadPosts() {
        postsLoaderSubject.onNext(.loading)
        postsLoader.load().subscribe(handlePostsResult).disposed(by: disposeBag)
    }
    
    public func postDetailModel(index: Int) -> PostDetailsModel {
        guard let loadedData = try? postsLoaderSubject.value().loadedData,
            let postItem = loadedData?[index] else {
            fatalError()
        }
        return PostDetailsModel(title: postItem.title,
                                body: postItem.body,
                                authorName: authorForPost(postId: postItem.id).asObservable(),
                                numberOfComments: numberOfComments(postId: postItem.id).asObservable())
    }
    
    private func loadUsers() {
        usersLoaderSubject.onNext(.loading)
        usersLoader.load().subscribe(handleUsersResult).disposed(by: disposeBag)
    }
    
    private func loadComments() {
        commentsLoaderSubject.onNext(.loading)
        commentsLoader.load().subscribe(handleCommentsResult).disposed(by: disposeBag)
    }

    private func authorForPost(postId: Int) -> BehaviorSubject<Loadable<String>> {
        if (try? usersLoaderSubject.value().shouldReload) == true {
            self.loadUsers()
        }

        let authorName = BehaviorSubject<Loadable<String>>(value: .pending)
        
        Observable.combineLatest(postsLoaderSubject, usersLoaderSubject) { postsLoadable, usersLoadable in
            return postsLoadable.transform { items in
                return items.first { $0.id == postId }!.userId
            }.combine(usersLoadable).transform { userId, users in
                return users.first { $0.id == userId }!.name
            }
        }.bind(to: authorName).disposed(by: disposeBag)
        
        return authorName
    }
    
    private func numberOfComments(postId: Int) -> BehaviorSubject<Loadable<Int>> {
        if (try? commentsLoaderSubject.value().shouldReload) == true {
            loadComments()
        }
    
        let numberOfComments = BehaviorSubject<Loadable<Int>>(value: .pending)
        
        commentsLoaderSubject.map { commentsLoadable in
            return commentsLoadable.transform { comments in
                comments.reduce(into: 0, { result, comment in
                    result += comment.postId == postId ? 1 : 0
                })
            }
        }.asObservable().bind(to: numberOfComments).disposed(by: disposeBag)

        return numberOfComments
    }
    
    private lazy var handleUsersResult: (SingleEvent<[UserItem]>) -> Void = { [weak self] result in
        guard let self = self else { return }
        switch result {
        case .success(let items):
            self.usersLoaderSubject.onNext(.loaded(items))
        default:
            self.usersLoaderSubject.onNext(.failed(NSError(domain: "failed to load", code: 1)))
        }
    }
    
    private lazy var handleCommentsResult: (SingleEvent<[CommentItem]>) -> Void = { [weak self] result in
        guard let self = self else { return }
        switch result {
        case .success(let items):
            self.commentsLoaderSubject.onNext(.loaded(items))
        default:
            self.commentsLoaderSubject.onNext(.failed(NSError(domain: "failed to load", code: 1)))
        }
    }

    private lazy var  handlePostsResult: (SingleEvent<[PostItem]>) -> Void = { [weak self] result in
        guard let self = self else { return }
        switch result {
        case .success(let items):
            self.postsLoaderSubject.onNext(.loaded(items))
        default:
            self.postsLoaderSubject.onNext(.failed(NSError(domain: "failed to load", code: 1)))
        }
    }
}

fileprivate extension Array where Element == PostItem {
    var toPostListItems: [PostListItemModel] {
        return map { PostListItemModel(postName: $0.title) }
    }
}
