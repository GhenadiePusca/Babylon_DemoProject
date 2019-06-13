//
//  LocalPostsLoader.swift
//  Posts
//
//  Created by Pusca Ghenadie on 13/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import RxSwift

public class LocalPostsLoader {
    private let store: PostsStore
    
    public init(store: PostsStore) {
        self.store = store
    }
    
    public func save(_ items: [PostItem]) -> Single<Void> {
        return store.deleteCachedPosts().flatMap { self.store.savePosts(items) }
    }
}
