//
//  ItemsStorageManager.swift
//  Posts
//
//  Created by Pusca Ghenadie on 17/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import RxSwift

public protocol ItemsStorageManager {
    associatedtype Item
    func save(_ items: [Item]) -> Completable
    func validatePersistedItems()
}

public class AnyItemsStorageManager<T>: ItemsLoader, ItemsStorageManager {
    public typealias Item = T
    private let _load: () -> Single<[Item]>
    private let _save: ([Item]) -> Completable
    private let _validatePersistedItems: () -> ()
    
    public init<L: ItemsLoader & ItemsStorageManager>(_ itemsLoader: L) where L.Item == T {
        _load = itemsLoader.load
        _save = itemsLoader.save
        _validatePersistedItems = itemsLoader.validatePersistedItems
    }
    
    public func load() -> Single<[Item]> {
        return _load()
    }
    
    public func save(_ items: [Item]) -> Completable {
        return _save(items)
    }
    
    public func validatePersistedItems() {
        return _validatePersistedItems()
    }
}
