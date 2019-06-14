//
//  PostsMapper.swift
//  Posts
//
//  Created by Pusca Ghenadie on 13/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

struct PostsMapper {
    
    private static let OK_HTTTP_RESPONSE = 200
    
    internal static func mapSuccess(_ result: (data: Data, response: HTTPURLResponse)) throws -> [RemotePostItem] {
        guard result.response.statusCode == OK_HTTTP_RESPONSE,
            let resultContainer = try? JSONDecoder().decode(FailableCodableArray<RemotePostItem>.self,
                                                            from: result.data) else {
                throw RemotePostsLoader.Error.invalidData
        }
        
        return resultContainer.elements
    }
}
