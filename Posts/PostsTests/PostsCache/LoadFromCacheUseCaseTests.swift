//
//  LoadFromCacheUseCaseTests.swift
//  PostsTests
//
//  Created by Pusca Ghenadie on 14/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import XCTest
import Posts
import RxSwift

class LoadFromCacheUseCaseTests: XCTestCase {
    
    func test_init_cacheRemainsIntactOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedCommands, [])
    }

    private func makeSUT() -> (sut: LocalPostsLoader, store: PostsStoreSpy) {
        let store = PostsStoreSpy()
        let sut = LocalPostsLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return (sut, store)
    }

    private class PostsStoreSpy: PostsStore {
        
        // MARK: - Commands
        enum Command: Equatable {
            case delete
            case insert([LocalPostItem])
        }
        
        private(set) var receivedCommands = [Command]()
        
        // MARK: - Private
        private static let notSetError = NSError(domain: "not provided", code: 1)
        
        // MARK: - Stub properties
        
        var onDeletionResult: SingleEvent<Void> = .error(PostsStoreSpy.notSetError)
        var onSaveResult: SingleEvent<Void> = .error(PostsStoreSpy.notSetError)
        
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
    }

}
