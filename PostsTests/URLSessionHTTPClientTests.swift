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

    func test_getFromURL_performsGetRequestWithURL() {
        let url = URL(string: "https://someURL.com")!
        let exp = expectation(description: "Wait for completion")

        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        let sut = makeSUT()
        _ = sut.get(fromURL: url).subscribe { _ in }

        wait(for: [exp], timeout: 1.0)

    }
    func test_getFromURL_failsOnError() {
        let url = URL(string: "https://someURL.com")!
        let error = NSError(domain: "err", code: 500)
        URLProtocolStub.stub(error: error, data: nil, response: nil)

        let sut = makeSUT()

        let exp = expectation(description: "Wait for completion")

        _ = sut.get(fromURL: url).subscribe { result in
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

    // MARK: - Helpers

    private func makeSUT() -> URLSessionHTTPClient {
        return URLSessionHTTPClient()
    }
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?

        private struct Stub {
            let error: Error?
            let data: Data?
            let response: HTTPURLResponse?
        }

        static func startInterceptingRequests() {
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }

        static func stub(error: Error?, data: Data?, response: HTTPURLResponse?) {
            stub = Stub(error: error, data: data, response: response)
        }

        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }

        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }
}
