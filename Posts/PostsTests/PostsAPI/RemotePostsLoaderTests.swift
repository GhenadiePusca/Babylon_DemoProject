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
    struct TestingConstants {
        static let testURL = URL(string: "https://some-url.com")!
    }
    
    let disposeBag = DisposeBag()

    func test_load_requestsDataFromURL() {
        let (sut, client) = makeSUT(url: TestingConstants.testURL)

        sut.load().subscribe().disposed(by: disposeBag)
        
        XCTAssertEqual(client.requestedURLs,
                       [TestingConstants.testURL],
                       "Expected to call \(TestingConstants.testURL), but called \(client.requestedURLs)")
    }
    
    func test_load_deliversErrorOnClientGetError() {
        let (sut, client) = makeSUT()

        expectLoad(toCompleteWithResult: .error(RemotePostsLoaderError.connectivity),
                   sut: sut,
                   stub: {
                    client.loadResult = .error(NSError(domain: "test", code: 500, userInfo: nil))
        })
    }

    func test_load_deliversErrorOnNon200StatusCode() {
        let (sut, client) = makeSUT()

        let invalidStatusCodes = [190, 199, 201, 299, 300, 301, 399, 400, 401, 499, 500]
        invalidStatusCodes.forEach { code in
            expectLoad(toCompleteWithResult: .error(RemotePostsLoaderError.invalidData),
                       sut: sut,
                       stub: {
                        let emptyData = Data()
                        let invalidStatusCodeResponse = RemotePostsLoaderTests.createHTTPResponse(code)
                        client.loadResult = .success((emptyData, invalidStatusCodeResponse))
            })
        }
    }
    
    func test_load_deliversErrorOn200StatusCodeWithInvalidResponse() {
        let (sut, client) = makeSUT()

        expectLoad(toCompleteWithResult: .error(RemotePostsLoaderError.invalidData),
                   sut: sut,
                   stub: {
                    let invalidData = Data(bytes: "invalidData".utf8)
                    let response = RemotePostsLoaderTests.createHTTPResponse(200)
                    client.loadResult = .success((invalidData, response))
        })
    }

    func test_load_deliversDataOn200StatusCodeAndEmptyJSON() {
        let (sut, client) = makeSUT()

        expectLoad(toCompleteWithResult: .success([]),
                   sut: sut,
                   stub: {
                    let emptyJSONData = Data(bytes: "[]".utf8)
                    let response = RemotePostsLoaderTests.createHTTPResponse(200)
                    client.loadResult = .success((emptyJSONData,response))
        })
    }
    
    func test_load_deliversItemsOn200StatusCodeWithData() {
        let (sut, client) = makeSUT()
        
        let (items, json) = makePostItems()

        expectLoad(toCompleteWithResult: .success(items),
                   sut: sut,
                   stub: {
                    let jsonData = try! JSONSerialization.data(withJSONObject: json)
                    let response = RemotePostsLoaderTests.createHTTPResponse(200)
                    client.loadResult = .success((jsonData, response))
        })
    }

    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "https://some-url.com")!,
                         file: StaticString = #file,
                         line: UInt = #line) -> (sut: RemotePostsLoader<PostItem, RemotePostItem>, client: HTTPClientMock) {
        let client = HTTPClientMock()
        let sut = RemotePostsLoader(url: url,
                                    client: client,
                                    mapper: Mapper.remotePostsToPost)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }

    private func expectLoad(toCompleteWithResult expectedResult: SingleEvent<[PostItem]>,
                            sut: RemotePostsLoader<PostItem, RemotePostItem>,
                            file: StaticString = #file,
                            line: UInt = #line,
                            stub: @escaping () -> Void) {

        stub()

        let exp = expectation(description: "Waiting for completion")

        sut.load().subscribe { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.error(receivedError), .error(expectedError)):
                XCTAssertEqual(receivedError as? RemotePostsLoaderError,
                               expectedError as? RemotePostsLoaderError,
                               file: file,
                               line: line)
            default:
                XCTFail("Expected to receive \(expectedResult), got \(String(describing: receivedResult))", file: file, line: line)
            }

            exp.fulfill()
        }.disposed(by: disposeBag)

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

    private static func createHTTPResponse(_ statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: TestingConstants.testURL,
                               statusCode: statusCode,
                               httpVersion: nil,
                               headerFields: nil)!
    }

    final class HTTPClientMock: HTTPClient {
        var loadResult: SingleEvent<GetResult> = .error(NSError(domain: "test", code: 500, userInfo: nil))

        var requestedURLs = [URL]()
        
        func get(fromURL url: URL) -> Single<GetResult> {
            requestedURLs.append(url)

            return .create(subscribe: { single in
                single(self.loadResult)
                return Disposables.create()
            })
        }
    }
}
