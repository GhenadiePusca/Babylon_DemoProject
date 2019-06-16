//
//  RemotePostsLoaderWithLocalFallbackIntegrationTests.swift
//  RemotePostsLoaderWithLocalFallbackIntegrationTests
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import XCTest
import Posts
import RxSwift

class RemotePostsLoaderWithLocalFallbackIntegrationTests: XCTestCase {
    
    let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        setEmptyCache()
    }
    
    override func tearDown() {
        super.tearDown()
        removeCachedItems()
    }

    func test_load_dataIsCachedOnSuccesfulLoad() {
        let (sut, localLoder) = makeSUT()

        let remoteLoadExp = expectation(description: "Wait for load")
        sut.load().subscribe { result in
            remoteLoadExp.fulfill()
        }.disposed(by: disposeBag)
        
        wait(for: [remoteLoadExp], timeout: 5.0)
        
        // Sleep for 1 second, wait for the data to be written to cache
        // After the load is complet the data si writen to cache as a side effect
        sleep(1)
        let cacheLoadExp = expectation(description: "Wait for load")
        localLoder.load().subscribe { result in
            switch result {
            case let .success(cachedItems):
                XCTAssertEqual(cachedItems, self.expectedFixedPostItems())
            default:
                break
            }
            
            cacheLoadExp.fulfill()
        }.disposed(by: disposeBag)
        
        wait(for: [cacheLoadExp], timeout: 1.0)
    }
    
    private func test_load_previousCachedDataIsReturnedOnNewLoadFail() {
        
    }
    
    private func makeSUT(remoteURL: URL? = nil) -> (sut: RemotePostsLoaderWithLocalFallback, local: LocalPostsLoader) {
        let testURL = remoteURL ?? testRemoteURL()
        let remoteLoader = RemotePostsLoader(url: testURL,
                                             client: URLSessionHTTPClient())
        let fileSystemStore = FileSystemPostsStore(storeURL: testStoreURL())
        let localLoder = LocalPostsLoader(store: fileSystemStore)
        
        let sut = RemotePostsLoaderWithLocalFallback(remoteLoader: remoteLoader,
                                                     localPostsLoader: localLoder)
        
        return (sut, localLoder)
    }
    
    private func expectedFixedPostItems() -> [PostItem] {
        let item1 = PostItem(id: 1,
                             userId: 1,
                             title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
                             body: "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto")
        
        let item2 = PostItem(id: 2,
                             userId: 2,
                             title: "qui est esse",
                             body: "est rerum tempore vitae\nsequi sint nihil reprehenderit dolor beatae ea dolores neque\nfugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis\nqui aperiam non debitis possimus qui neque nisi nulla")
        
        let item3 = PostItem(id: 3,
                             userId: 3,
                             title: "ea molestias quasi exercitationem repellat qui ipsa sit aut",
                             body: "et iusto sed quo iure\nvoluptatem occaecati omnis eligendi aut ad\nvoluptatem doloribus vel accusantium quis pariatur\nmolestiae porro eius odio et labore et velit aut")
        
        return [item1, item2, item3]
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
    
    private func testRemoteURL() -> URL {
        return URL(string: "https://poststestapi.free.beeceptor.com/")!
    }

    private func testStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }

}
