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
import RxTest

class PostsRepoTests: XCTestCase {
    
    let disposeBag = DisposeBag()
    var testScheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        
        testScheduler = TestScheduler(initialClock: 0)
    }
    
    func test_loading_notifiesWithCorrectStates() {
        let (sut, loader) = makeSUT()
        
        let loaderObs = testScheduler.createObserver(Loadable<[PostListItemModel]>.self)
        sut.postItemsLoader.subscribe(loaderObs).disposed(by: disposeBag)
        
        testScheduler.scheduleAt(1) {
            loader.loadResult = .error(anyNSError())
            sut.loadData()
        }
        
        testScheduler.scheduleAt(2) {
            loader.loadResult = .success(anyItems())
            sut.loadData()
        }
        
        testScheduler.start()
        
        typealias RecorderEvent = Recorded<Event<Loadable<[PostListItemModel]>>>
        let expectedLoadingEvents: [RecorderEvent] = [
            next(0, .pending),
            next(1, .loading),
            next(1, .failed(anyNSError())),
            next(2, .loading),
            next(2, .loaded(anyItems().map { PostListItemModel(postName: $0.title) })),
        ]

        XCTAssertEqual(loaderObs.events, expectedLoadingEvents)
    }
    
    // MARK: - Helpers

    private func makeSUT() -> (sut: PostsRepo, loader: PostsLoaderMock) {
        let loader = PostsLoaderMock()
        let sut = PostsRepo(postsLoader: loader)
        trackForMemoryLeaks(sut)
        
        return (sut, loader)
    }
    
    private class PostsLoaderMock: PostsLoader {
        var loadResult: SingleEvent<LoadResult> = .error(anyNSError())
        var loadRequestsCount = 0

        func load() -> Single<LoadResult> {
            loadRequestsCount += 1
            return .create { single in
                single(self.loadResult)
                return Disposables.create()
            }
        }
    }
    
}
