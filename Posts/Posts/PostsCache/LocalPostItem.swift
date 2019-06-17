//
//  LocalPostItem.swift
//  Posts
//
//  Created by Pusca Ghenadie on 14/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

public struct LocalPostItem: Equatable {
    public let id: Int
    public let userId: Int
    public let title: String
    public let body: String
    
    public init(id: Int,
                userId: Int,
                title: String,
                body: String) {
        self.id = id
        self.title = title
        self.userId = userId
        self.body = body
    }
    
    var toItem: PostItem {
        return PostItem(id: id,
                        userId: userId,
                        title: title,
                        body: body)
    }
}
