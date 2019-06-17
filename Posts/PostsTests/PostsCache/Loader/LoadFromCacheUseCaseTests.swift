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
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        let disp = sut.load().subscribe()
        
        XCTAssertEqual(store.receivedCommands, [.retrieve])
        disp.dispose()
    }

    func test_load_deliversErrorOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalEror = anyNSError()

        expect(sut,
               toCompleteWithResult: .error(retrievalEror),
               withStub: {
                store.onRetrieveResult = .error(retrievalEror)
        })
    }
    
    func test_load_hasNoSideEffectsOnError() {
        let (sut, store) = makeSUT()
        let retrievalEror = anyNSError()
        
        store.onRetrieveResult = .error(retrievalEror)
        let disp = sut.load().subscribe()
        
        XCTAssertEqual(store.receivedCommands, [.retrieve])
        disp.dispose()
    }
    
    func test_load_hasNoSideEffectsOnSuccesfulLoad() {
        let (sut, store) = makeSUT()
        let cachedPostItems = anyItems().map { $0.toLocal }
        
        store.onRetrieveResult = .success(cachedPostItems)
        let disp = sut.load().subscribe()
        
        XCTAssertEqual(store.receivedCommands, [.retrieve])
        disp.dispose()
    }
    
    func test_load_deliversNoPostsOnEmptyCache() {
        let (sut, store) = makeSUT()
        let noPostItems = [PostItem]()
        let noCachePostItems = [LocalPostItem]()
        
        expect(sut,
               toCompleteWithResult: .success(noPostItems),
               withStub: {
                store.onRetrieveResult = .success(noCachePostItems)
        })
    }
    
    func test_load_deliversPostsOnCacheWithData() {
        let (sut, store) = makeSUT()
        let expectedPostItems = anyItems()
        let cachedPostItems = expectedPostItems.map { $0.toLocal }
        
        expect(sut,
               toCompleteWithResult: .success(expectedPostItems),
               withStub: {
                store.onRetrieveResult = .success(cachedPostItems)
        })
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: AnyItemsStorageManager<PostItem>, store: PostsStoreSpy<LocalPostItem>) {
        let store = PostsStoreSpy<LocalPostItem>()
        let sut = LocalItemsLoader<PostItem, LocalPostItem>.init(store: AnyItemsStore(store),
                                                                     localToItemMapper: Mapper.localPostsToPost,
                                                                     itemToLocalMapper: Mapper.postToLocalPosts)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return (AnyItemsStorageManager(sut), store)
    }
    
    private func expect(_ sut: AnyItemsStorageManager<PostItem>,
                        toCompleteWithResult expectedResult: SingleEvent<[PostItem]>,
                        withStub stub: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        stub()
        
        let disp = sut.load().subscribe { result in
            XCTAssertTrue(result.isSameAs(expectedResult),
                          "expected \(expectedResult), got \(result)", file: file, line: line)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        disp.dispose()
    }
}
