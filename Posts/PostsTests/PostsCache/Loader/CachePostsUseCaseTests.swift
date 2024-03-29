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
    
    func test_init_cacheRemainsIntactOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedCommands, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [anyItem(), anyItem()]
        
        let disp = sut.save(items).subscribe()
        
        XCTAssertEqual(store.receivedCommands, [.delete])
        disp.dispose()
    }
    
    func test_save_doesNotInsertInCacheOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [anyItem(), anyItem()]
        let deletionError = anyNSError()
        
        store.onDeletionResult = .error(deletionError)
        let disp = sut.save(items).subscribe()
        
        XCTAssertEqual(store.receivedCommands, [.delete])
        disp.dispose()
    }
    
    func test_save_onSuccessDeletionSavesItems() {
        let (sut, store) = makeSUT()
        let items = [anyItem(), anyItem()]
        let localItems = items.map { $0.toLocal }
        
        store.onDeletionResult = .completed
        let disp = sut.save(items).subscribe()
        
        XCTAssertEqual(store.receivedCommands, [.delete, .insert(localItems)])
        disp.dispose()
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
        let succesfulDeletion = CompletableEvent.completed
        
        expect(sut,
               toCompleteWithResult: .error(insertionError),
               withStub: {
                store.onDeletionResult = succesfulDeletion
                store.onSaveResult = .error(insertionError)
        })
    }
    
    func test_save_succedsOnSuccesfulSave() {
        let (sut, store) = makeSUT()
        let succesfulSave = CompletableEvent.completed
        let succesfulDeletion = CompletableEvent.completed

        expect(sut,
               toCompleteWithResult: succesfulSave,
               withStub: {
                store.onDeletionResult = succesfulDeletion
                store.onSaveResult = succesfulSave
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
                        toCompleteWithResult expectedResult: CompletableEvent,
                        withStub stub: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        stub()

        let disp = sut.save([anyItem()]).subscribe { result in
            XCTAssertTrue(result.isSameStateAndEqualNSErrorsAs(expectedResult),
                          "expected \(expectedResult), got \(result)", file: file, line: line)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        disp.dispose()
    }
}
