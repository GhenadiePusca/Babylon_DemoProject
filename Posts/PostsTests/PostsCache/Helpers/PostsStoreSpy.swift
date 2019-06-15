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

class PostsStoreSpy: PostsStore {
    
    // MARK: - Commands
    enum Command: Equatable {
        case delete
        case insert([LocalPostItem])
        case retrieve
    }
    
    private(set) var receivedCommands = [Command]()
    
    // MARK: - Private
    private static let notSetError = NSError(domain: "not provided", code: 1)
    
    // MARK: - Stub properties
    
    var onDeletionResult: CompletableEvent = .error(PostsStoreSpy.notSetError)
    var onSaveResult: CompletableEvent = .error(PostsStoreSpy.notSetError)
    var onRetrieveResult: SingleEvent<RetrieveResult> = .error(PostsStoreSpy.notSetError)
    
    // MAARK: - PostsStore protocol conformance

    func deleteCachedPosts() -> Completable {
        return .create(subscribe: { completable in
            self.receivedCommands.append(.delete)
            completable(self.onDeletionResult)
            return Disposables.create {}
        })
    }
    
    func savePosts(_ items: [LocalPostItem]) -> Completable {
        return .create(subscribe: { completable in
            self.receivedCommands.append(.insert(items))
            completable(self.onSaveResult)
            return Disposables.create {}
        })
    }
    
    func retrieve() -> Single<RetrieveResult> {
        return .create(subscribe: { single in
            self.receivedCommands.append(.retrieve)
            single(self.onRetrieveResult)
            return Disposables.create {}
        })
    }
}
