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
        postsDataRepo = PostsRepo(postsLoader: Factory.remotePostsLoaderWithCacheFallaback,
                                  commentsLoader: Factory.remoteCommentsLoaderWithCacheFallaback)
    }
    
    // MARK: - Posts loader properties
    private static var remotePostsLoaderWithCacheFallaback: AnyItemsLoader<PostItem> { return AnyItemsLoader(RemotePostsLoaderWithLocalFallback(remoteLoader: remotePostsLoader,
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
    // MARK: - Comments loader properties
    private static var remoteCommentsLoaderWithCacheFallaback: AnyItemsLoader<CommentItem> { return AnyItemsLoader(RemotePostsLoaderWithLocalFallback(remoteLoader: remoteCommentsLoader,
                                                                                                                                                      localPostsLoader: localCommentsLoader)) }
    
    private static var remoteCommentsLoader: AnyItemsLoader<CommentItem> { return AnyItemsLoader(RemotePostsLoader(url: remoteCommentsURL,
                                                                                                                   client: urlSessionHttpClient,
                                                                                                                   mapper: Mapper.remoteCommentsToComments)) }
    private static var localCommentsLoader: AnyItemsStorageManager<CommentItem> { return AnyItemsStorageManager(LocalItemsLoader(store: fileSystemCommentsStore,
                                                                                                                                 localToItemMapper: Mapper.localCommentsToComments,
                                                                                                                                 itemToLocalMapper: Mapper.commentsToLocalComments)) }
    
    private static var fileSystemCommentsStore: AnyItemsStore<LocalCommentItem> { return AnyItemsStore(FileSystemItemsStore(storeURL: localCommentsURL,
                                                                                                                            savedToEncodedMapper: Mapper.localCommentsToEncodable,
                                                                                                                            econdedToSavedMapper: Mapper.encodableCommentsToLocalComments))}
    
    // MARK: - Users loader properties
    private static var remoteUsersLoaderWithCacheFallaback: AnyItemsLoader<UserItem> { return AnyItemsLoader(RemotePostsLoaderWithLocalFallback(remoteLoader: remoteUsersLoader,
                                                                                                                                                localPostsLoader: localUsersLoader)) }
    
    private static var remoteUsersLoader: AnyItemsLoader<UserItem> { return AnyItemsLoader(RemotePostsLoader(url: remoteUsersURL,
                                                                                                             client: urlSessionHttpClient,
                                                                                                             mapper: Mapper.remoteUsersToUsers)) }
    private static var localUsersLoader: AnyItemsStorageManager<UserItem> { return AnyItemsStorageManager(LocalItemsLoader(store: fileSystemUsersStore,
                                                                                                                           localToItemMapper: Mapper.localUsersToUers,
                                                                                                                           itemToLocalMapper: Mapper.usersToLocalUsers)) }
    
    private static var fileSystemUsersStore: AnyItemsStore<LocalUserItem> { return AnyItemsStore(FileSystemItemsStore(storeURL: localUsersURL,
                                                                                                                      savedToEncodedMapper: Mapper.localUsersToCodableUsers,
                                                                                                                      econdedToSavedMapper: Mapper.codableUsersToLocalUsers))}

    // MARK: - Factory helpers
    private static var remotePostsURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com/posts")!
    }
    
    private static var remoteCommentsURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com/comments")!
    }
    
    private static var remoteUsersURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com/users")!
    }
    
    private static var localPostsURL: URL {
        return localRootURL.appendingPathComponent("PostItems")
    }
    
    private static var localCommentsURL: URL {
        return localRootURL.appendingPathComponent("Comments")
    }
    
    private static var localUsersURL: URL {
        return localRootURL.appendingPathComponent("Users")
    }
    
    private static var localRootURL: URL {
        let rootURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("PostsApp")
        try! FileManager.default.createDirectory(at: rootURL,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
        return rootURL
    }
}
