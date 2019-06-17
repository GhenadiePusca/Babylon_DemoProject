//
//  LocalAuthorItem.swift
//  Posts
//
//  Created by Pusca Ghenadie on 17/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

public struct LocalUserItem {
    public let id: Int
    public let name: String
    public let userName: String
    public let emailAddress: String
    public let address: LocalAddressItem
    public let phoneNumber: String
    public let websiteURL: String
    public let company: LocalCompanyItem
    
    public init(id: Int,
                name: String,
                userName: String,
                emailAddress: String,
                address: LocalAddressItem,
                phoneNumber: String,
                websiteURL: String,
                company: LocalCompanyItem) {
        self.id = id
        self.name = name
        self.userName = userName
        self.emailAddress = emailAddress
        self.address = address
        self.phoneNumber = phoneNumber
        self.websiteURL = websiteURL
        self.company = company
    }
}

public struct LocalAddressItem {
    public let street: String
    public let suite: String
    public let city: String
    public let zipcode: String
    public let coordinates: LocalCoordinatesItem
    
    public init(street: String,
                suite: String,
                city: String,
                zipcode: String,
                coordinates: LocalCoordinatesItem) {
        self.street = street
        self.suite = suite
        self.city = city
        self.zipcode = zipcode
        self.coordinates = coordinates
    }
}

public struct LocalCoordinatesItem {
    public let latitude: String
    public let longitute: String
    
    public init(latitude: String,
                longitute: String) {
        self.latitude = latitude
        self.longitute = longitute
    }
}

public struct LocalCompanyItem {
    public let name: String
    public let catchPhrase: String
    public let bussinesScope: String
    
    public init(name: String,
                catchPhrase: String,
                bussinesScope: String) {
        self.name = name
        self.catchPhrase = catchPhrase
        self.bussinesScope = bussinesScope
    }
}
