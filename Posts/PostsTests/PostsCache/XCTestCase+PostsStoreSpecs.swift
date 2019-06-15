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
        
        let disp = sut.retrieve().subscribe { result in
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
        
        disp.dispose()
    }
    
    func expectInsertion(toCompleteWithResult expectedResult: CompletableEvent,
                         sut: PostsStore,
                         itemsToCache: [LocalPostItem],
                         file: StaticString = #file,
                         line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval")
        
        let disp = sut.savePosts(itemsToCache).subscribe { result in
            XCTAssertTrue(result.isSameEventAs(expectedResult), "expected \(expectedResult), got \(result)", file: file, line: line)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        disp.dispose()
    }
    
    func expectDeletion(toCompleteWithResult expectedResult: CompletableEvent,
                        sut: PostsStore,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval")
        
        let disp = sut.deleteCachedPosts().subscribe { result in
            XCTAssertTrue(result.isSameEventAs(expectedResult), "expected \(expectedResult), got \(result)", file: file, line: line)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        disp.dispose()
    }
    
}
