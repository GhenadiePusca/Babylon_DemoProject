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

class FileSystemPostsStore: PostsStore {
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }

    func deleteCachedPosts() -> Single<Void> {
        return .just(())
    }
    
    func savePosts(_ items: [LocalPostItem]) -> Single<Void> {
        return .just(())
    }
    
    func retrieve() -> Single<RetrieveResult> {
        return .just([])
    }
}

class FileSystemPostsStoreTests: XCTestCase {
    
    func test_retrieve_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        let noItems = [LocalPostItem]()
    
        expectRetrieve(toCompleteWithResult: .success(noItems), sut: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let noItems = [LocalPostItem]()
        
        expectRetrieve(toCompleteWithResult: .success(noItems), sut: sut)
        expectRetrieve(toCompleteWithResult: .success(noItems), sut: sut)
    }
    
    func test_retrieveAfterInsertingToEmpty_deliversInsertedItems() {
        let sut = makeSUT()
        let cachedItems = anyItems().map { $0.toLocal }
        let successResult: Void = ()

        expectInsertion(toCompleteWithResult: .success(successResult), sut: sut, itemsToCache: cachedItems)
        expectRetrieve(toCompleteWithResult: .success(cachedItems), sut: sut)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> FileSystemPostsStore {
        let sut = FileSystemPostsStore(storeURL: testStoreURL())
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func expectRetrieve(toCompleteWithResult expectedResult: SingleEvent<FileSystemPostsStore.RetrieveResult>,
                                sut: FileSystemPostsStore,
                                file: StaticString = #file,
                                line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval")
        
        _ = sut.retrieve().subscribe { result in
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
    
    private func expectInsertion(toCompleteWithResult expectedResult: SingleEvent<Void>,
                                sut: FileSystemPostsStore,
                                itemsToCache: [LocalPostItem],
                                file: StaticString = #file,
                                line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval")
        
        _ = sut.savePosts(itemsToCache).subscribe { result in
            switch (result, expectedResult) {
            case (.success, .success):
                break
            case let (.error(receivedError), .error(expectedError)):
                XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, file: file, line: line)
            default:
                XCTFail("expected \(expectedResult), got \(result)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func testStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
