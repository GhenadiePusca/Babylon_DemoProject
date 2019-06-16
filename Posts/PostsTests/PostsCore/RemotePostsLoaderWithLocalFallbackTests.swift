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

protocol PostsPersister {
    func save(_ items: [PostItem]) -> Completable
}

final class RemotePostsLoaderWithLocalFallback: PostsLoader {
    
    let remoteLoader: PostsLoader
    let localPostsLoader: PostsLoader & PostsPersister
    
    init(remoteLoader: PostsLoader, localPostsLoader: PostsLoader & PostsPersister) {
        self.remoteLoader = remoteLoader
        self.localPostsLoader = localPostsLoader
    }
    
    func load() -> Single<LoadResult> {
        return .just([])
    }
}

class RemotePostsLoaderWithLocalFallbackTests: XCTestCase {
    
    func test_load_requestLoadOnRemoteLoader() {
    }
    
    func test_remoteLoad_cachesLoadedData() {
        
    }
    
    func test_remoteLoad_fallbacksToCacheIfRemoteLoadError() {}
    
    func test_load_throwsErrorIfCacheEmpty() {
        
    }
    
    private func makeSUT() -> (sut: PostsLoader,
                               remote: RemotePostsLoaderMock,
                               local: LocalPostsLoaderMock) {
            let remoteLoader = RemotePostsLoaderMock()
            let localLoader = LocalPostsLoaderMock()
            let sut = RemotePostsLoaderWithLocalFallback(remoteLoader: remoteLoader,
                                                         localPostsLoader: localLoader)
            trackForMemoryLeaks(sut)
            return (sut, remoteLoader, localLoader)
    }
    
    private class RemotePostsLoaderMock: PostsLoader {
        var loadRequestsCount = 0
        var loadResult: SingleEvent<LoadResult> = .error(anyNSError())

        func load() -> Single<LoadResult> {
            return .create { single in
                single(self.loadResult)
                return Disposables.create()
            }
        }
    }
    
    private class LocalPostsLoaderMock: PostsLoader & PostsPersister {
        var loadRequestsCount = 0
        var saveRequests = [[PostItem]]()
        
        let loadResult: SingleEvent<LoadResult> = .error(anyNSError())
        func load() -> Single<LoadResult> {
            loadRequestsCount += 1
            return .create { single in
                single(self.loadResult)
                return Disposables.create()
            }
        }
        
        func save(_ items: [PostItem]) -> Completable {
            saveRequests.append(items)
            return .create { completable in
                completable(.completed)
                return Disposables.create()
            }
        }
    }
}
