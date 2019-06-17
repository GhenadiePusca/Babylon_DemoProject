//
//  ItemsStore.swift
//  Posts
//
//  Created by Pusca Ghenadie on 17/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import RxSwift

public protocol ItemsStore {
    associatedtype ItemType
    func deleteItems() -> Completable
    func savePosts(_ items: [ItemType]) -> Completable
    func retrieve() -> Single<[ItemType]>
}

public class AnyItemsStore<T>: ItemsStore {
    public typealias ItemType = T
    private let _deleteItems: () -> Completable
    private let _savePosts: (_ items: [ItemType]) -> Completable
    private let _retrieve: () -> Single<[ItemType]>
    
    public init<S: ItemsStore>(_ itemsStore: S) where S.ItemType == T {
        _deleteItems = itemsStore.deleteItems
        _savePosts = itemsStore.savePosts
        _retrieve = itemsStore.retrieve
    }
    
    public func deleteItems() -> Completable {
        return _deleteItems()
    }
    
    public func savePosts(_ items: [ItemType]) -> Completable {
        return _savePosts(items)
    }
    
    public func retrieve() -> Single<[ItemType]> {
        return _retrieve()
    }
}
