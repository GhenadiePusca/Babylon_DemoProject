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
    private static var remoteLoaderWithCacheFallaback: AnyItemsLoader<PostItem> { return AnyItemsLoader(RemotePostsLoaderWithLocalFallback(remoteLoader: remotePostsLoader,
                                                                                    localPostsLoader: localPostsLoader)) }
    
    private static var remotePostsLoader: AnyItemsLoader<PostItem> { return AnyItemsLoader(RemotePostsLoader(url: remotePostsURL,
                                                                                                             client: urlSessionHttpClient,
                                                                                                             mapper: Mapper.remotePostsToPost)) }
    private static var localPostsLoader: AnyItemsStorageManager<PostItem> { return AnyItemsStorageManager(LocalItemsLoader(store: fileSystemPostsStore,
                                                                                                         localToItemMapper: Mapper.localPostsToPost,
                                                                                                         itemToLocalMapper: Mapper.postToLocalPosts)) }

    private static var urlSessionHttpClient: HTTPClient { return URLSessionHTTPClient() }
    private static var fileSystemPostsStore: AnyItemsStore<LocalPostItem> { return AnyItemsStore(FileSystemItemsStore(storeURL: localPostsURL,
                                                                                               savedToEncodedMapper: Mapper.localPostsEncodable,
                                                                                               econdedToSavedMapper: Mapper.encodableToLocal))}
    
    private static var remotePostsURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com/posts")!
    }
    
    private static var localPostsURL: URL {
        return localRootURL.appendingPathComponent("PostItems")
    }
    
    private static var localRootURL: URL {
        let rootURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("PostsApp")
        try! FileManager.default.createDirectory(at: rootURL,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
        return rootURL
    }
}
