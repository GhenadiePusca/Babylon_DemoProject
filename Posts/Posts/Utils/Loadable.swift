//
//  Loadable.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

public enum Loadable<Value> {
    case pending
    case loading
    case loaded(Value)
    case failed(Error)
    
    var shouldReload: Bool {
        switch self {
        case .pending, .failed:
            return true
        default:
            return false
        }
    }

    func combine<OtherValue>(_ other: Loadable<OtherValue>) -> Loadable<(Value, OtherValue)> {
        switch (self, other) {
        case let (.failed(error), _), let (_, .failed(error)):
            return .failed(error)
        case (.loading, _), (_, .loading):
            return .loading
        case (.pending, _),
             (_, .pending):
            return .pending
        case let (.loaded(selfValue), .loaded(otherValue)):
            return .loaded((selfValue, otherValue))
        }
    }
    
    func transform<T>(_ transformer: (Value) -> T) -> Loadable<T> {
        switch self {
        case .loaded(let value):
            return .loaded(transformer(value))
        case .failed(let error):
            return .failed(error)
        case .pending:
            return .pending
        case .loading:
            return .loading
        }
    }
}

extension Loadable where Value: Sequence {
    func filter(isIncluded: (Value.Element) -> Bool) -> Loadable<[Value.Element]> {

        switch self {
        case .loaded(let value):
            return .loaded(value.filter(isIncluded))
        case .pending:
            return .pending
        case .loading:
            return .loading
        case .failed(let error):
            return .failed(error)
        }
    }
}
