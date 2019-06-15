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

extension SingleEvent where Element: Equatable {
    func isSameAs(_ other: SingleEvent) -> Bool {
        switch (self, other) {
        case let (.success(selfValue), .success(otherValue)):
            return selfValue == otherValue
        case let (.error(selfError), .error(otherError)):
            return (selfError as NSError) == (otherError as NSError)
        default:
            return false
            
        }
    }
}
