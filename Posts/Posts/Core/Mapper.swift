//
//  Mapper.swift
//  Posts
//
//  Created by Pusca Ghenadie on 17/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

public struct Mapper {}

// MARK: - Posts mapping
extension Mapper {
    public static func localPostsEncodable(_ local: [LocalPostItem]) -> [CodablePostItem] {
        return local.map { CodablePostItem(localPostItem: $0) }
    }
    
    public static func encodableToLocal(_ codable: [CodablePostItem]) -> [LocalPostItem] {
        return codable.map { LocalPostItem(id: $0.id,
                                           userId: $0.userId,
                                           title: $0.title,
                                           body: $0.body) }
    }
    
    public static func localPostsToPost(_ local: [LocalPostItem]) -> [PostItem] {
        return local.map { PostItem(id: $0.id,
                                    userId: $0.userId,
                                    title: $0.title,
                                    body: $0.body) }
    }
    
    public static func postToLocalPosts(_ posts: [PostItem]) -> [LocalPostItem] {
        return posts.map { LocalPostItem(id: $0.id,
                                         userId: $0.userId,
                                         title: $0.title,
                                         body: $0.body) }
    }
    
    public static func remotePostsToPost(_ posts: [RemotePostItem]) -> [PostItem] {
        return posts.map { PostItem(id: $0.id,
                                    userId: $0.userId,
                                    title: $0.title,
                                    body: $0.body) }
    }
}

// MARK: - Comments mapper
extension Mapper {

    public static func remoteCommentsToComments(_ comments: [RemoteCommentItem]) -> [CommentItem] {
        return comments.map { CommentItem(id: $0.id,
                                         postId: $0.postId,
                                         authorName: $0.name,
                                         authorEmail: $0.email,
                                         body: $0.body) }
    }
    
    public static func localCommentsToEncodable(_ local: [LocalCommentItem]) -> [CodableCommentItem] {
        return local.map { CodableCommentItem(localItem: $0) }
    }
    
    public static func encodableCommentsToLocalComments(_ codable: [CodableCommentItem]) -> [LocalCommentItem] {
        return codable.map { LocalCommentItem(id: $0.id,
                                              postId: $0.postId,
                                              authorName: $0.authorName,
                                              authorEmail: $0.authorEmail,
                                              body: $0.body) }
    }
    
    public static func localCommentsToComments(_ local: [LocalCommentItem]) -> [CommentItem] {
        return local.map { CommentItem(id: $0.id,
                                       postId: $0.postId,
                                       authorName: $0.authorName,
                                       authorEmail: $0.authorEmail,
                                       body: $0.body) }
    }
    
    public static func commentsToLocalComments(_ local: [CommentItem]) -> [LocalCommentItem] {
        return local.map { LocalCommentItem(id: $0.id,
                                            postId: $0.postId,
                                            authorName: $0.authorName,
                                            authorEmail: $0.authorEmail,
                                            body: $0.body) }
    }
    
}

// MARK: - Users mapper
extension Mapper {
    public static func remoteUsersToUsers(_ users: [RemoteUserItem]) -> [UserItem] {
        return users.map { $0.toUser }
    }
    
    public static func usersToLocalUsers(_ users: [UserItem]) -> [LocalUserItem] {
        return users.map { $0.toLocal }
    }
    
    public static func localUsersToUers(_ users: [LocalUserItem]) -> [UserItem] {
        return users.map { UserItem(withLocal: $0) }
    }
    
    public static func localUsersToCodableUsers(_ users: [LocalUserItem]) -> [CodableUserItem] {
        return users.map { CodableUserItem(localItem: $0) }
    }
    
    public static func codableUsersToLocalUsers(_ users: [CodableUserItem]) -> [LocalUserItem] {
        return users.map { $0.toLocal }
    }
}

fileprivate extension UserItem {
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
    
    init(withLocal local: LocalUserItem) {
        id = local.id
        name = local.name
        userName = local.userName
        emailAddress = local.emailAddress
        address = Address(withLocal: local.address)
        phoneNumber = local.phoneNumber
        websiteURL = local.websiteURL
        company = Company(withLocal: local.company)
    }
}

extension Address {
    var toLocal: LocalAddressItem {
        return LocalAddressItem(street: street,
                                suite: suite,
                                city: city,
                                zipcode: zipcode,
                                coordinates: coordinates.toLocal)
    }
    
    init(withLocal local: LocalAddressItem) {
        street = local.street
        suite = local.suite
        city = local.suite
        zipcode = local.zipcode
        coordinates = Coordinates(withLocal: local.coordinates)
    }
}

extension Coordinates {
    var toLocal: LocalCoordinatesItem {
        return LocalCoordinatesItem(latitude: latitude,
                                    longitute: longitute)
    }
    
    init(withLocal local: LocalCoordinatesItem) {
        latitude = local.latitude
        longitute = local.longitute
    }
}

extension Company {
    var toLocal: LocalCompanyItem {
        return LocalCompanyItem(name: name,
                                catchPhrase: catchPhrase,
                                bussinesScope: bussinesScope)
    }
    
    init(withLocal local: LocalCompanyItem) {
        name = local.name
        catchPhrase = local.catchPhrase
        bussinesScope = local.bussinesScope
    }
}

// MARK - Remote User to use
fileprivate extension RemoteUserItem {
    var toUser: UserItem {
        return UserItem(id: id,
                        name: name,
                        userName: username,
                        emailAddress: email,
                        address: address.toAddressItem,
                        phoneNumber: phone,
                        websiteURL: website,
                        company: company.toCompanyItem)
    }
}

fileprivate extension RemoteAddressItem {
    var toAddressItem: Address {
        return Address(street: street,
                       suite: suite,
                       city: city,
                       zipcode: zipcode,
                       coordinates: geo.toCoordinates)
    }
}

fileprivate extension RemoteGeoItem {
    var toCoordinates: Coordinates {
        return Coordinates(latitude: lat,
                           longitute: lng)
    }
}

fileprivate extension RemoteCompanyItem {
    var toCompanyItem: Company {
        return Company(name: name,
                       catchPhrase: catchPhrase,
                       bussinesScope: bs)
    }
}
