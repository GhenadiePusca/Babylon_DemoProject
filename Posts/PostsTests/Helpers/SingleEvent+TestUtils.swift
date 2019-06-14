//
//  SingleEvent+TestUtils.swift
//  PostsTests
//
//  Created by Pusca, Ghenadie on 14/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import RxSwift

extension SingleEvent {
    var isSuccess: Bool {
        guard case .success = self else {
            return false
        }

        return true
    }
}
