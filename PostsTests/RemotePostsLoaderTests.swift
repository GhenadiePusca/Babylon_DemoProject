//
//  RemotePostsLoaderTests.swift
//  PostsTests
//
//  Created by Pusca Ghenadie on 11/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import XCTest
import RxSwift
import Posts

class RemotePostsLoaderTests: XCTestCase {
    
    func test_load_requestsDataFromURL() {
        let testURL = URL(string: "https://some-url.com")!
        let (sut, client) = makeSUT(url: testURL)

        _ = sut.load()
        
        XCTAssertEqual(client.requestedURLs,
                       [testURL],
                       "Expected to call \(testURL), but called \(client.requestedURLs)")
    }
    
    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "https://some-url.com")!) -> (sut: RemotePostsLoader, client: HTTPClientMock) {
        let client = HTTPClientMock()
        let sut = RemotePostsLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    final class HTTPClientMock: HTTPClient {
        var requestedURLs = [URL]()
        func get(fromURL url: URL) {
            requestedURLs.append(url)
        }
    }
}
