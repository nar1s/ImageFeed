//
//  ProfileModel.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 02.01.2026.
//

import UIKit

struct Profile {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String
    
    var name: String { "\(firstName) \(lastName)" }
    var loginName: String { "@\(username)" }
}

struct ProfileResult: Codable {
    let username: String?
    let firstName: String?
    let lastName: String?
    let bio: String?
}

struct ProfileImage: Codable {
    let small: String?
    let medium: String?
    let large: String?
}

struct UserResult: Codable {
    let profileImage: ProfileImage?
}
