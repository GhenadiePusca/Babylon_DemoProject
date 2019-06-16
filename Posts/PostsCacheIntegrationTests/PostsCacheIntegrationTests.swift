//
//  PostsCacheIntegrationTests.swift
//  PostsCacheIntegrationTests
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import XCTest
import Posts
import RxSwift

class PostsCacheIntegrationTests: XCTestCase {
    
    
    let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        
        setEmptyCache()
    }
    
    override func tearDown() {
        super.tearDown()
        
        removeCachedItems()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        let noItemsResult: SingleEvent<LocalPostsLoader.LoadResult> = .success([])
    
        let exp = expectation(description: "Wait for load")
        sut.load().subscribe { result in
            XCTAssertTrue(result.isSameAs(noItemsResult),
                          "Expected to load no items, got \(result)")
            exp.fulfill()
        }.disposed(by: disposeBag)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> LocalPostsLoader {
        let testURL = testStoreURL()
        let fileSystemStore = FileSystemPostsStore(storeURL: testURL)
        let sut = LocalPostsLoader(store: fileSystemStore)
        trackForMemoryLeaks(fileSystemStore)
        trackForMemoryLeaks(sut)
        
        return sut
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
