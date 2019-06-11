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

final class RemotePostsLoader {
    let url: URL
    let client: HTTPClient

    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load() -> Observable<[PostItem]> {
        client.get(fromURL: url)
        return .just([])
    }
}

final class HTTPClient {
    var requestedURLs = [URL]()
    func get(fromURL url: URL) {
        requestedURLs.append(url)
    }
}

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

    private func makeSUT(url: URL = URL(string: "https://some-url.com")!) -> (sut: RemotePostsLoader, client: HTTPClient) {
        let client = HTTPClient()
        let sut = RemotePostsLoader(url: url, client: client)
        
        return (sut, client)
    }
}
