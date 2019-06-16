//
//  Factory.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

struct Factory {
    lazy var postsRepo = PostsRepo(postsLoader: remoteLoaderWithCacheFallaback)
    
    lazy var remoteLoaderWithCacheFallaback = RemotePostsLoaderWithLocalFallback(remoteLoader: <#T##PostsLoader#>,
                                                                                 localPostsLoader: <#T##PostsLoader & PostsPersister#>)
    
    lazy var remotePostsLoader = RemotePostsLoader(url: remotePostsURL,
                                                   client: urlSessionHttpClient)
    lazy var localPostsLoader = LocalPostsLoader(store: fileSystemPostsStore)

    lazy var urlSessionHttpClient = URLSessionHTTPClient()
    lazy var fileSystemPostsStore = FileSystemPostsStore(storeURL: lcoalPostsURL)
    
    var remotePostsURL: URL {
        return URL(string: "http://jsonplaceholder.typicode.com/posts")!
    }
    
    var lcoalPostsURL: URL {
        return localRootURL.appendingPathComponent("PostItems")
    }
    
    private var localRootURL: URL {
        return FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask).first!.appendingPathComponent("PostsApp")
    }
}
