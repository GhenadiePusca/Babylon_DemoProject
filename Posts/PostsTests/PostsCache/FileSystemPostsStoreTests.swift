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

    func deleteCachedPosts() -> Completable {
        return .empty()
    }
    
    func savePosts(_ items: [LocalPostItem]) -> Completable {
        return encodeItems(items).flatMapCompletable(writeEncodedData)
    }
    
    func retrieve() -> Single<RetrieveResult> {
        return getCachedData().flatMap(decodeCachedData).ifEmpty(default: [])
    }
    
    // MARK: - Retrieval helpers

    private func getCachedData() -> Maybe<Data> {
        return .create(subscribe: { single in
            do {
                let data = try Data(contentsOf: self.storeURL)
                single(.success(data))
            } catch {
                single(.completed)
            }
            
            return Disposables.create()
        })
    }
    
    private func decodeCachedData(_ data: Data) -> Maybe<RetrieveResult> {
        return .create(subscribe: { single in
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(FailableDecodableArray<CodablePostItem>.self, from: data)
                single(.success(decoded.elements.map { $0.toLocal }))
            } catch {
                single(.error(error))
            }
            
            return Disposables.create()
        })
    }

    // MARK: - Save helpers

    private func encodeItems(_ items: [LocalPostItem]) -> Single<Data> {
        return .create(subscribe: { single in
            do {
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(items.map { CodablePostItem(localPostItem: $0) })
                single(.success(encoded))
            } catch {
                single(.error(error))
            }
            
            return Disposables.create()
        })
    }
    
    private func writeEncodedData(_ data: Data) -> Completable {
        return .create(subscribe: { completable in
            do {
                try data.write(to: self.storeURL)
                completable(.completed)
            } catch {
                completable(.error(error))
            }
            
            return Disposables.create()
        })
    }
}

class FileSystemPostsStoreTests: XCTestCase {
    
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

        expectRetrieve(toCompleteWithResult: .success(noItems), sut: sut)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let noItems = [LocalPostItem]()

        expectRetrieve(toCompleteWithResult: .success(noItems), sut: sut)
        expectRetrieve(toCompleteWithResult: .success(noItems), sut: sut)
    }
    
    func test_retrieve_deliversItemsOnNonEmptyCache() {
        let sut = makeSUT()
        let cachedItems = anyItems().map { $0.toLocal }
        let succesfulInsertion = CompletableEvent.completed
        
        expectInsertion(toCompleteWithResult: succesfulInsertion, sut: sut, itemsToCache: cachedItems)
        expectRetrieve(toCompleteWithResult: .success(cachedItems), sut: sut)
    }
    
    func test_retrieveTwice_deliversSameItemsOnNonEmptyCache() {
        let sut = makeSUT()
        let cachedItems = anyItems().map { $0.toLocal }
        let succesfulInsertion = CompletableEvent.completed
        
        expectInsertion(toCompleteWithResult: succesfulInsertion, sut: sut, itemsToCache: cachedItems)
        expectRetrieve(toCompleteWithResult: .success(cachedItems), sut: sut)
        expectRetrieve(toCompleteWithResult: .success(cachedItems), sut: sut)
    }
    
    func test_retrieve_deliversErorrOnInvalidData() {
        let testURL = testStoreURL()
        let sut = makeSUT(storeURL: testURL)
        
        try! "invaliData".write(to: testURL, atomically: false, encoding: .utf8)
        
        expectRetrieve(toCompleteWithResult: .error(anyNSError()), sut: sut)
    }
    // MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil) -> FileSystemPostsStore {
        let sut = FileSystemPostsStore(storeURL: storeURL ?? testStoreURL())
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
                                sut: FileSystemPostsStore,
                                itemsToCache: [LocalPostItem],
                                file: StaticString = #file,
                                line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval")
        
        _ = sut.savePosts(itemsToCache).subscribe { result in
            switch (result, expectedResult) {
            case (.completed, .completed):
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
}
