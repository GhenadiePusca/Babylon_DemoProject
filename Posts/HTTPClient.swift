//
//  HTTPClient.swift
//  Posts
//
//  Created by Pusca Ghenadie on 11/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation
import RxSwift

public protocol HTTPClient {
    typealias GetResult = (data: Data, response: HTTPURLResponse)
    func get(fromURL url: URL) -> Single<GetResult>
}
