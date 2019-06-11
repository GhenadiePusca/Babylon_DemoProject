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
    
    func test_load_deliversErrorOnGetError() {
        let (sut, client) = makeSUT()
        
        let exp = expectation(description: "wait for completion")
        var captureErrors = [RemotePostsLoader.Error]()
        
        let disposable = sut.load().subscribe(onNext: { result in
            guard case let .failure(error) = result else {
                return
            }
            captureErrors.append(error as! RemotePostsLoader.Error)
            exp.fulfill()
        })
        
        let clientError = NSError(domain: "testError", code: 1, userInfo: nil)
        client.completeWith(error: clientError)

        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(captureErrors, [.connectivity])
        
        disposable.dispose()
    }
    
    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "https://some-url.com")!) -> (sut: RemotePostsLoader, client: HTTPClientMock) {
        let client = HTTPClientMock()
        let sut = RemotePostsLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    final class HTTPClientMock: HTTPClient {
        typealias message = (url: URL, obs: PublishSubject<GetResult>)

        var messages = [message]()
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(fromURL url: URL) -> Observable<GetResult> {
            let obs = PublishSubject<GetResult>.init()
            messages.append((url, obs))
            
            return obs
        }
        
        func completeWith(error: Error, idx: Int = 0) {
            messages[idx].obs.onNext(.failure(error))
        }
    }
}
