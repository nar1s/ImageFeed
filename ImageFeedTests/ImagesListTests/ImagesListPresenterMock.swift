//
//  ImagesListPresenterSpy.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 18.01.2026.
//

@testable import ImageFeed
import UIKit

final class ImagesListPresenterMock: ImagesListPresenterProtocol {
    var view: ImageFeed.ImagesListViewControllerProtocol?
    
    var photosCount: Int = 0
    
    var viewDidLoadCalled = false
    var didScrollBottomCalled = false
    var didTapLikeCalled = false
    var didTapPhotoCalled = false
    
    func photo(at indexPath: IndexPath) -> ImageFeed.Photo? {
        return nil
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didScrollBottom() {
        didScrollBottomCalled = true
    }
    
    func didTapPhoto(at indexPath: IndexPath) {
        didTapLikeCalled = true
    }
    
    func didTapLike(at indexPath: IndexPath) {
        didTapPhotoCalled = true
    }
    
    
}
