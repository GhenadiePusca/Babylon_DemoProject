//
//  ModelsFactory.swift
//  PostsTests
//
//  Created by Pusca Ghenadie on 14/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation
import Posts

// MARK: -  Factory methods
func anyItem() -> PostItem {
    return PostItem(id: 1, userId: 2, title: "any title", body: "any body")
}

func anyItems() -> [PostItem] {
    let item1 = PostItem(id: 1, userId: 2, title: "any title", body: "any body")
    let item2 = PostItem(id: 2, userId: 4, title: "any title 2", body: "any body 2")
    
    return [item1, item2]
}

func anyNSError() -> NSError {
    return NSError(domain: "err", code: 1)
}

// MARK: - Extension
extension PostItem {
    var toLocal: LocalPostItem {
        return LocalPostItem(id: id,
                             userId: userId,
                             title: title,
                             body: body)
    }
}
