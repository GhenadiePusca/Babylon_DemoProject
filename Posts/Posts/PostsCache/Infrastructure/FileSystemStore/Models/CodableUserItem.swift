//
//  CodableAuthorItem.swift
//  Posts
//
//  Created by Pusca Ghenadie on 17/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

public struct CodableUserItem: Codable {
    public let id: Int
    public let name: String
    public let userName: String
    public let emailAddress: String
    public let address: CodableAddressItem
    public let phoneNumber: String
    public let websiteURL: String
    public let company: CodableCompanyItem
    
    public init(localItem: LocalUserItem){
        self.id = localItem.id
        self.name = localItem.name
        self.userName = localItem.userName
        self.emailAddress = localItem.emailAddress
        self.address = CodableAddressItem(localItem: localItem.address)
        self.phoneNumber = localItem.phoneNumber
        self.websiteURL = localItem.websiteURL
        self.company = CodableCompanyItem(localItem: localItem.company)
    }
}

extension CodableUserItem {
    var toLocal: LocalUserItem {
        return LocalUserItem(id: id,
                             name: name,
                             userName: userName,
                             emailAddress: emailAddress,
                             address: address.toLocal,
                             phoneNumber: phoneNumber,
                             websiteURL: websiteURL,
                             company: company.toLocal)
    }
}


public struct CodableAddressItem: Codable {
    public let street: String
    public let suite: String
    public let city: String
    public let zipcode: String
    public let coordinates: CodableCoordinatesItem
    
    public init(localItem: LocalAddressItem) {
        self.street = localItem.street
        self.suite = localItem.suite
        self.city = localItem.city
        self.zipcode = localItem.zipcode
        self.coordinates = CodableCoordinatesItem(localItem: localItem.coordinates)
    }
}

public struct CodableCoordinatesItem: Codable {
    public let latitude: String
    public let longitute: String
    
    public init(localItem: LocalCoordinatesItem) {
        self.latitude = localItem.latitude
        self.longitute = localItem.longitute
    }
}

public struct CodableCompanyItem: Codable {
    public let name: String
    public let catchPhrase: String
    public let bussinesScope: String
    
    public init(localItem: LocalCompanyItem) {
        self.name = localItem.name
        self.catchPhrase = localItem.catchPhrase
        self.bussinesScope = localItem.bussinesScope
    }
}


extension CodableAddressItem {
    var toLocal: LocalAddressItem {
        return LocalAddressItem(street: street,
                                suite: suite,
                                city: city,
                                zipcode: zipcode,
                                coordinates: coordinates.toLocal)
    }
}

extension CodableCoordinatesItem {
    var toLocal: LocalCoordinatesItem {
        return LocalCoordinatesItem(latitude: latitude,
                                    longitute: longitute)
    }
}

extension CodableCompanyItem {
    var toLocal: LocalCompanyItem {
        return LocalCompanyItem(name: name,
                                catchPhrase: catchPhrase,
                                bussinesScope: bussinesScope)
    }
}
