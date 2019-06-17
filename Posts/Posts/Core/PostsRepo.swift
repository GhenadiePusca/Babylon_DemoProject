//
//  PostsRepo.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation
import RxSwift

public protocol PostsDataProvider {
    var postItemsLoader: Observable<Loadable<[PostListItemModel]>> { get }
    func loadPosts()
}

struct PostDetailsModel {
    let title: String
    let body: String
    let authorName: Observable<Loadable<String>>
    let numberOfComments: Observable<Loadable<Int>>
}

public final class PostsRepo: PostsDataProvider {
    private let postsLoader: AnyItemsLoader<PostItem>
    private let commentsLoader: AnyItemsLoader<CommentItem>
    private let usersLoader: AnyItemsLoader<UserItem>

    private let disposeBag = DisposeBag()
    
    private let postsLoaderSubject = BehaviorSubject<Loadable<[PostItem]>>(value: .pending)
    private let usersLoaderSubject = BehaviorSubject<Loadable<[UserItem]>>(value: .pending)
    private let commentsLoaderSubject = BehaviorSubject<Loadable<[CommentItem]>>(value: .pending)

    public lazy var postItemsLoader = postsLoaderSubject.map { $0.transform { items in items.toPostListItems } }.asObservable()

    private var loadedPostItems = [Int: PostItem]()
    
    public init(postsLoader: AnyItemsLoader<PostItem>,
                commentsLoader: AnyItemsLoader<CommentItem>,
                usersLoader: AnyItemsLoader<UserItem>) {
        self.postsLoader = postsLoader
        self.commentsLoader = commentsLoader
        self.usersLoader = usersLoader
    }
    
    public func loadPosts() {
        postsLoaderSubject.onNext(.loading)
        postsLoader.load().subscribe(handlePostsResult).disposed(by: disposeBag)
    }
    
    func postDetailModel(postId: Int) -> PostDetailsModel {
        return PostDetailsModel(title: loadedPostItems[postId]!.title,
                         body: loadedPostItems[postId]!.body,
                         authorName: authorForPost(postId: postId).asObservable(),
                         numberOfComments: numberOfComments(postId: postId).asObservable())
    }
    
    func loadUsers() {
        usersLoaderSubject.onNext(.loading)
        usersLoader.load().subscribe(handleUsersResult).disposed(by: disposeBag)
    }
    
    func loadComments() {
        commentsLoaderSubject.onNext(.loading)
        commentsLoader.load().subscribe(handleCommentsResult).disposed(by: disposeBag)
    }

    func authorForPost(postId: Int) -> BehaviorSubject<Loadable<String>> {
        if try! usersLoaderSubject.value().shouldReload {
            loadUsers()
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
    
    func numberOfComments(postId: Int) -> BehaviorSubject<Loadable<Int>> {
        if try! commentsLoaderSubject.value().shouldReload {
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
    
    private func handleUsersResult(result: SingleEvent<[UserItem]>) {
        switch result {
        case .success(let items):
            self.usersLoaderSubject.onNext(.loaded(items))
        default:
            self.usersLoaderSubject.onNext(.failed(NSError(domain: "failed to loadd", code: 1)))
        }
    }
    
    private func handleCommentsResult(result: SingleEvent<[CommentItem]>) {
        switch result {
        case .success(let items):
            self.commentsLoaderSubject.onNext(.loaded(items))
        default:
            self.commentsLoaderSubject.onNext(.failed(NSError(domain: "failed to loadd", code: 1)))
        }
    }

    private func handlePostsResult(result: SingleEvent<[PostItem]>) {
        switch result {
        case .success(let items):
            self.postsLoaderSubject.onNext(.loaded(items))
        default:
            self.postsLoaderSubject.onNext(.failed(NSError(domain: "failed to loadd", code: 1)))
        }
    }
}

fileprivate extension Array where Element == PostItem {
    var toPostListItems: [PostListItemModel] {
        return map { PostListItemModel(postName: $0.title) }
    }
}
