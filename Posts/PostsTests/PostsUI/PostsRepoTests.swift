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
    
    func test_postDetail_correctModelLoadedOnRequest() {
        let (sut, postsLoader, _, _) = makeSUT()
        
        let testPostItem = PostItem(id: 1,
                                    userId: 2,
                                    title: "any title",
                                    body: "any body")
        postsLoader.loadResult = .success([testPostItem])
        
        sut.loadPosts()
        
        let exp = expectation(description: "wait for loading")
        sut.postItemsLoader.subscribe { _ in
            exp.fulfill()
        }.disposed(by: disposeBag)
        wait(for: [exp], timeout: 1.0)
        
        let appDetail = sut.postDetailModel(postId: testPostItem.id)
        XCTAssertEqual(appDetail.title, testPostItem.title)
        XCTAssertEqual(appDetail.body, testPostItem.body)
    }
    
    func test_postDetail_authorAndCommentsAreCorrectlySet() {
        let (sut, postsLoader, commentsLoader, usersLoader) = makeSUT()
        
        let testPostItem = PostItem(id: 1,
                                    userId: 2,
                                    title: "any title",
                                    body: "any body")
        
        let testUser = user(userId: testPostItem.userId)
        postsLoader.loadResult = .success([testPostItem])
        usersLoader.loadResult = .success([testUser])
        commentsLoader.loadResult = .success([comment(postId: testPostItem.id)])
        
        sut.loadPosts()
        let exp = expectation(description: "wait for loading")
        sut.postItemsLoader.subscribe { _ in
            exp.fulfill()
        }.disposed(by: disposeBag)
    
        wait(for: [exp], timeout: 1.0)
        
        let appDetail = sut.postDetailModel(postId: testPostItem.id)
        
        let authorExp = expectation(description: "get author")
        appDetail.authorName.subscribe(onNext: { nameLoadable in
            XCTAssertEqual(nameLoadable, .loaded(testUser.name))
            authorExp.fulfill()
        }).disposed(by: disposeBag)

        wait(for: [authorExp], timeout: 1.0)
        
        let commentsExp = expectation(description: "get author")
        appDetail.numberOfComments.subscribe(onNext: { nameLoadable in
            XCTAssertEqual(nameLoadable, .loaded(1))
            commentsExp.fulfill()
        }).disposed(by: disposeBag)
        
        wait(for: [commentsExp], timeout: 1.0)
    }
    
    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file,
                         line: UInt = #line) -> (sut: PostsRepo,
                               postsLoader: LoaderMock<PostItem>,
                               commentsLoader: LoaderMock<CommentItem>,
                               usersLoader: LoaderMock<UserItem>) {
        let postsLoader = LoaderMock<PostItem>()
        let commentsLoader = LoaderMock<CommentItem>()
        let usersLoader = LoaderMock<UserItem>()
        let sut = PostsRepo(postsLoader: AnyItemsLoader(postsLoader),
                            commentsLoader: AnyItemsLoader(commentsLoader),
                            usersLoader: AnyItemsLoader(usersLoader))

        trackForMemoryLeaks(sut, file: file, line: line)
        
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
    
    private func comment(postId: Int) -> CommentItem {
        return CommentItem(id: 1,
                           postId: postId,
                           authorName: "",
                           authorEmail: "",
                           body: "")
    }

    private func user(userId: Int) -> UserItem {
        return UserItem(id: userId,
                        name: "A name",
                        userName: "",
                        emailAddress: "",
                        address: Address(street: "",
                                         suite: "",
                                         city: "",
                                         zipcode: "",
                                         coordinates: Coordinates(latitude: "",
                                                                  longitute: "")),
                        phoneNumber: "",
                        websiteURL: "",
                        company: Company(name: "",
                                         catchPhrase: "",
                                         bussinesScope: ""))
    }
}
