//
//  Mapper.swift
//  Posts
//
//  Created by Pusca Ghenadie on 17/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

public struct Mapper {
    public static func localPostsEncodable(_ local: [LocalPostItem]) -> [CodablePostItem] {
        return local.map { CodablePostItem(localPostItem: $0) }
    }
    
    public static func encodableToLocal(_ codable: [CodablePostItem]) -> [LocalPostItem] {
        return codable.map { LocalPostItem(id: $0.id,
                                           userId: $0.userId,
                                           title: $0.title,
                                           body: $0.body) }
    }
    
    public static func localPostsToPost(_ local: [LocalPostItem]) -> [PostItem] {
        return local.map { PostItem(id: $0.id,
                                    userId: $0.userId,
                                    title: $0.title,
                                    body: $0.body) }
    }
    
    public static func postToLocalPosts(_ posts: [PostItem]) -> [LocalPostItem] {
        return posts.map { LocalPostItem(id: $0.id,
                                         userId: $0.userId,
                                         title: $0.title,
                                         body: $0.body) }
    }
    
    public static func remotePostsToPost(_ posts: [RemotePostItem]) -> [PostItem] {
        return posts.map { PostItem(id: $0.id,
                                    userId: $0.userId,
                                    title: $0.title,
                                    body: $0.body) }
    }
}
