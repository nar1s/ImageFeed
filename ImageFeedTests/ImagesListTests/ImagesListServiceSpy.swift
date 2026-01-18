//
//  ImagesListServiceSpy.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 18.01.2026.
//

@testable import ImageFeed
import UIKit

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    var photosStub: [Photo] = []
    var photos: [ImageFeed.Photo] { photosStub }
    
    var fetchPhotosNextPageCallCount: Int = 0
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCallCount += 1
    }
    
    var changeLikeCalledWith: (photoId: String, isLike: Bool)?
    var changeLikeResult: Result<Bool, Error> = .success(true)
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, any Error>) -> Void) {
        changeLikeCalledWith = (photoId: photoId, isLike: isLike)
        completion(changeLikeResult)
    }
}
