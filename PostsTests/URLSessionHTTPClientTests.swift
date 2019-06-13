//
//  URLSessionHTTPClientTests.swift
//  PostsTests
//
//  Created by Pusca, Ghenadie on 13/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import XCTest
import Posts
import RxSwift

final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get(fromURL url: URL) -> Single<GetResult> {
        return Single<GetResult>.create(subscribe: { [weak self] single in
            self?.session.dataTask(with: url, completionHandler: { (_, _, error) in
                if let error = error {
                    single(.error(error))
                }
            }).resume()
            return Disposables.create {
            }
        })
    }
}
class URLSessionHTTPClientTests: XCTestCase {

    override func setUp() {
        super.setUp()

        URLProtocolStub.startInterceptingRequests()
    }

    override func tearDown() {
        super.tearDown()

        URLProtocolStub.stopInterceptingRequests()
    }

    func test_getFromURL_failsOnError() {
        let url = URL(string: "https://someURL.com")!
        let error = NSError(domain: "err", code: 500)
        URLProtocolStub.stub(url: url, error: error)

        let sut = URLSessionHTTPClient()

        let exp = expectation(description: "Wait for completion")

        sut.get(fromURL: url).subscribe { result in
            switch result {
            case let .error(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with error \(error), got \(result)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    private class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()

        private struct Stub {
            let error: Error?
        }

        static func startInterceptingRequests() {
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
        }

        static func stub(url: URL, error: Error?) {
            stubs[url] = Stub(error: error)
        }

        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }

            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }
}
