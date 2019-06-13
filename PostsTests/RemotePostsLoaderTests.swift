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
    
    func test_load_deliversErrorOnClientGetError() {
        let (sut, client) = makeSUT()
        
        expectLoad(toCompleteWithError: .connectivity,
                   sut: sut,
                   onAction: {
                    let error = NSError(domain: "test", code: 500, userInfo: nil)
                    client.completeWith(error: error)
        })
    }

    func test_load_deliversErrorOnNon200StatusCode() {
        let (sut, client) = makeSUT()

        let invalidStatusCodes = [190, 199, 201, 299, 300, 301, 399, 400, 401, 499, 500]
        invalidStatusCodes.enumerated().forEach { arg in
            let (idx, code) = arg
            
            expectLoad(toCompleteWithError: .invalidData,
                       sut: sut,
                       onAction: {
                        client.completeWith(statusCode: code, idx: idx)
            })
        }
    }
    
    func test_load_deliversErrorOn200StatusCodeWithInvalidResponse() {
        let (sut, client) = makeSUT()

        expectLoad(toCompleteWithError: .invalidData,
                   sut: sut,
                   onAction: {
                    let invalidData = Data(bytes: "invalidData".utf8)
                    client.completeWith(statusCode: 200, data: invalidData)
        })
    }

    func test_load_deliversDataOn200StatusCodeAndEmptyJSON() {
        let (sut, client) = makeSUT()

        expectLoad(toCompleteWithData: [],
                   sut: sut,
                   onAction: {
                    let emptyJsonData = Data(bytes: "[]".utf8)
                    client.completeWith(statusCode: 200,
                                        data: emptyJsonData)
        })
    }
    
    func test_load_deliversItemsOn200StatusCodeWithData() {
        let (sut, client) = makeSUT()
        
        let (items, json) = makePostItems()
        
        expectLoad(toCompleteWithData: items,
                   sut: sut,
                   onAction: {
                    let jsonData = try! JSONSerialization.data(withJSONObject: json)
                    client.completeWith(statusCode: 200,
                                        data: jsonData)
        })
    }

    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "https://some-url.com")!) -> (sut: RemotePostsLoader, client: HTTPClientMock) {
        let client = HTTPClientMock()
        let sut = RemotePostsLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    private func expectLoad(toCompleteWithError expectedError: RemotePostsLoader.Error,
                            sut: RemotePostsLoader,
                            file: StaticString = #file,
                            line: UInt = #line,
                            onAction action: () -> Void) {
        let exp = expectation(description: "Wait for completion")
        _ = sut.load().subscribe(onError: { error in
            XCTAssertEqual(error as! RemotePostsLoader.Error, expectedError)
            exp.fulfill()
        })
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expectLoad(toCompleteWithData expectedData: [PostItem],
                            sut: RemotePostsLoader,
                            file: StaticString = #file,
                            line: UInt = #line,
                            onAction action: () -> Void) {
        let exp = expectation(description: "Wait for completion")
        _ = sut.load().subscribe(onNext: { data in
            XCTAssertEqual(data, expectedData)
            exp.fulfill()
        })
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makePostItems() -> (items: [PostItem], json: [[String: Any]]) {
        let item1 = PostItem(id: 1,
                             userId: 2,
                             title: "A title 1",
                             body: "A body 1")
        
        let item2 = PostItem(id: 2,
                             userId: 1,
                             title: "A title 2",
                             body: "A body 2")
        
        let item1JSON: [String: Any] = [
            "id": 1,
            "userId": 2,
            "title": "A title 1",
            "body": "A body 1"
        ]
        
        let item2JSON: [String: Any] = [
            "id": 2,
            "userId": 1,
            "title": "A title 2",
            "body": "A body 2"
        ]
        
        let invalidItemJSON: [String: Any] = ["userId": 2, "body": "Some"]
        
        return ([item1, item2], [item1JSON, item2JSON, invalidItemJSON])
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
            messages[idx].obs.onError(error)
        }
        
        func completeWith(statusCode: Int, data: Data = Data(), idx: Int = 0) {
            let response = HTTPURLResponse(url: messages[idx].url,
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[idx].obs.onNext((data, response))
        }
    }
}
