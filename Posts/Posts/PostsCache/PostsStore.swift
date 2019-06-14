//
//  PostsStore.swift
//  Posts
//
//  Created by Pusca Ghenadie on 13/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import RxSwift

public protocol PostsStore {
    func deleteCachedPosts() -> Single<Void>
    func savePosts(_ items: [LocalPostItem]) -> Single<Void>
    func retrieve()
}
