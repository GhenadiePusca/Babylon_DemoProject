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
    
    private struct CodablePostItem: Codable {
        let id: Int
        let userId: Int
        let title: String
        let body: String
        
        public init(localPostItem: LocalPostItem) {
            self.id = localPostItem.id
            self.title = localPostItem.title
            self.userId = localPostItem.userId
            self.body = localPostItem.body
        }
        
        var toLocal: LocalPostItem {
            return LocalPostItem(id: id,
                                 userId: userId,
                                 title: title,
                                 body: body)
        }
    }

    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }

    func deleteCachedPosts() -> Single<Void> {
        return .just(())
    }
    
    func savePosts(_ items: [LocalPostItem]) -> Single<Void> {
        return .create(subscribe: { single in
            let encoder = JSONEncoder()
            let encoded = try! encoder.encode(items.map { CodablePostItem(localPostItem: $0) })
            try! encoded.write(to: self.storeURL)
            single(.success(()))
            return Disposables.create()
        })
    }
    
    func retrieve() -> Single<RetrieveResult> {
        
        return .create(subscribe: { single in
            if let data = try? Data(contentsOf: self.storeURL) {
                let decoder = JSONDecoder()
                let decoded = try! decoder.decode(FailableDecodableArray<CodablePostItem>.self, from: data)
                single(.success(decoded.elements.map { $0.toLocal }))
            } else {
                single(.success([]))
            }
            return Disposables.create()
        })
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
