//
//  GenericFileSystemPostsStoreTests.swift
//  PostsTests
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import XCTest

import Posts
import RxSwift

class GenericFileSystemPostsStoreTests: XCTestCase, PostsStoreSpecs {

    let disposeBag = DisposeBag()
    
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
        expectRetrieval(toCompleteWithResult: .success([]), sut: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        expectRetrieval(toCompleteWithResult: .success([]), sut: sut)
        expectRetrieval(toCompleteWithResult: .success([]), sut: sut)
    }
    
    func test_retrieve_deliversItemsOnNonEmptyCache() {
        let sut = makeSUT()
        let cachedItems = localItems()
        let succesfulInsertion = CompletableEvent.completed
        
        expectInsertion(toCompleteWithResult: succesfulInsertion,
                        sut: sut,
                        itemsToCache: cachedItems)
        expectRetrieval(toCompleteWithResult: .success(cachedItems), sut: sut)
    }
    
    func test_retrieve_noSideEffectsOnSuccesfulRetrieve() {
        let sut = makeSUT()
        let cachedItems = localItems()
        let succesfulInsertion = CompletableEvent.completed
        
        expectInsertion(toCompleteWithResult: succesfulInsertion,
                        sut: sut,
                        itemsToCache: cachedItems)
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
        
        let firstCacheItems = localItems()
        expectInsertion(toCompleteWithResult: .completed,
                        sut: sut,
                        itemsToCache: firstCacheItems)
        
        let latestItems = [anyLocalItem()]
        expectInsertion(toCompleteWithResult: .completed,
                        sut: sut,
                        itemsToCache: latestItems)
        
        expectRetrieval(toCompleteWithResult: .success(latestItems), sut: sut)
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidURL = URL(string: "invalid://store")
        let sut = makeSUT(storeURL: invalidURL)
        
        let itemsToCache = localItems()
        expectInsertion(toCompleteWithResult: .error(anyNSError()),
                        sut: sut,
                        itemsToCache: itemsToCache)
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidURL = URL(string: "invalid://store")
        let sut = makeSUT(storeURL: invalidURL)
        
        let itemsToCache = localItems()
        sut.savePosts(itemsToCache).subscribe().disposed(by: disposeBag)
        expectRetrieval(toCompleteWithResult: .success([]), sut: sut)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expectDeletion(toCompleteWithResult: .completed, sut: sut)
        expectRetrieval(toCompleteWithResult: .success([]), sut: sut)
    }
    
    func test_delete_deletesPreviousInsertedCache() {
        let sut = makeSUT()
        let cachedItems = localItems()
        
        expectInsertion(toCompleteWithResult: .completed, sut: sut, itemsToCache: cachedItems)
        expectDeletion(toCompleteWithResult: .completed, sut: sut)
        expectRetrieval(toCompleteWithResult: .success([]), sut: sut)
    }
    
    // Tried to delete caches directory, but the system will throw error
    // only if trying to delete the directory second time, but not the first time
    //    func test_delete_deliverErrorOnDeletionError() {
    //        let noDeletePermissionsURL = cachesDirectory()
    //        let sut = makeSUT(storeURL: noDeletePermissionsURL)
    //
    //        expectDeletion(toCompleteWithResult: .error(anyNSError()), sut: sut)
    //        expectDeletion(toCompleteWithResult: .error(anyNSError()), sut: sut)
    //    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        
        var operationsFinishOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Wait for op1")
        sut.savePosts(localItems()).subscribe { _ in
            operationsFinishOrder.append(op1)
            op1.fulfill()
            }.disposed(by: disposeBag)
        
        let op2 = expectation(description: "Wait for op2")
        sut.deleteItems().subscribe { _ in
            operationsFinishOrder.append(op2)
            op2.fulfill()
            }.disposed(by: disposeBag)
        
        let op3 = expectation(description: "Wait for op3")
        sut.savePosts(localItems()).subscribe { _ in
            operationsFinishOrder.append(op3)
            op3.fulfill()
            }.disposed(by: disposeBag)
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(operationsFinishOrder, [op1, op2, op3], "Expected to run operations in order")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil,
                         file: StaticString = #file,
                         line: UInt = #line) -> AnyItemsStore<LocalPostItem> {
        let sut = FileSystemItemsStore<LocalPostItem, CodablePostItem>(storeURL: storeURL ?? testStoreURL(),
                                                               savedToEncodedMapper: Mapper.localPostsEncodable,
                                                               econdedToSavedMapper: Mapper.encodableToLocal)
        trackForMemoryLeaks(sut, file: file, line: line)
        return AnyItemsStore(sut)
    }
    
    private func localItems() -> [LocalPostItem] {
        return anyItems().map { $0.toLocal }
    }
    
    private func anyLocalItem() -> LocalPostItem {
        return anyItem().toLocal
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

