//
//  RemotePostsLoaderWithLocalFallback.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import RxSwift

public final class RemotePostsLoaderWithLocalFallback<Item>: ItemsLoader {
    
    private let remoteLoader: AnyItemsLoader<Item>
    private let localPostsLoader: AnyItemsStorageManager<Item>
    private let disposeBag = DisposeBag()
    
    public init(remoteLoader: AnyItemsLoader<Item>,
                localPostsLoader: AnyItemsStorageManager<Item>) {
        self.remoteLoader = remoteLoader
        self.localPostsLoader = localPostsLoader
    }
    
    public func load() -> Single<[Item]> {
        return remoteLoader.load().do(onSuccess: cacheFetchedItems).catchError(localCacheFallback)
    }
    
    private func cacheFetchedItems(items: [Item]) {
        localPostsLoader.save(items).subscribe().disposed(by: disposeBag)
    }
    
    private func localCacheFallback(remoteLoadError: Error) -> Single<[Item]> {
        return localPostsLoader.load().catchErrorJustReturn([]).flatMap(validateCachedItems)
    }
    
    private func validateCachedItems(items: [Item]) -> Single<[Item]> {
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
