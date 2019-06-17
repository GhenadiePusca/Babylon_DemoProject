//
//  RemoteCommentItem.swift
//  Posts
//
//  Created by Pusca Ghenadie on 17/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

public struct RemoteCommentItem: Decodable {
    public let id: Int
    public let postId: Int
    public let name: String
    public let email: String
    public let body: String
}
