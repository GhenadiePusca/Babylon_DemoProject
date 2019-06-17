//
//  CommentItem.swift
//  Posts
//
//  Created by Pusca Ghenadie on 17/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

public struct CommentItem: Equatable {
    public let id: Int
    public let postId: Int
    public let authorName: String
    public let authorEmail: String
    public let body: String
    
    public init(id: Int,
                postId: Int,
                authorName: String,
                authorEmail: String,
                body: String) {
        self.id = id
        self.postId = postId
        self.authorName = authorName
        self.authorEmail = authorEmail
        self.body = body
    }
}
