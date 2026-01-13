//
//  Photo.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 12.01.2026.
//

import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Codable {
    let id: String?
    let width: Int?
    let height: Int?
    let createdAt: Date?
    let welcomeDescription: String?
    let urls: Urls?
    let likedByUser: Bool?

    struct Urls: Codable {
        let thumb: String?
        let regular: String?
        let full: String?
        let small: String?
        let raw: String?
    }

    var thumbImageURL: String? { urls?.thumb }
    var largeImageURL: String? { urls?.regular }
    var isLiked: Bool? { likedByUser }
}
