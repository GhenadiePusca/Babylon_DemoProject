//
//  PostsListViewModel.swift
//  PostsTests
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import XCTest
import Posts
import RxSwift
import RxCocoa
import RxTest

class PostsListViewModelTests: XCTestCase {

    let disposeBag = DisposeBag()
    var testScheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        
        testScheduler = TestScheduler(initialClock: 0)
    }

    func test_dataLoading_eventsCorrectlyTrigered() {
        let subject = PublishSubject<Loadable<[PostListItemModel]>>()
        let sut = makeSUT(dataLoader: subject.asObservable())
        
        let loadingFailedObserv = testScheduler.createObserver(Bool.self)
        let isLoadingObserv = testScheduler.createObserver(Bool.self)
        let itemsVMObserv = testScheduler.createObserver([PostListItemViewModel].self)
        sut.isLoading.drive(isLoadingObserv).disposed(by: disposeBag)
        sut.loadingFailed.drive(loadingFailedObserv).disposed(by: disposeBag)
        sut.postsModels.drive(itemsVMObserv).disposed(by: disposeBag)
        
        testScheduler.scheduleAt(1) {
            subject.onNext(.pending)
        }
        
        testScheduler.scheduleAt(2) {
            subject.onNext(.loading)
        }
        
        testScheduler.scheduleAt(3) {
            subject.onNext(.failed(anyNSError()))
        }
        
        testScheduler.scheduleAt(4) {
            subject.onNext(.loading)
        }
        
        testScheduler.scheduleAt(5) {
            subject.onNext(.loaded(self.loadedItems()))
        }
        
        testScheduler.start()
        
        let expectedLoadingEvents = [ next(0, false), next(1, false),
                                      next(2, true), next(3, false),
                                      next(4, true), next(5, false)
        ]
        
        let expectedFailureEvents = [next(0, false), next(1, false),
                                     next(2, false), next(3, true),
                                     next(4, false), next(5, false)
        ]
        
        let expectedDataEvents = [
            next(0, []),
            next(1, []),
            next(2, []),
            next(3, []),
            next(4, []),
            next(5, loadItemsViewModel(items: self.loadedItems()))
        ]
        
        XCTAssertEqual(loadingFailedObserv.events, expectedFailureEvents)
        XCTAssertEqual(isLoadingObserv.events, expectedLoadingEvents)
        XCTAssertEqual(itemsVMObserv.events, expectedDataEvents)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(dataLoader: Observable<Loadable<[PostListItemModel]>>,
                         file: StaticString = #file,
                         line: UInt = #line) -> PostsListViewModel {
        let sut = PostsListViewModel(dataLoader: dataLoader)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
        
    }
    private func loadedItems() -> [PostListItemModel] {
        let post1 = PostListItemModel(postName: "item 1")
        let post2 = PostListItemModel(postName: "item 2")
        
        return [post1, post2]
    }
    
    private func loadItemsViewModel(items: [PostListItemModel]) -> [PostListItemViewModel] {
        return items.map { PostListItemViewModel(model: $0) }
    }
}

extension PostListItemViewModel: Equatable {
    public static func == (lhs: PostListItemViewModel, rhs: PostListItemViewModel) -> Bool {
        return lhs.postName == rhs.postName
    }
}
