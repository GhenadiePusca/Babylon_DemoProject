//
//  CacheValidaitonUseCaseTests.swift
//  PostsTests
//
//  Created by Pusca Ghenadie on 14/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import XCTest
import Posts
import RxSwift

class CacheValidationUseCaseTests: XCTestCase {
    func test_init_cacheRemainsIntactOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedCommands, [])
    }
    
    func test_load_deletesTheCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalEror = anyNSError()
        
        store.onRetrieveResult = .error(retrievalEror)
        _ = sut.validateCache()
        
        XCTAssertEqual(store.receivedCommands, [.retrieve, .delete])
    }
    
    func test_load_doesNotDeleteTheCacheOnRetrievalSuccess() {
        let (sut, store) = makeSUT()
        let cachedItems = anyItems().map { $0.toLocal }
        
        store.onRetrieveResult = .success(cachedItems)
        _ = sut.validateCache()
        
        XCTAssertEqual(store.receivedCommands, [.retrieve])
    }
    
    // MARK: - Helpers

    private func makeSUT() -> (sut: LocalPostsLoader, store: PostsStoreSpy) {
        let store = PostsStoreSpy()
        let sut = LocalPostsLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return (sut, store)
    }
}
