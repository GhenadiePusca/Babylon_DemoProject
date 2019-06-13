//
//  CachedPostsUseCaseTests.swift
//  PostsTests
//
//  Created by Pusca Ghenadie on 13/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import XCTest
import Posts
import RxSwift

class LocalPostsLoader {
    let store: PostsStore
    
    init(store: PostsStore) {
        self.store = store
    }
    
    func save(_ items: [PostItem]) -> Single<Void> {
        return store.deleteCachedPosts()
    }
}

class PostsStore {
    enum Command: Equatable {
        case delete
        case insert([PostItem])
    }
    
    private(set) var receivedCommands = [Command]()
    
    func deleteCachedPosts() -> Single<Void> {
        receivedCommands.append(.delete)
        return .just(())
    }
}

class CachedPostsUseCaseTests: XCTestCase {
    
    func test_init_cacheReminsIntactOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedCommands, [])
    }
    
    func test_save_requestsCacheDeletion() {
        
        let (sut, store) = makeSUT()
        let items = [anyItem(), anyItem()]
        
        _ = sut.save(items).subscribe { _ in }
        
        XCTAssertEqual(store.receivedCommands, [.delete])
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: LocalPostsLoader, store: PostsStore) {
        let store = PostsStore()
        let sut = LocalPostsLoader(store: store)
        
        return (sut, store)
    }

    private func anyItem() -> PostItem {
        return PostItem(id: 1, userId: 2, title: "any title", body: "any body")
    }
}
