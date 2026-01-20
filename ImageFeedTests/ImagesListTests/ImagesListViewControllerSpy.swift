//
//  ImagesListViewControllerSpy.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 18.01.2026.
//

@testable import ImageFeed
import UIKit

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?

    // reload/insert
    var reloadDataCalled = false
    var insertRowsCalled = false
    var insertedIndexPaths: [IndexPath] = []

    var reloadRowCalled = false
    var reloadedIndexPath: IndexPath?

    // loading / errors
    var showLoadingCalled = false
    var hideLoadingCalled = false
    var showErrorCalled = false

    // navigation
    var openedPhoto: Photo?
    
    func reloadData() {
        reloadDataCalled = true
    }
    
    func insertRows(at indexPaths: [IndexPath]) {
        insertRowsCalled = true
        insertedIndexPaths = indexPaths
    }
    
    func reloadRow(at indexPath: IndexPath) {
        reloadRowCalled = true
        reloadedIndexPath = indexPath
    }
    
    func showLoadingIndicator() {
        showLoadingCalled = true
    }
    
    func hideLoadingIndicator() {
        hideLoadingCalled = true
    }
    
    func showError(_ error: any Error) {
        showErrorCalled = true
    }
    
    func openSingleImage(_ photo: ImageFeed.Photo) {
        openedPhoto = photo
    }
}
