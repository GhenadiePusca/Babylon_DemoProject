//
//  PostsStoreSpy.swift
//  PostsTests
//
//  Created by Pusca Ghenadie on 14/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation
import Posts
import RxSwift

class PostsStoreSpy<SavedItem: Equatable>: ItemsStore {

    
    public typealias ItemType = SavedItem

    // MARK: - Commands
    enum Command: Equatable {
        case delete
        case insert([SavedItem])
        case retrieve
    }
    
    private(set) var receivedCommands = [Command]()
    
    // MARK: - Private
    private var notSetError: NSError {
        return NSError(domain: "not provided", code: 1)
    }
    
    // MARK: - Stub properties

    lazy var onDeletionResult: CompletableEvent = .error(notSetError)
    lazy var onSaveResult: CompletableEvent = .error(notSetError)
    lazy var onRetrieveResult: SingleEvent<[SavedItem]> = .error(notSetError)

    func savePosts(_ items: [SavedItem]) -> Completable {
        return .create(subscribe: { completable in
            self.receivedCommands.append(.insert(items))
            completable(self.onSaveResult)
            return Disposables.create {}
        })
    }
    
    func retrieve() -> PrimitiveSequence<SingleTrait, Array<SavedItem>> {
        return .create(subscribe: { single in
            self.receivedCommands.append(.retrieve)
            single(self.onRetrieveResult)
            return Disposables.create {}
        })
    }
    
    func deleteItems() -> Completable {
        return .create(subscribe: { completable in
            self.receivedCommands.append(.delete)
            completable(self.onDeletionResult)
            return Disposables.create {}
        })
    }
}
