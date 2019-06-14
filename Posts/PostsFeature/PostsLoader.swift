//
//  PostsLoader.swift
//  Posts
//
//  Created by Pusca Ghenadie on 11/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import RxSwift

public protocol PostsLoader {
    typealias LoadResult = [PostItem]
    func load() -> Single<LoadResult>
}
