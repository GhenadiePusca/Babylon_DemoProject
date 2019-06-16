//
//  PostsPersister.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import RxSwift

public protocol PostsPersister {
    func save(_ items: [PostItem]) -> Completable
}
