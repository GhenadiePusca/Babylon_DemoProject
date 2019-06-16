//
//  Loadable+Equatable.swift
//  PostsTests
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Posts

extension Loadable: Equatable where Value: Equatable {
    public static func == (lhs: Loadable<Value>, rhs: Loadable<Value>) -> Bool {
        switch (lhs, rhs) {
        case (.pending, .pending),
             (.loading, .loading),
             (.failed, .failed):
            return true
        case let (.loaded(lhsValue), .loaded(rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}
