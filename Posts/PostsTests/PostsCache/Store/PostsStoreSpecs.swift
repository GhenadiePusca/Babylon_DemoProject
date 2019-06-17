//
//  PostsStoreSpecs.swift
//  PostsTests
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

protocol PostsStoreSpecs {
    func test_retrieve_deliversNoItemsOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversItemsOnNonEmptyCache()
    func test_retrieve_noSideEffectsOnSuccesfulRetrieve()
    func test_retrieve_deliversErorrOnInvalidData()
    func test_retrieve_noSideEffectsOnRetrievalError()
    
    func test_insert_overridesPreviouslyInsertedItems()
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
    
    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_deletesPreviousInsertedCache()
    func test_storeSideEffects_runSerially()
}
