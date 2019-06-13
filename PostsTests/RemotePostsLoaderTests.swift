//
//  RemotePostsLoaderTests.swift
//  PostsTests
//
//  Created by Pusca Ghenadie on 11/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
import Posts

class RemotePostsLoaderTests: XCTestCase {
    struct TestingConstants {
        static let testURL = URL(string: "https://some-url.com")!
    }
    
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

        expectLoad(toCompleteWithResult: .error(RemotePostsLoader.Error.connectivity),
                   sut: sut,
                   stub: {
                    client.loadResult = .error(NSError(domain: "test", code: 500, userInfo: nil))
        })
    }

    func test_load_deliversErrorOnNon200StatusCode() {
        let (sut, client) = makeSUT()

        let invalidStatusCodes = [190, 199, 201, 299, 300, 301, 399, 400, 401, 499, 500]
        invalidStatusCodes.forEach { code in
            expectLoad(toCompleteWithResult: .error(RemotePostsLoader.Error.invalidData),
                       sut: sut,
                       stub: {
                        client.loadResult = .success((Data(), RemotePostsLoaderTests.createHTTPResponse(code)))
            })
        }
    }
    
    func test_load_deliversErrorOn200StatusCodeWithInvalidResponse() {
        let (sut, client) = makeSUT()

        expectLoad(toCompleteWithResult: .error(RemotePostsLoader.Error.invalidData),
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

    private func makeSUT(url: URL = URL(string: "https://some-url.com")!) -> (sut: RemotePostsLoader, client: HTTPClientMock) {
        let client = HTTPClientMock()
        let sut = RemotePostsLoader(url: url, client: client)
        
        return (sut, client)
    }

    private func expectLoad(toCompleteWithResult expectedResult: SingleEvent<[PostItem]>,
                            sut: RemotePostsLoader,
                            file: StaticString = #file,
                            line: UInt = #line,
                            stub: @escaping () -> Void) {

        let scheduler = TestScheduler(initialClock: 0)
        var receivedResult: SingleEvent<[PostItem]>?

        scheduler.scheduleAt(0, action: stub)
        scheduler.scheduleAt(1) {
            _ = sut.load().subscribe {
                receivedResult = $0
            }
        }
        scheduler.scheduleAt(3, action: {
            switch (receivedResult, expectedResult) {
            case let (.some(.success(receivedItems)), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.some(.error(receivedError)), .error(expectedError)):
                XCTAssertEqual(receivedError as? RemotePostsLoader.Error,
                               expectedError as? RemotePostsLoader.Error,
                               file: file,
                               line: line)
            default:
                XCTFail("Expected to receive \(expectedResult), got \(String(describing: receivedResult))")
            }
        })

        scheduler.start()
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
            return Single<GetResult>.create(subscribe: { [weak self] single in
                guard let self = self else { return Disposables.create {}}
                single(self.loadResult)
                return Disposables.create {}
            })
        }
    }
}
