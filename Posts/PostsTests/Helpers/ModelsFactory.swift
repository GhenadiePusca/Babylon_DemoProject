//
//  ModelsFactory.swift
//  PostsTests
//
//  Created by Pusca Ghenadie on 14/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation
import Posts

internal func anyItem() -> PostItem {
    return PostItem(id: 1, userId: 2, title: "any title", body: "any body")
}

internal func anyNSError() -> NSError {
    return NSError(domain: "err", code: 1)
}
