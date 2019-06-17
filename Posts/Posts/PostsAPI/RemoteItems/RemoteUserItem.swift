//
//  RemoteAuthorItem.swift
//  Posts
//
//  Created by Pusca Ghenadie on 17/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

public struct RemoteUserItem: Decodable {
    public let id: Int
    public let name: String
    public let username: String
    public let email: String
    public let address: RemoteAddressItem
    public let phone: String
    public let website: String
    public let company: RemoteCompanyItem
}

public struct RemoteAddressItem: Decodable {
    public let street: String
    public let suite: String
    public let city: String
    public let zipcode: String
    public let geo: RemoteGeoItem
}

public struct RemoteGeoItem: Decodable {
    public let lat: String
    public let lng: String
}

public struct RemoteCompanyItem: Decodable {
    public let name: String
    public let catchPhrase: String
    public let bs: String
}
