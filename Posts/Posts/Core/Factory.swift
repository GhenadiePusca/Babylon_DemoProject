//
//  Factory.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

public protocol ServicesProvider {
    var postsDataRepo: PostsDataProvider { get }
}

public struct Factory: ServicesProvider {
    public let postsDataRepo: PostsDataProvider
    
    public init() {
        postsDataRepo = PostsRepo(postsLoader: Factory.remoteLoaderWithCacheFallaback)
    }
    
    // MARK: - Factory properties
    private static var remoteLoaderWithCacheFallaback: RemotePostsLoaderWithLocalFallback { return RemotePostsLoaderWithLocalFallback(remoteLoader: remotePostsLoader,
                                                                                    localPostsLoader: localPostsLoader) }
    
    private static var remotePostsLoader: PostsLoader { return RemotePostsLoader(url: remotePostsURL,
                                                      client: urlSessionHttpClient) }
    private static var localPostsLoader: PostsLoader & PostsPersister { return LocalPostsLoader(store: fileSystemPostsStore) }

    private static var urlSessionHttpClient: HTTPClient { return URLSessionHTTPClient() }
    private static var fileSystemPostsStore: PostsStore { return FileSystemPostsStore(storeURL: localPostsURL) }
    
    private static var remotePostsURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com/posts")!
    }
    
    private static var localPostsURL: URL {
        return localRootURL.appendingPathComponent("PostItems")
    }
    
    private static var localRootURL: URL {
        let rootURL = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask).first!.appendingPathComponent("PostsApp")
        try? FileManager.default.createDirectory(at: rootURL,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
        return rootURL
    }
}
