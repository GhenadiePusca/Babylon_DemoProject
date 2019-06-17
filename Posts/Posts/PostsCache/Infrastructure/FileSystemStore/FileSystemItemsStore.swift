//
//  GenericStore.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation
import RxSwift

public class FileSystemItemsStore<SavedItem, EncodedItem: Codable>: ItemsStore {
    public typealias ItemType = SavedItem
    
    public typealias SavedToEncodedMapper = ([SavedItem]) -> [EncodedItem]
    public typealias EcondedToSavedMapper = ([EncodedItem]) -> [SavedItem]
    private let savedToEncodedMapper: SavedToEncodedMapper
    private let econdedToSavedMapper: EcondedToSavedMapper
    
    private lazy var sideEffectsScheduler = SerialDispatchQueueScheduler.init(internalSerialQueueName: "\(type(of: self))")
    private let storeURL: URL
    
    public init(storeURL: URL,
                savedToEncodedMapper: @escaping SavedToEncodedMapper,
                econdedToSavedMapper: @escaping EcondedToSavedMapper) {
        self.storeURL = storeURL
        self.savedToEncodedMapper = savedToEncodedMapper
        self.econdedToSavedMapper = econdedToSavedMapper
    }
    
    public func deleteItems() -> Completable {
        let url = self.storeURL
        return FileSystemItemsStore.deleteCache(url).subscribeOn(sideEffectsScheduler)
    }
    
    public func savePosts(_ items: [SavedItem]) -> Completable {
        let url = self.storeURL
        let mapper = savedToEncodedMapper
        return FileSystemItemsStore.encodeItems(mapper(items))
            .flatMapCompletable { FileSystemItemsStore.writeEncodedData($0, url) }
            .subscribeOn(sideEffectsScheduler)
    }
    
    public func retrieve() -> Single<[SavedItem]> {
        let url = self.storeURL
        let mapper = econdedToSavedMapper
        return FileSystemItemsStore.getCachedData(url)
            .flatMap(FileSystemItemsStore.decodeCachedData)
            .map { mapper($0) }
            .ifEmpty(default: [])
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: .global()))

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
        return .create(subscribe: { maybe in
            do {
                let data = try Data(contentsOf: url)
                maybe(.success(data))
            } catch {
                maybe(.completed)
            }
            
            return Disposables.create()
        })
    }
    
    private static func decodeCachedData(_ data: Data) -> Maybe<[EncodedItem]> {
        return .create(subscribe: { maybe in
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(FailableDecodableArray<EncodedItem>.self, from: data)
                maybe(.success(decoded.elements))
            } catch {
                maybe(.error(error))
            }
            
            return Disposables.create()
        })
    }
    
    // MARK: - Save helpers
    
    private static func encodeItems<Item: Encodable>(_ items: [Item]) -> Single<Data> {
        return .create(subscribe: { single in
            do {
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(items)
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
