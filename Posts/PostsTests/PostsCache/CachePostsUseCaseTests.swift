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

class CachePostsUseCaseTests: XCTestCase {
    
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
    
    func test_save_doesNotInsertInCacheOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [anyItem(), anyItem()]
        let deletionError = anyNSError()
        
        store.onDeletionResult = .error(deletionError)
        _ = sut.save(items).subscribe { _ in }
        
        XCTAssertEqual(store.receivedCommands, [.delete])
    }
    
    func test_save_onSuccessDeletionSavesItems() {
        let (sut, store) = makeSUT()
        let items = [anyItem(), anyItem()]
        let localItems = items.map { LocalPostItem(id: $0.id, userId: $0.userId, title: $0.title, body: $0.body) }
        
        store.onDeletionResult = .success(())
        _ = sut.save(items).subscribe { _ in }
        
        XCTAssertEqual(store.receivedCommands, [.delete, .insert(localItems)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut,
               toCompleteWithResult: .error(deletionError),
               withStub: {
                store.onDeletionResult = .error(deletionError)
        })
    }
    
    func test_save_failsOnSaveError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut,
               toCompleteWithResult: .error(insertionError),
               withStub: {
                store.onDeletionResult = .success(())
                store.onSaveResult = .error(insertionError)
        })
    }
    
    func test_save_succedsOnSuccesfulSave() {
        let (sut, store) = makeSUT()
        
        expect(sut,
               toCompleteWithResult: .success(()),
               withStub: {
                store.onDeletionResult = .success(())
                store.onSaveResult = .success(())
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: LocalPostsLoader, store: PostsStoreSpy) {
        let store = PostsStoreSpy()
        let sut = LocalPostsLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalPostsLoader,
                        toCompleteWithResult expectedResult: SingleEvent<Void>,
                        withStub stub: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        stub()

        _ = sut.save([anyItem()]).subscribe { result in
            switch (result, expectedResult) {
            case (.success, .success):
                break
            case let (.error(receivedError), .error(expectedError)):
                XCTAssertEqual(receivedError as NSError?, expectedError as NSError?)
            default:
                XCTFail("expected \(expectedResult), got \(result)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class PostsStoreSpy: PostsStore {
        
        // MARK: - Commands
        enum Command: Equatable {
            case delete
            case insert([LocalPostItem])
        }
        
        private(set) var receivedCommands = [Command]()
        
        // MARK: - Private
        private static let notSetError = NSError(domain: "not provided", code: 1)
        
        // MARK: - Stub properties

        var onDeletionResult: SingleEvent<Void> = .error(PostsStoreSpy.notSetError)
        var onSaveResult: SingleEvent<Void> = .error(PostsStoreSpy.notSetError)
        
        // MAARK: - PostsStore protocol conformance
        func deleteCachedPosts() -> Single<Void> {
            receivedCommands.append(.delete)
            return .create(subscribe: { single in
                single(self.onDeletionResult)
                return Disposables.create {}
            })
        }
        
        func savePosts(_ items: [LocalPostItem]) -> Single<Void> {
            receivedCommands.append(.insert(items))
            return .create(subscribe: { single in
                single(self.onSaveResult)
                return Disposables.create {}
            })
        }
    }
}
