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
        sut.validatePersistedItems()
        
        XCTAssertEqual(store.receivedCommands, [.retrieve, .delete])
    }
    
    func test_load_doesNotDeleteTheCacheOnRetrievalSuccess() {
        let (sut, store) = makeSUT()
        let cachedItems = anyItems().map { $0.toLocal }
        
        store.onRetrieveResult = .success(cachedItems)
        sut.validatePersistedItems()
        
        XCTAssertEqual(store.receivedCommands, [.retrieve])
    }
    
    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file,
                         line: UInt = #line) -> (sut: AnyItemsStorageManager<PostItem>, store: PostsStoreSpy<LocalPostItem>) {
        let store = PostsStoreSpy<LocalPostItem>()
        let sut = LocalItemsLoader<PostItem, LocalPostItem>.init(store: AnyItemsStore(store),
                                                                     localToItemMapper: Mapper.localPostsToPost,
                                                                     itemToLocalMapper: Mapper.postToLocalPosts)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (AnyItemsStorageManager(sut), store)
    }
}
