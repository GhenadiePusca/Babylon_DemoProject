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

class LocalPostsLoader {
    let store: PostsStore
    
    init(store: PostsStore) {
        self.store = store
    }
    
    func save(_ items: [PostItem]) -> Single<Void> {
        return store.deleteCachedPosts().flatMap { self.store.savePosts(items) }
    }
}

class PostsStore {
    enum Command: Equatable {
        case delete
        case insert([PostItem])
    }
    
    private(set) var receivedCommands = [Command]()
    
    var onDeletionResult: SingleEvent<Void> = .error(NSError(domain: "not provided", code: 1))
    
    func deleteCachedPosts() -> Single<Void> {
        receivedCommands.append(.delete)
        return .create(subscribe: { [weak self] single in
            let disposable = Disposables.create {}
            guard let self = self else { return disposable }

            single(self.onDeletionResult)
            return disposable
        })
    }
    
    func savePosts(_ items: [PostItem]) -> Single<Void> {
        receivedCommands.append(.insert(items))
        return .just(())
    }
}

class CachedPostsUseCaseTests: XCTestCase {
    
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
        
        store.onDeletionResult = .success(())
        _ = sut.save(items).subscribe { _ in }
        
        XCTAssertEqual(store.receivedCommands, [.delete, .insert(items)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: LocalPostsLoader, store: PostsStore) {
        let store = PostsStore()
        let sut = LocalPostsLoader(store: store)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalPostsLoader,
                        toCompleteWithResult expectedResult: SingleEvent<Void>,
                        withStub stub: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        stub()

        sut.save([anyItem()]).subscribe { result in
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

    private func anyItem() -> PostItem {
        return PostItem(id: 1, userId: 2, title: "any title", body: "any body")
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "err", code: 1)
    }
}
