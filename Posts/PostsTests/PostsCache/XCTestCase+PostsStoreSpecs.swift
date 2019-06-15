//
//  XCTestCase+PostsStoreSpecs.swift
//  PostsTests
//
//  Created by Pusca Ghenadie on 15/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import XCTest
import Posts
import RxSwift

extension PostsStoreSpecs where Self: XCTestCase {
    
    func expectRetrieval(toCompleteWithResult expectedResult: SingleEvent<PostsStore.RetrieveResult>,
                         sut: PostsStore,
                         file: StaticString = #file,
                         line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval")
        
        var capturedResult: SingleEvent<PostsStore.RetrieveResult>?
        let disposable = sut.retrieve().observeOn(MainScheduler.instance).subscribe { [weak exp] result in
            capturedResult = result
            exp?.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        disposable.dispose()
        
        switch (capturedResult, expectedResult) {
        case let (.success(receivedItems)?, .success(expectedItems)):
            XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
        case (.error?, .error):
            break
        default:
            XCTFail("expected \(expectedResult), got \(String(describing: capturedResult))", file: file, line: line)
        }
    }
    
    func expectInsertion(toCompleteWithResult expectedResult: CompletableEvent,
                         sut: PostsStore,
                         itemsToCache: [LocalPostItem],
                         file: StaticString = #file,
                         line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval")
        
        var capturedResult: CompletableEvent?
        let disposable = sut.savePosts(itemsToCache).observeOn(MainScheduler.instance).subscribe { [weak exp] result in
            capturedResult = result
            exp?.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        disposable.dispose()
        
        switch (capturedResult, expectedResult) {
        case (.completed?, .completed),
             (.error?, .error):
            break
        default:
            XCTFail("expected \(expectedResult), got \(capturedResult)", file: file, line: line)
        }
    }
    
    func expectDeletion(toCompleteWithResult expectedResult: CompletableEvent,
                        sut: PostsStore,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval")
        
        var capturedResult: CompletableEvent?
        let disposable = sut.deleteCachedPosts().observeOn(MainScheduler.instance).subscribe { [weak exp] result in
            capturedResult = result
            exp?.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        disposable.dispose()
        
        switch (capturedResult, expectedResult) {
        case (.completed?, .completed),
             (.error?, .error):
            break
        default:
            XCTFail("expected \(expectedResult), got \(capturedResult)", file: file, line: line)
        }
    }
    
}
