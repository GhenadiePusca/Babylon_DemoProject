//
//  FileSystemPostsStoreTests.swift
//  PostsTests
//
//  Created by Pusca Ghenadie on 14/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import XCTest
import Posts
import RxSwift

protocol PostsStoreSpecs {
    func test_retrieve_deliversNoItemsOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversItemsOnNonEmptyCache()
    func test_retrieve_noSideEffectsOnSuccesfulRetrieve()
    func test_retrieve_deliversErorrOnInvalidData()
    func test_retrieve_noSideEffectsOnRetrievalError()

    func test_insert_overridesPreviouslyInsertedItems()
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()

    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_deletesPreviousInsertedCache()
    func test_storeSideEffects_runSerially()
}

class FileSystemPostsStoreTests: XCTestCase, PostsStoreSpecs {
    
    override func setUp() {
        super.setUp()
        
        setEmptyCache()
    }
    
    override func tearDown() {
        super.tearDown()
        
        removeCachedItems()
    }
    
    func test_retrieve_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        let noItems = [LocalPostItem]()

        expectRetrieval(toCompleteWithResult: .success(noItems), sut: sut)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let noItems = PostsStore.RetrieveResult()

        expectRetrieval(toCompleteWithResult: .success(noItems), sut: sut)
        expectRetrieval(toCompleteWithResult: .success(noItems), sut: sut)
    }
    
    func test_retrieve_deliversItemsOnNonEmptyCache() {
        let sut = makeSUT()
        let cachedItems = anyItems().map { $0.toLocal }
        let succesfulInsertion = CompletableEvent.completed
        
        expectInsertion(toCompleteWithResult: succesfulInsertion, sut: sut, itemsToCache: cachedItems)
        expectRetrieval(toCompleteWithResult: .success(cachedItems), sut: sut)
    }
    
    func test_retrieve_noSideEffectsOnSuccesfulRetrieve() {
        let sut = makeSUT()
        let cachedItems = anyItems().map { $0.toLocal }
        let succesfulInsertion = CompletableEvent.completed
        
        expectInsertion(toCompleteWithResult: succesfulInsertion, sut: sut, itemsToCache: cachedItems)
        expectRetrieval(toCompleteWithResult: .success(cachedItems), sut: sut)
        expectRetrieval(toCompleteWithResult: .success(cachedItems), sut: sut)
    }
    
    func test_retrieve_deliversErorrOnInvalidData() {
        let testURL = testStoreURL()
        let sut = makeSUT(storeURL: testURL)
        
        try! "invaliData".write(to: testURL, atomically: false, encoding: .utf8)
        
        expectRetrieval(toCompleteWithResult: .error(anyNSError()), sut: sut)
    }

    func test_retrieve_noSideEffectsOnRetrievalError() {
        let testURL = testStoreURL()
        let sut = makeSUT(storeURL: testURL)
        
        try! "invaliData".write(to: testURL, atomically: false, encoding: .utf8)
        
        expectRetrieval(toCompleteWithResult: .error(anyNSError()), sut: sut)
        expectRetrieval(toCompleteWithResult: .error(anyNSError()), sut: sut)
    }

    func test_insert_overridesPreviouslyInsertedItems() {
        let sut = makeSUT()

        let firstCacheItems = anyItems().map { $0.toLocal }
        expectInsertion(toCompleteWithResult: .completed, sut: sut, itemsToCache: firstCacheItems)
        
        let latestItems = [anyItem().toLocal]
        expectInsertion(toCompleteWithResult: .completed, sut: sut, itemsToCache: latestItems)
        
        expectRetrieval(toCompleteWithResult: .success(latestItems), sut: sut)
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidURL = URL(string: "invalid://store")
        let sut = makeSUT(storeURL: invalidURL)
        
        let itemsToCache = anyItems().map { $0.toLocal }
        expectInsertion(toCompleteWithResult: .error(anyNSError()), sut: sut, itemsToCache: itemsToCache)
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidURL = URL(string: "invalid://store")
        let sut = makeSUT(storeURL: invalidURL)
        
        let itemsToCache = anyItems().map { $0.toLocal }
        let noItems = [LocalPostItem]()
        _ = sut.savePosts(itemsToCache).subscribe()
        expectRetrieval(toCompleteWithResult: .success(noItems), sut: sut)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let noItems = PostsStore.RetrieveResult()
        
        expectDeletion(toCompleteWithResult: .completed, sut: sut)
        expectRetrieval(toCompleteWithResult: .success(noItems), sut: sut)
    }
    
    func test_delete_deletesPreviousInsertedCache() {
        let sut = makeSUT()
        let cachedItems = anyItems().map { $0.toLocal }
        let noItemsAfterDelete = PostsStore.RetrieveResult()
    
        expectInsertion(toCompleteWithResult: .completed, sut: sut, itemsToCache: cachedItems)
        expectDeletion(toCompleteWithResult: .completed, sut: sut)
        expectRetrieval(toCompleteWithResult: .success(noItemsAfterDelete), sut: sut)
    }

     // Tried to delete caches directory, but the system will throw error
    // only if trying to delete the directory second time, but not the first time
//    func test_delete_deliverErrorOnDeletionError() {
//        let noDeletePermissionsURL = cachesDirectory()
//        let sut = makeSUT(storeURL: noDeletePermissionsURL)
//
//        expectDeletion(toCompleteWithResult: .error(anyNSError()), sut: sut)
//    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        
        var operationsFinishOrder = [XCTestExpectation]()

        let op1 = expectation(description: "Wait for op1")
        _ = sut.savePosts(anyItems().map { $0.toLocal }).subscribe { _ in
            operationsFinishOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Wait for op2")
        _ = sut.deleteCachedPosts().subscribe { _ in
            operationsFinishOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Wait for op3")
        _ = sut.savePosts(anyItems().map { $0.toLocal }).subscribe { _ in
            operationsFinishOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(operationsFinishOrder, [op1, op2, op3], "Expected to run operations in order")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil) -> PostsStore {
        let sut = FileSystemPostsStore(storeURL: storeURL ?? testStoreURL())
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func expectRetrieval(toCompleteWithResult expectedResult: SingleEvent<FileSystemPostsStore.RetrieveResult>,
                                 sut: PostsStore,
                                 file: StaticString = #file,
                                 line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval")
        
        _ = sut.retrieve().subscribe { result in
            switch (result, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case (.error, .error):
                break
            default:
                XCTFail("expected \(expectedResult), got \(result)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expectInsertion(toCompleteWithResult expectedResult: CompletableEvent,
                                sut: PostsStore,
                                itemsToCache: [LocalPostItem],
                                file: StaticString = #file,
                                line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval")
        
        _ = sut.savePosts(itemsToCache).subscribe { result in
            switch (result, expectedResult) {
            case (.completed, .completed),
                 (.error, .error):
                break
            default:
                XCTFail("expected \(expectedResult), got \(result)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expectDeletion(toCompleteWithResult expectedResult: CompletableEvent,
                                sut: PostsStore,
                                file: StaticString = #file,
                                line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval")
        
        _ = sut.deleteCachedPosts().subscribe{ result in
            switch (result, expectedResult) {
            case (.completed, .completed),
                 (.error, .error):
                break
            default:
                XCTFail("expected \(expectedResult), got \(result)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func setEmptyCache() {
        deleteCached()
    }
    
    private func removeCachedItems() {
        deleteCached()
    }

    private func deleteCached() {
        try? FileManager.default.removeItem(at: testStoreURL())
    }

    private func testStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }

    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
