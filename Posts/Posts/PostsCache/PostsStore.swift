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

    /// The operation is executed on background thread
    func deleteCachedPosts() -> Completable
    
    /// The operation is executed on background thread
    func savePosts(_ items: [LocalPostItem]) -> Completable
    
    /// The operation is executed on background threadç
    func retrieve() -> Single<RetrieveResult>
}
