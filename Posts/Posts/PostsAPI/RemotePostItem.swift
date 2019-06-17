//
//  RemotePostItem.swift
//  Posts
//
//  Created by Pusca Ghenadie on 14/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

public struct RemotePostItem: Decodable {
    public let id: Int
    public let userId: Int
    public let title: String
    public let body: String
}
