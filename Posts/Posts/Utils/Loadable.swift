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
}
