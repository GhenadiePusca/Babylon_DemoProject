//
//  URLSessionHTTPClient.swift
//  Posts
//
//  Created by Pusca, Ghenadie on 14/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation
import RxSwift

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    private struct UnexpectedValueRepresentation: Error {}

    public func get(fromURL url: URL) -> Single<GetResult> {
        return .create(subscribe: { [weak self] single in
            guard let self = self else { return Disposables.create() }
            self.session.dataTask(with: url, completionHandler: { (data, response, error) in
                if let error = error {
                    single(.error(error))
                } else if let data = data, let response = response as? HTTPURLResponse {
                    single(.success((data, response)))
                } else {
                    single(.error(UnexpectedValueRepresentation()))
                }
            }).resume()
            return Disposables.create {}
        })
    }
}
