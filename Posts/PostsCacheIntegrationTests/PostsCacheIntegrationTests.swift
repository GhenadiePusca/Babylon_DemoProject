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
    
    func test_load_canLoadDataStoredByAnotherStoreInstance() {
        let saveSUT = makeSUT()
        let loadSUT = makeSUT()
        let itemsToCache = anyItems()
        
        let expectedSaveResut = CompletableEvent.completed
        let saveExp = expectation(description: "Wait for save")
        saveSUT.save(itemsToCache).subscribe { result in
            XCTAssertTrue(result.isSameEventAs(expectedSaveResut),
                          "Expected to save items, got \(result)")
            
            saveExp.fulfill()
        }.disposed(by: disposeBag)
        
        wait(for: [saveExp], timeout: 1.0)
        
        let cachedItems = itemsToCache
        let expectedLoadResut: SingleEvent<LocalPostsLoader.LoadResult> = .success(cachedItems)
        let loadExp = expectation(description: "Wait for load")
        loadSUT.load().subscribe { result in
            XCTAssertTrue(result.isSameAs(expectedLoadResut),
                          "Expected to load items, got \(result)")
            
            loadExp.fulfill()
        }.disposed(by: disposeBag)
        
        wait(for: [loadExp], timeout: 1.0)
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
