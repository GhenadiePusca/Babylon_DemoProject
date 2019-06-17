//
//  PostsAPIEndToEndTests.swift
//  PostsAPIEndToEndTests
//
//  Created by Pusca Ghenadie on 14/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import XCTest
import Posts
import RxSwift

class PostsAPIEndToEndTests: XCTestCase {
    
    func test_getDataFromTestServerGetsFixedTestData() {
        let testURL = URL(string: "https://poststestapi.free.beeceptor.com/")!
        
        let client = URLSessionHTTPClient()
        let loader = RemotePostsLoader(url: testURL,
                                       client: client,
                                       mapper: Mapper.remotePostsToPost)
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(loader)
        
        let exp = expectation(description: "Wait for load")

        let expectedPosts = expectedFixedPostItems()
        _ = loader.load().subscribe { result in
            switch result {
            case .success(let receivedPosts):
                XCTAssertEqual(receivedPosts[0], expectedPosts[0])
                XCTAssertEqual(receivedPosts[1], expectedPosts[1])
                XCTAssertEqual(receivedPosts[2], expectedPosts[2])
            default:
                XCTFail("Expected to get posts, got \(result)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
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
}
