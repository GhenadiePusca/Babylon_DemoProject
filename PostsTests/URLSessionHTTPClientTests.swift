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

    private struct UnexpectedValueRepresentation: Error {}
    func get(fromURL url: URL) -> Single<GetResult> {
        return Single<GetResult>.create(subscribe: { [weak self] single in
            self?.session.dataTask(with: url, completionHandler: { (_, _, error) in
                if let error = error {
                    single(.error(error))
                } else {
                    single(.error(UnexpectedValueRepresentation()))
                }
            }).resume()
            return Disposables.create {}
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
        let url = anyURL()
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
        let url = anyURL()
        let error = anyError()
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

    func test_getFromURL_failsOnInvalidRepresantations() {
        let nonHTTPUrlResponse = URLResponse(url: anyURL(),
                                      mimeType: nil,
                                      expectedContentLength: 0,
                                      textEncodingName: nil)
        let httpURLResponse = HTTPURLResponse(url: anyURL(),
                                              statusCode: 0,
                                              httpVersion: nil,
                                              headerFields: nil)
        let data = Data()

        XCTAssertNotNil(getErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(getErrorFor(data: nil, response: nonHTTPUrlResponse, error: nil))
        XCTAssertNotNil(getErrorFor(data: nil, response: httpURLResponse, error: nil))
        XCTAssertNotNil(getErrorFor(data: nil, response: nonHTTPUrlResponse, error: anyError()))
        XCTAssertNotNil(getErrorFor(data: nil, response: httpURLResponse, error: anyError()))
        XCTAssertNotNil(getErrorFor(data: data, response: nil, error: nil))
        XCTAssertNotNil(getErrorFor(data: data, response: nil, error: anyError()))
        XCTAssertNotNil(getErrorFor(data: data, response: nonHTTPUrlResponse, error: anyError()))
        XCTAssertNotNil(getErrorFor(data: data, response: httpURLResponse, error: anyError()))
        XCTAssertNotNil(getErrorFor(data: data, response: nonHTTPUrlResponse, error: nil))
    }

    // MARK: - Helpers

    private func makeSUT() -> URLSessionHTTPClient {
        return URLSessionHTTPClient()
    }

    private func getErrorFor(data: Data?,
                             response: URLResponse?,
                             error: Error?,
                             file: StaticString = #file,
                             line: UInt = #line) -> Error? {
        URLProtocolStub.stub(error: error,
                             data: data,
                             response: response)

        let exp = expectation(description: "Wait for completion")

        var capturedError: Error?
        let sut = makeSUT()
        _ = sut.get(fromURL: anyURL()).subscribe { result in
            switch result {
            case .error(let error):
                capturedError = error
            default:
                XCTFail("Expected error, got \(result)")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        return capturedError
    }

    private func anyError() -> NSError {
        return NSError(domain: "err", code: 500)
    }

    private func anyURL() -> URL {
        return URL(string: "https://someURL.com")!
    }

    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?

        private struct Stub {
            let error: Error?
            let data: Data?
            let response: URLResponse?
        }

        static func startInterceptingRequests() {
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }

        static func stub(error: Error?, data: Data?, response: URLResponse?) {
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
