//
//  PostsLoader.swift
//  Posts
//
//  Created by Pusca Ghenadie on 11/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import RxSwift

public enum Result<T> {
    case success(T)
    case failure(Error)
}

protocol PostsLoader {
    typealias LoadResult = Result<[PostItem]>
    func load() -> Observable<LoadResult>
}
