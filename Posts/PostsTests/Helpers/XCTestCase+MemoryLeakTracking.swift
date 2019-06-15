//
//  XCTestCase+MemoryLeakTracking.swift
//  PostsTests
//
//  Created by Pusca Ghenadie on 13/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            if instance != nil {
                print("instance not nil \(instance)")
            }
            XCTAssertNil(instance, "Instance should have been deallocated.", file: file, line: line)
        }
    }
}
