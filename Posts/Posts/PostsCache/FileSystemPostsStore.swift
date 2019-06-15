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
    private let queue = DispatchQueue(label: "FileSystemPostsStore.queue",
        qos: .userInitiated)
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func deleteCachedPosts() -> Completable {
        let url = self.storeURL
        return FileSystemPostsStore.deleteCache(url).subscribeOn(SerialDispatchQueueScheduler.init(queue: queue, internalSerialQueueName: "\(type(of: self)).queue"))
    }

    public func savePosts(_ items: [LocalPostItem]) -> Completable {
        let url = self.storeURL
        return FileSystemPostsStore.encodeItems(items).flatMapCompletable { FileSystemPostsStore.writeEncodedData($0, url) }.subscribeOn(SerialDispatchQueueScheduler.init(queue: queue, internalSerialQueueName: "\(type(of: self)).queue"))
    }
    
    public func retrieve() -> Single<RetrieveResult> {
        let url = self.storeURL
        return FileSystemPostsStore.getCachedData(url).flatMap(FileSystemPostsStore.decodeCachedData).ifEmpty(default: []).subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: .global()))
    }
    
    // MARK: - Deletion helpers

    private static func deleteCache(_ url: URL) -> Completable {
        return .create(subscribe: { completable in
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.removeItem(at: url)
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
    
    // MARK: - Retrieval helpers
    
    private static func getCachedData(_ url: URL) -> Maybe<Data> {
        return .create(subscribe: { single in
            do {
                let data = try Data(contentsOf: url)
                single(.success(data))
            } catch {
                single(.completed)
            }
            
            return Disposables.create()
        })
    }
    
    private static func decodeCachedData(_ data: Data) -> Maybe<RetrieveResult> {
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
    
    private static func encodeItems(_ items: [LocalPostItem]) -> Single<Data> {
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
    
    private static func writeEncodedData(_ data: Data, _ url: URL) -> Completable {
        return .create(subscribe: { completable in
            do {
                try data.write(to: url)
                completable(.completed)
            } catch {
                completable(.error(error))
            }
            
            return Disposables.create()
        })
    }
}
