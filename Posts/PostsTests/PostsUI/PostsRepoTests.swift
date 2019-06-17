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
        let (sut, postsLoader, _, _) = makeSUT()
        
        let loaderObs = testScheduler.createObserver(Loadable<[PostListItemModel]>.self)
        sut.postItemsLoader.subscribe(loaderObs).disposed(by: disposeBag)
        
        testScheduler.scheduleAt(1) {
            postsLoader.loadResult = .error(anyNSError())
            sut.loadPosts()
        }
        
        testScheduler.scheduleAt(2) {
            postsLoader.loadResult = .success(anyItems())
            sut.loadPosts()
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

    private func makeSUT() -> (sut: PostsRepo,
                               postsLoader: LoaderMock<PostItem>,
                               commentsLoader: LoaderMock<CommentItem>,
                               usersLoader: LoaderMock<UserItem>) {
        let postsLoader = LoaderMock<PostItem>()
        let commentsLoader = LoaderMock<CommentItem>()
        let usersLoader = LoaderMock<UserItem>()
        let sut = PostsRepo(postsLoader: AnyItemsLoader(postsLoader),
                            commentsLoader: AnyItemsLoader(commentsLoader),
                            usersLoader: AnyItemsLoader(usersLoader))

        trackForMemoryLeaks(sut)
        
        return (sut, postsLoader, commentsLoader, usersLoader)
    }
    
    private class LoaderMock<ItemType>: ItemsLoader {
        typealias Item = ItemType
        
        var loadResult: SingleEvent<[Item]> = .error(anyNSError())
        var loadRequestsCount = 0

        func load() -> Single<[Item]> {
            loadRequestsCount += 1
            return .create { single in
                single(self.loadResult)
                return Disposables.create()
            }
        }
    }
}
