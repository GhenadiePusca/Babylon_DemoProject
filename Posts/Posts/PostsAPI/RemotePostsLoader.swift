//
//  RemotePostsLoader.swift
//  Posts
//
//  Created by Pusca Ghenadie on 11/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import RxSwift
import Foundation

public enum RemotePostsLoaderError: Error {
    case connectivity
    case invalidData
}

final public class RemotePostsLoader<Item, RemoteItem: Decodable>: ItemsLoader {
    private let url: URL
    private let client: HTTPClient
    
    public typealias RemoteToPostsMapper = ([RemoteItem]) -> [Item]
    private let remoteToPostsMapper: RemoteToPostsMapper
    
    public init(url: URL,
                client: HTTPClient,
                mapper: @escaping RemoteToPostsMapper) {
        self.url = url
        self.client = client
        self.remoteToPostsMapper = mapper
    }
    
    public func load() -> Single<[Item]> {
        let mapper = remoteToPostsMapper
        return client.get(fromURL: url).catchError { _ in
            throw RemotePostsLoaderError.connectivity
        }.map { try mapper(RemotePostsLoader.mapSuccess($0)) }
    }
    
    private static func mapSuccess<Item: Decodable>(_ result: (data: Data, response: HTTPURLResponse)) throws -> [Item] {
        let OK_HTTTP_RESPONSE = 200
        guard result.response.statusCode == OK_HTTTP_RESPONSE,
            let resultContainer = try? JSONDecoder().decode(FailableDecodableArray<Item>.self,
                                                            from: result.data) else {
                        throw RemotePostsLoaderError.invalidData
        }
        
        return resultContainer.elements
    }
}


