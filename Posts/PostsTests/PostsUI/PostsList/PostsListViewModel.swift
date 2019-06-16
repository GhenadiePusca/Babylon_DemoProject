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

enum Loadable<Value> {
    case pending
    case loading
    case loaded(Value)
    case failed(Error)
}

struct PostListItemModel {
    let postName: String
}

struct PostListItemViewModel {
    var postName: String {
        return model.postName
    }
    
    private let model: PostListItemModel
    
    init(model: PostListItemModel) {
        self.model = model
    }
}

class PostsListViewModel {
    let postsModels: Driver<[PostListItemViewModel]>
    let isLoading: Driver<Bool>
    let loadingFailed: Driver<Bool>
    
    private let models = BehaviorRelay<[PostListItemViewModel]>(value: [])
    private let loading = BehaviorRelay<Bool>(value: false)
    private let loadingFail = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()

    init(dataLoader: Observable<Loadable<[PostListItemModel]>>) {
        postsModels = models.asDriver()
        isLoading = loading.asDriver()
        loadingFailed = loadingFail.asDriver()

        bindToDataLoader(loader: dataLoader)
    }
    
    private func bindToDataLoader(loader: Observable<Loadable<[PostListItemModel]>>) {
        loader.subscribe(onNext: handleState).disposed(by: disposeBag)
    }
    
    private func handleState(_ state: Loadable<[PostListItemModel]>) {
        switch state {
        case .loading:
            loading.accept(true)
            loadingFail.accept(false)
        case .failed:
            loading.accept(false)
            loadingFail.accept(true)
        case .loaded(let items):
            loading.accept(false)
            loadingFail.accept(false)
            handleData(data: items)
        default:
            loading.accept(false)
            loadingFail.accept(false)
            break
        }
    }
    
    private func handleData(data: [PostListItemModel]) {
        models.accept(data.map { PostListItemViewModel(model: $0) })
    }
}

class PostsListViewModelTests: XCTestCase {

    let disposeBag = DisposeBag()
    var testScheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        
        testScheduler = TestScheduler(initialClock: 0)
    }

    func test_init_hasNoPostsToShow() {
        let sut = makeSUT(dataLoader: .just(.pending))

        let exp = expectation(description: "Wait for subs")
        sut.postsModels.drive(onNext: { items in
            XCTAssertTrue(items.isEmpty, "Default state should be empty")
            exp.fulfill()
        }).disposed(by: disposeBag)
        
        wait(for: [exp], timeout: 1.0)
    }

    func test_dataLoading_isLoadingIsCorrectlyTriggered() {
        let subject = PublishSubject<Loadable<[PostListItemModel]>>()
        let sut = makeSUT(dataLoader: subject.asObservable())

        let isLoadingObserv = testScheduler.createObserver(Bool.self)
        sut.isLoading.drive(isLoadingObserv).disposed(by: disposeBag)
        
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
        
        let expectedEvents = [
            next(0, false),
            next(1, false),
            next(2, true),
            next(3, false),
            next(4, true),
            next(5, false)
        ]

        XCTAssertEqual(isLoadingObserv.events, expectedEvents)
    }
    
    func test_dataLoading_showErrorIsCorrectlyTriggered() {
        let subject = PublishSubject<Loadable<[PostListItemModel]>>()
        let sut = makeSUT(dataLoader: subject.asObservable())
        
        let loadingFailedObserv = testScheduler.createObserver(Bool.self)
        sut.loadingFailed.drive(loadingFailedObserv).disposed(by: disposeBag)
        
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
        
        let expectedEvents = [
            next(0, false),
            next(1, false),
            next(2, false),
            next(3, true),
            next(4, false),
            next(5, false)
        ]
        
        XCTAssertEqual(loadingFailedObserv.events, expectedEvents)
    }
    
    func test_dataLoading_showDataTriggeredOnSuccessWithData() {
        let items = loadedItems()
        let sut = makeSUT(dataLoader: .just(.loaded(items)))
        
        let exp = expectation(description: "Wait for subs")
        sut.postsModels.drive(onNext: { itemViewModels in
            XCTAssertEqual(itemViewModels.count, items.count)
            exp.fulfill()
        }).disposed(by: disposeBag)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_triggersEventsInCorrectOrder() {
        let subject = PublishSubject<Loadable<[PostListItemModel]>>()
        let sut = makeSUT(dataLoader: subject.asObservable())
        
        let isLoadingObserv = testScheduler.createObserver(Bool.self)
        let isErrorObserv = testScheduler.createObserver(Bool.self)
        let itemModelsObserv = testScheduler.createObserver([PostListItemViewModel].self)
        sut.isLoading.drive(isLoadingObserv).disposed(by: disposeBag)
        sut.loadingFailed.drive(isErrorObserv).disposed(by: disposeBag)
        sut.postsModels.drive(itemModelsObserv).disposed(by: disposeBag)
        
//        sut.postsModels.drive(onNext: { items in
//            XCTAssertTrue(items.isEmpty, "Default state should be empty")
//            exp.fulfill()
//        }).disposed(by: disposeBag)
//
//        sut.loadingFailed.drive(onNext: { loading in
//            XCTAssertTrue(loading, "Expected to load data")
//            exp.fulfill()
//        }).disposed(by: disposeBag)
//
//        sut.isLoading.drive(onNext: { loading in
//            XCTAssertTrue(loading, "Expected to load data")
//            exp.fulfill()
//        }).disposed(by: disposeBag)
        
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
}
