//
//  ItemsLoader.swift
//  Posts
//
//  Created by Pusca Ghenadie on 17/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import RxSwift

public protocol ItemsLoader {
    associatedtype Item
    func load() -> Single<[Item]>
}

public class AnyItemsLoader<T>: ItemsLoader {
    public typealias Item = T
    private let _load: () -> Single<[Item]>
    
    public init<L: ItemsLoader>(_ itemsLoader: L) where L.Item == T {
        _load = itemsLoader.load
    }
    
    public func load() -> Single<[Item]> {
        return _load()
    }
}
