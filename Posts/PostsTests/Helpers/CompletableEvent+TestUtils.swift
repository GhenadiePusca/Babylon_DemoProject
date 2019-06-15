//
//  CompletableEvent+TestUtils.swift
//  PostsTests
//
//  Created by Pusca Ghenadie on 15/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import RxSwift

extension CompletableEvent {
    func isSameEventAs(_ other: CompletableEvent) -> Bool {
        switch (self, other) {
        case (.completed, .completed), (.error, .error):
            return true
        default:
            return false
        }
    }
    
    func isSameStateAndEqualNSErrorsAs(_ other: CompletableEvent) -> Bool {
        switch (self, other) {
        case (.completed, .completed):
            return true
        case let (.error(selfError), .error(otherError)):
            return (selfError as NSError) == (otherError as NSError)
        default:
            return false
        }
    }
}
