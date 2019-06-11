//
//  RemotePostsLoader.swift
//  Posts
//
//  Created by Pusca Ghenadie on 11/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import RxSwift
import Foundation

final public  class RemotePostsLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load() -> Observable<[PostItem]> {
        client.get(fromURL: url)
        return .just([])
    }
}
