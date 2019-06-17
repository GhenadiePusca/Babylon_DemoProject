//
//  PostDetailModel.swift
//  Posts
//
//  Created by Pusca Ghenadie on 17/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import RxSwift

public struct PostDetailsModel {
    public let title: String
    public let body: String
    public let authorName: Observable<Loadable<String>>
    public let numberOfComments: Observable<Loadable<Int>>
    
    public init(title: String,
                body: String,
                authorName: Observable<Loadable<String>>,
                numberOfComments: Observable<Loadable<Int>>) {
        self.title = title
        self.body = body
        self.authorName = authorName
        self.numberOfComments = numberOfComments
    }
}
