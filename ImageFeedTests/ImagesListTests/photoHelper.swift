//
//  photoHelper.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 18.01.2026.
//

@testable import ImageFeed
import UIKit

func makePhoto(id: String, isLiked: Bool) -> Photo {
    Photo(
        id: id,
        size: CGSize(width: 1000, height: 800),
        createdAt: Date(),
        welcomeDescription: nil,
        fullImageURL: "https://example.com/full.jpg",
        largeImageURL: "https://example.com/large.jpg",
        isLiked: isLiked
    )
}
