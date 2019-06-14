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
    
    var onDeletionResult: SingleEvent<Void> = .error(PostsStoreSpy.notSetError)
    var onSaveResult: SingleEvent<Void> = .error(PostsStoreSpy.notSetError)
    var onRetrieveResult: SingleEvent<RetrieveResult> = .error(PostsStoreSpy.notSetError)
    
    // MAARK: - PostsStore protocol conformance

    func deleteCachedPosts() -> Single<Void> {
        receivedCommands.append(.delete)
        return .create(subscribe: { single in
            single(self.onDeletionResult)
            return Disposables.create {}
        })
    }
    
    func savePosts(_ items: [LocalPostItem]) -> Single<Void> {
        receivedCommands.append(.insert(items))
        return .create(subscribe: { single in
            single(self.onSaveResult)
            return Disposables.create {}
        })
    }
    
    func retrieve() -> Single<RetrieveResult> {
        receivedCommands.append(.retrieve)
        return .create(subscribe: { single in
            single(self.onRetrieveResult)
            return Disposables.create {}
        })
    }
}
