//
//  CodablePostItem.swift
//  Posts
//
//  Created by Pusca Ghenadie on 17/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

public struct CodablePostItem: Codable {
    public let id: Int
    public let userId: Int
    public let title: String
    public let body: String
    
    public init(localPostItem: LocalPostItem) {
        self.id = localPostItem.id
        self.title = localPostItem.title
        self.userId = localPostItem.userId
        self.body = localPostItem.body
    }
    
    public var toLocal: LocalPostItem {
        return LocalPostItem(id: id,
                             userId: userId,
                             title: title,
                             body: body)
    }
}
