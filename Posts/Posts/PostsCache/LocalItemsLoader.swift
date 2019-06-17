//
//  GenericLocalLoader.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation
import RxSwift

public class LocalItemsLoader<Item, LocalItem>: ItemsLoader, ItemsStorageManager {
    private let disposeBag = DisposeBag()
    
    public typealias LocalToItemMapper = ([LocalItem]) -> [Item]
    public typealias ItemToLocalMapper = ([Item]) -> [LocalItem]
    public typealias ItemType = Item

    private let store: AnyItemsStore<LocalItem>
    private let localToItemMapper: LocalToItemMapper
    private let itemToLocalMapper: ItemToLocalMapper
    
    public init(store: AnyItemsStore<LocalItem>,
                localToItemMapper: @escaping LocalToItemMapper,
                itemToLocalMapper: @escaping ItemToLocalMapper) {
        self.store = store
        self.localToItemMapper = localToItemMapper
        self.itemToLocalMapper = itemToLocalMapper
    }
    
    public func save(_ items: [ItemType]) -> Completable {
        let mapper = self.itemToLocalMapper
        return store.deleteItems().andThen(store.savePosts(mapper(items)))
    }
    
    public func load() -> Single<[ItemType]> {
        let mapper = self.localToItemMapper
        return store.retrieve().map { mapper($0) }
    }
    
    public func validatePersistedItems() {
        store.retrieve().catchError { [weak self] error in
            self?.deleteCache()
            return .error(error)
        }.subscribe().disposed(by: disposeBag)
    }
    
    private func deleteCache() {
        store.deleteItems().subscribe().disposed(by: disposeBag)
    }
}
