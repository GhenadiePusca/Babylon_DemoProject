//
//  FileSystemPostsStore.swift
//  Posts
//
//  Created by Pusca Ghenadie on 15/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation
import RxSwift

public class FileSystemPostsStore: PostsStore {
    
    private struct CodablePostItem: Codable {
        let id: Int
        let userId: Int
        let title: String
        let body: String
        
        init(localPostItem: LocalPostItem) {
            self.id = localPostItem.id
            self.title = localPostItem.title
            self.userId = localPostItem.userId
            self.body = localPostItem.body
        }
        
        var toLocal: LocalPostItem {
            return LocalPostItem(id: id,
                                 userId: userId,
                                 title: title,
                                 body: body)
        }
    }
    
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func deleteCachedPosts() -> Completable {
        return .create(subscribe: { completable in
            if FileManager.default.fileExists(atPath: self.storeURL.path) {
                do {
                    try FileManager.default.removeItem(at: self.storeURL)
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
            } else {
                completable(.completed)
            }
            
            return Disposables.create()
        })
    }
    
    public func savePosts(_ items: [LocalPostItem]) -> Completable {
        return encodeItems(items).flatMapCompletable(writeEncodedData)
    }
    
    public func retrieve() -> Single<RetrieveResult> {
        return getCachedData().flatMap(decodeCachedData).ifEmpty(default: [])
    }
    
    // MARK: - Retrieval helpers
    
    private func getCachedData() -> Maybe<Data> {
        return .create(subscribe: { single in
            do {
                let data = try Data(contentsOf: self.storeURL)
                single(.success(data))
            } catch {
                single(.completed)
            }
            
            return Disposables.create()
        })
    }
    
    private func decodeCachedData(_ data: Data) -> Maybe<RetrieveResult> {
        return .create(subscribe: { single in
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(FailableDecodableArray<CodablePostItem>.self, from: data)
                single(.success(decoded.elements.map { $0.toLocal }))
            } catch {
                single(.error(error))
            }
            
            return Disposables.create()
        })
    }
    
    // MARK: - Save helpers
    
    private func encodeItems(_ items: [LocalPostItem]) -> Single<Data> {
        return .create(subscribe: { single in
            do {
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(items.map { CodablePostItem(localPostItem: $0) })
                single(.success(encoded))
            } catch {
                single(.error(error))
            }
            
            return Disposables.create()
        })
    }
    
    private func writeEncodedData(_ data: Data) -> Completable {
        return .create(subscribe: { completable in
            do {
                try data.write(to: self.storeURL)
                completable(.completed)
            } catch {
                completable(.error(error))
            }
            
            return Disposables.create()
        })
    }
}
