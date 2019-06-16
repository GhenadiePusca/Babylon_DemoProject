//
//  RemotePostsLoaderWithLocalFallback.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import RxSwift

public final class RemotePostsLoaderWithLocalFallback: PostsLoader {
    
    private let remoteLoader: PostsLoader
    private let localPostsLoader: PostsLoader & PostsPersister
    
    public init(remoteLoader: PostsLoader, localPostsLoader: PostsLoader & PostsPersister) {
        self.remoteLoader = remoteLoader
        self.localPostsLoader = localPostsLoader
    }
    
    public func load() -> Single<LoadResult> {
        return remoteLoader.load().do(onSuccess: cacheFetchedItems).catchError(localCacheFallback)
    }
    
    private func cacheFetchedItems(items: [PostItem]) {
        localPostsLoader.save(items).subscribe().dispose()
    }
    
    private func localCacheFallback(remoteLoadError: Error) -> Single<LoadResult> {
        return localPostsLoader.load().catchErrorJustReturn([]).flatMap(validateCachedItems)
    }
    
    private func validateCachedItems(items: [PostItem]) -> Single<LoadResult> {
        return .create { single in
            if items.isEmpty {
                single(.error(NSError(domain: "Failed to load data", code: 1)))
            } else {
                single(.success(items))
            }
            return Disposables.create()
        }
    }
}
