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
    
        expectLoad(toCompleteWithResult: noItemsResult, sut: sut)
    }
    
    func test_load_canLoadDataStoredByAnotherStoreInstance() {
        let saveSUT = makeSUT()
        let loadSUT = makeSUT()
        let itemsToCache = anyItems()
        
        expectSave(toCompleteWithResult: .completed,
                   sut: saveSUT,
                   itemsToSave: itemsToCache)

        let cachedItems = itemsToCache
        expectLoad(toCompleteWithResult: .success(cachedItems), sut: loadSUT)
    }
    
    func test_save_overridesItemsSaveByAnotherStoreInstance() {
        let firstSaveSUT = makeSUT()
        let secondSaveSUT = makeSUT()
        let loadSUT = makeSUT()
        let firstSavedItems = anyItems()
        let latestSavedItems = [anyItem()]
        
        expectSave(toCompleteWithResult: .completed,
                   sut: firstSaveSUT,
                   itemsToSave: firstSavedItems)

        expectSave(toCompleteWithResult: .completed,
                   sut: secondSaveSUT,
                   itemsToSave: latestSavedItems)

        expectLoad(toCompleteWithResult: .success(latestSavedItems),
                   sut: loadSUT)
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
    
    private func expectLoad(toCompleteWithResult expectedResult: SingleEvent<LocalPostsLoader.LoadResult>,
                            sut: LocalPostsLoader,
                            file: StaticString = #file,
                            line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        sut.load().subscribe { result in
            XCTAssertTrue(result.isSameAs(expectedResult),
                          "expected \(expectedResult), got \(result)", file: file, line: line)
            exp.fulfill()
        }.disposed(by: disposeBag)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expectSave(toCompleteWithResult expectedResult: CompletableEvent,
                            sut: LocalPostsLoader,
                            itemsToSave: [PostItem],
                            file: StaticString = #file,
                            line: UInt = #line) {
        let exp = expectation(description: "Wait for save")
        sut.save(itemsToSave).subscribe { result in
            XCTAssertTrue(result.isSameEventAs(expectedResult),
                          "Expected to save items, got \(result)")
            
            exp.fulfill()
        }.disposed(by: disposeBag)
        
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
