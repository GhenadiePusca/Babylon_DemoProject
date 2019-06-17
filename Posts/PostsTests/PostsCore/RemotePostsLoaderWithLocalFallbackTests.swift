//
//  RemotePostsLoaderWithLocalFallbackTests.swift
//  PostsTests
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation
import XCTest
import Posts
import RxSwift

class RemotePostsLoaderWithLocalFallbackTests: XCTestCase {
    let disposeBag = DisposeBag()

    func test_load_requestLoadOnRemoteLoader() {
        let (sut, remote, _) = makeSUT()
        
        sut.load().subscribe().disposed(by: disposeBag)
        
        XCTAssertEqual(remote.loadRequestsCount, 1,
                       "Expected to request a load once, instead called it \(remote.loadRequestsCount)")
    }
    
    func test_remoteLoad_cachesLoadedDataOnSuccess() {
        let (sut, remote, local) = makeSUT()
        
        let loadedItems = anyItems()
        remote.loadResult = .success(loadedItems)

        sut.load().subscribe().disposed(by: disposeBag)
        
        XCTAssertEqual(local.saveRequests,
                       [loadedItems],
                       "Expected to save loaded items")
    }
    
    func test_remoteLoad_fallbacksToCacheIfRemoteLoadError() {
        let (sut, remote, local) = makeSUT()
        
        remote.loadResult = .error(anyNSError())
        
        sut.load().subscribe().disposed(by: disposeBag)
        
        XCTAssertEqual(local.loadRequestsCount,
                       1,
                       "Expected to request a load once, instead called it \(remote.loadRequestsCount)")
    }
    
    func test_load_throwsErrorAftterCacheFallbackAndCacheEmpty() {
        let (sut, remote, local) = makeSUT()
        
        remote.loadResult = .error(anyNSError())
        local.loadResult = .success([])
        
        let exp = expectation(description: "Wait for load")
        sut.load().subscribe { result in
            XCTAssertFalse(result.isSuccess, "Expected load to fail")
            exp.fulfill()
        }.disposed(by: disposeBag)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(file: StaticString = #file,
                         line: UInt = #line) -> (sut: AnyItemsLoader<PostItem>,
                               remote: RemotePostsLoaderMock,
                               local: LocalPostsLoaderMock) {
            let remoteLoader = RemotePostsLoaderMock()
            let localLoader = LocalPostsLoaderMock()
            let sut = RemotePostsLoaderWithLocalFallback(remoteLoader: AnyItemsLoader(remoteLoader),
                                                         localPostsLoader: AnyItemsStorageManager(localLoader))
            trackForMemoryLeaks(sut, file: file, line: line)
            return (AnyItemsLoader(sut), remoteLoader, localLoader)
    }
    
    private class RemotePostsLoaderMock: ItemsLoader {
        typealias Item = PostItem
        
        var loadRequestsCount = 0
        var loadResult: SingleEvent<[Item]> = .error(anyNSError())

        func load() -> Single<[Item]> {
            loadRequestsCount += 1
            return .create { single in
                single(self.loadResult)
                return Disposables.create()
            }
        }
    }
    
    private class LocalPostsLoaderMock: ItemsLoader & ItemsStorageManager {
        typealias Item = PostItem
        
        var loadRequestsCount = 0
        var saveRequests = [[PostItem]]()
        var loadResult: SingleEvent<[Item]> = .error(anyNSError())

        func load() -> Single<[Item]> {
            loadRequestsCount += 1
            return .create { single in
                single(self.loadResult)
                return Disposables.create()
            }
        }
        
        func save(_ items: [Item]) -> Completable {
            saveRequests.append(items)
            return .create { completable in
                completable(.completed)
                return Disposables.create()
            }
        }

        func validatePersistedItems() {}
    }
}
