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
        XCTAssertFalse(getResultFor(data: nil, response: nil, error: nil).isSuccess)
        XCTAssertFalse(getResultFor(data: nil, response: nil, error: nil).isSuccess)
        XCTAssertFalse(getResultFor(data: nil, response: nonHTTPURLResponse(), error: nil).isSuccess)
        XCTAssertFalse(getResultFor(data: nil, response: nonHTTPURLResponse(), error: anyError()).isSuccess)
        XCTAssertFalse(getResultFor(data: nil, response: anyHTTPURLResponse(), error: anyError()).isSuccess)
        XCTAssertFalse(getResultFor(data: anyData(), response: nil, error: nil).isSuccess)
        XCTAssertFalse(getResultFor(data: anyData(), response: nil, error: anyError()).isSuccess)
        XCTAssertFalse(getResultFor(data: anyData(), response: nonHTTPURLResponse(), error: anyError()).isSuccess)
        XCTAssertFalse(getResultFor(data: anyData(), response: anyHTTPURLResponse(), error: anyError()).isSuccess)
        XCTAssertFalse(getResultFor(data: anyData(), response: nonHTTPURLResponse(), error: nil).isSuccess)
    }

    func test_getFromURL_succeedsOnHTTPResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()

        let result = getResultFor(data: data, response: response, error: nil)

        switch result {
        case let .success((receivedData, receivedResponse)):
            XCTAssertEqual(receivedData, data)
            XCTAssertEqual(receivedResponse.url, response.url)
            XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
        default:
            XCTFail("Expected success, got \(result)")
        }
    }

    func test_getFromURL_deliversEmptyDataAndResponseOnSuccesHTTPResponseWithNilData() {
        let emptyData = Data()
        let response = anyHTTPURLResponse()

        let result = getResultFor(data: emptyData, response: response, error: nil)

        switch result {
        case let .success((receivedData, receivedResponse)):
            XCTAssertEqual(receivedData, emptyData)
            XCTAssertEqual(receivedResponse.url, response.url)
            XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
        default:
            XCTFail("Expected success, got \(result)")
        }
    }

    // MARK: - Helpers

    private func makeSUT() -> HTTPClient {
        return URLSessionHTTPClient()
    }

    private func getResultFor(data: Data?,
                             response: URLResponse?,
                             error: Error?,
                             file: StaticString = #file,
                             line: UInt = #line) -> SingleEvent<URLSessionHTTPClient.GetResult> {
        URLProtocolStub.stub(error: error,
                             data: data,
                             response: response)

        let exp = expectation(description: "Wait for completion")

        var capturedResult: SingleEvent<URLSessionHTTPClient.GetResult>!
        let sut = makeSUT()
        _ = sut.get(fromURL: anyURL()).subscribe { result in
            capturedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        return capturedResult
    }

    private func anyError() -> NSError {
        return NSError(domain: "err", code: 500)
    }

    private func anyURL() -> URL {
        return URL(string: "https://someURL.com")!
    }

    private func anyData() -> Data {
        return Data(bytes: "some data".utf8)
    }

    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(),
                           mimeType: nil,
                           expectedContentLength: 0,
                           textEncodingName: nil)
    }

    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(),
                               statusCode: 0,
                               httpVersion: nil,
                               headerFields: nil)!
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
