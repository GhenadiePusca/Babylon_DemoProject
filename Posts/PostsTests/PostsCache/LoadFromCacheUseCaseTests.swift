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
        
        _ = sut.load().subscribe { _ in }
        
        XCTAssertEqual(store.receivedCommands, [.retrieve])
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
        _ = sut.load().subscribe { _ in }
        
        XCTAssertEqual(store.receivedCommands, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnSuccesfulLoad() {
        let (sut, store) = makeSUT()
        let cachedPostItems = anyItems().map { $0.toLocal }
        
        store.onRetrieveResult = .success(cachedPostItems)
        _ = sut.load().subscribe { _ in }
        
        XCTAssertEqual(store.receivedCommands, [.retrieve])
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

    private func makeSUT(file: StaticString = #file,
                         line: UInt = #line) -> (sut: LocalPostsLoader, store: PostsStoreSpy) {
        let store = PostsStoreSpy()
        let sut = LocalPostsLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalPostsLoader,
                        toCompleteWithResult expectedResult: SingleEvent<LocalPostsLoader.LoadResult>,
                        withStub stub: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        stub()
        
        _ = sut.load().subscribe { result in
            switch (result, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.error(receivedError), .error(expectedError)):
                XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, file: file, line: line)
            default:
                XCTFail("expected \(expectedResult), got \(result)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
