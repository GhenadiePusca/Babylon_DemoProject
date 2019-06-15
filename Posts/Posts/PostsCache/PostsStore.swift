//
//  PostsStore.swift
//  Posts
//
//  Created by Pusca Ghenadie on 13/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import RxSwift

public protocol PostsStore {
    typealias RetrieveResult = [LocalPostItem]

    func deleteCachedPosts() -> Completable
    func savePosts(_ items: [LocalPostItem]) -> Completable
    func retrieve() -> Single<RetrieveResult>
}
