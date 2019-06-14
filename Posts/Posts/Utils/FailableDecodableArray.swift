//
//  FailableDecodableArray.swift
//  Posts
//
//  Created by Pusca Ghenadie on 13/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

struct FailableCodableArray<Element : Decodable> : Decodable {
    
    private(set) var elements: [Element]
    
    init(from decoder: Decoder) throws {
        
        var container = try decoder.unkeyedContainer()
        
        var elements = [Element]()
        if let count = container.count {
            elements.reserveCapacity(count)
        }
        
        while !container.isAtEnd {
            if let element = try container
                .decode(FailableDecodable<Element>.self).base {
                elements.append(element)
            }
        }
        
        self.elements = elements
    }
}
