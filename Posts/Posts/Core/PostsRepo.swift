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

public final class PostsRepo: PostsDataProvider {
    private let postsLoader: AnyItemsLoader<PostItem>
    private let commentsLoader: AnyItemsLoader<CommentItem>
    private let usersLoader: AnyItemsLoader<UserItem>

    private let disposeBag = DisposeBag()
    
    private let postsLoaderSubject = BehaviorSubject<Loadable<[PostListItemModel]>>(value: .pending)
    public lazy var postItemsLoader = postsLoaderSubject.asObservable()

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
        usersLoader.load().subscribe { result in
            switch result {
            case .success(let comments):
                break
            case .error(let err):
                break
            }
        }
    }
    
    private func handlePostsResult(result: SingleEvent<[PostItem]>) {
        switch result {
        case .success(let items):
            self.loadedPostItems = items.reduce(into: [Int: PostItem](), {
                $0[$1.id] = $1
            })
            self.postsLoaderSubject.onNext(.loaded(items.toPostListItems))
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
