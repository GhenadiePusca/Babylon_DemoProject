//
//  AppCoordinatorTests.swift
//  PostsTests
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import XCTest
import RxSwift
import Posts

class AppCoordinatorTests: XCTestCase {
    
    func test_start_postsListViewControllerIsShown() {
        let (sut, nav) = makeSUT()
        
        sut.start()
        
        XCTAssertTrue(nav.visibleViewController is PostsListViewController,
                      "Expected to have PostsListViewController show, but \(nav.visibleViewController) is shown")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: AppCoordinator, nav: UINavigationController) {
        let nav = SynchronousNavController()
        let sut = AppCoordinator(navController: nav,
                                 servicesProvider: ServicesProviderMock())
        trackForMemoryLeaks(sut)
        
        return (sut, nav)
    }
    
    private class ServicesProviderMock: ServicesProvider {
        var postsDataRepo: PostsDataProvider = PostsDataProviderMock()
    }
    
    private class PostsDataProviderMock: PostsDataProvider {
        func postDetailModel(postId: Int) -> PostDetailsModel {
            return PostDetailsModel(title: "",
                                    body: "",
                                    authorName: .just(.pending),
                                    numberOfComments: .just(.pending))
        }
        
        var postItemsLoader: Observable<Loadable<[PostListItemModel]>> = .just(.pending)
        
        func loadPosts() {
            
        }
    }
}

