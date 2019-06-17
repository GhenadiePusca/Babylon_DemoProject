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

    private let disposeBag = DisposeBag()
    
    private let postsLoaderSubject = BehaviorSubject<Loadable<[PostListItemModel]>>(value: .pending)
    public lazy var postItemsLoader = postsLoaderSubject.asObservable()

    private var loadedPostItems = [Int: PostItem]()
    
    public init(postsLoader: AnyItemsLoader<PostItem>,
                commentsLoader: AnyItemsLoader<CommentItem>) {
        self.postsLoader = postsLoader
        self.commentsLoader = commentsLoader
    }
    
    public func loadPosts() {
        postsLoaderSubject.onNext(.loading)
        postsLoader.load().subscribe(handlePostsResult).disposed(by: disposeBag)
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
