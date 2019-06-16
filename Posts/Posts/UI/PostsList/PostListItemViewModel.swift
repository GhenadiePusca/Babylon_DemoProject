//
//  PostListItemViewModel.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

final public class PostListItemViewModel {
    public var postName: String {
        return model.postName
    }
    
    private let model: PostListItemModel
    
    public init(model: PostListItemModel) {
        self.model = model
    }
}
