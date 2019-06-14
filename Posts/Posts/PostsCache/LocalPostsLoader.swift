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
    
    public typealias LoadResult = [PostItem]

    public init(store: PostsStore) {
        self.store = store
    }
    
    public func save(_ items: [PostItem]) -> Single<Void> {
        return store.deleteCachedPosts().flatMap { self.store.savePosts(items.toLocal()) }
    }
    
    public func load() -> Single<LoadResult> {
        return store.retrieve().map { $0.toPostItems() }
    }
    
    public func validateCache() {
        _ = store.retrieve().catchError { error in
            self.deleteCache()
            return .error(error)
        }.subscribe()
    }
    
    private func deleteCache() {
        _ = self.store.deleteCachedPosts().subscribe()
    }
}

private extension PostItem {
    var toLocal: LocalPostItem {
        return LocalPostItem(id: id,
                             userId: userId,
                             title: title,
                             body: body)
    }
}

private extension LocalPostItem {
    var toLocal: PostItem {
        return PostItem(id: id,
                        userId: userId,
                        title: title,
                        body: body)
    }
}

private extension Array where Element == PostItem {
    func toLocal() -> [LocalPostItem] {
        return map { $0.toLocal }
    }
}

private extension Array where Element == LocalPostItem {
    func toPostItems() -> [PostItem] {
        return map { $0.toLocal }
    }
}
