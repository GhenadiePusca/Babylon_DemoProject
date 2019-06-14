//
//  RemotePostItem.swift
//  Posts
//
//  Created by Pusca Ghenadie on 14/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

internal struct RemotePostItem: Decodable {
    internal let id: Int
    internal let userId: Int
    internal let title: String
    internal let body: String
}
