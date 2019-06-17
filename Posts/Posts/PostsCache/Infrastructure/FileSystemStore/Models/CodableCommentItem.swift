//
//  CodableCommentItem.swift
//  Posts
//
//  Created by Pusca Ghenadie on 17/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

public struct CodableCommentItem: Codable {
    public let id: Int
    public let postId: Int
    public let authorName: String
    public let authorEmail: String
    public let body: String
    
    public init(localItem: LocalCommentItem) {
        self.id = localItem.id
        self.postId = localItem.postId
        self.authorName = localItem.authorName
        self.authorEmail = localItem.authorEmail
        self.body = localItem.body
    }
}
