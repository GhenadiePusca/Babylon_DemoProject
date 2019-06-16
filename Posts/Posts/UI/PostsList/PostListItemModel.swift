//
//  PostListItemModel.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

public struct PostListItemModel: Equatable {
    public let postName: String
    
    public init(postName: String) {
        self.postName = postName
    }
}
