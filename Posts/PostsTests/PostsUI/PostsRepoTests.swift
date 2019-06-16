//
//  PostsRepoTests.swift
//  PostsTests
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import XCTest
import Posts
import RxSwift

class PostsRepo {
    let postsLoader: PostsLoader
    private let disposeBag = DisposeBag()

    init(postsLoader: PostsLoader) {
        self.postsLoader = postsLoader
        
        loadData()
    }
    
    private func loadData() {
        postsLoader.load().subscribe { _ in
        }.disposed(by: disposeBag)
    }
}

class PostsRepoTests: XCTestCase {
    
    func test_init_triggersDataLoading() {
        let (_, loader) = makeSUT()

        XCTAssertEqual(loader.loadRequestsCount, 1)
    }
    
    // MARK: - Helpers

    private func makeSUT() -> (sut: PostsRepo, loader: PostsLoaderMock) {
        let loader = PostsLoaderMock()
        let sut = PostsRepo(postsLoader: loader)
        trackForMemoryLeaks(sut)
        
        return (sut, loader)
    }
    
    private class PostsLoaderMock: PostsLoader {
        var loadRequestsCount = 0
        func load() -> Single<LoadResult> {
            loadRequestsCount += 1
            return .just([])
        }
    }
    
}
