//
//  ImagesListProtocols.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 20.01.2026.
//

import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }

    var photosCount: Int { get }
    func photo(at indexPath: IndexPath) -> Photo?

    func viewDidLoad()
    func didScrollBottom()
    func didTapPhoto(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)
}

protocol ImagesListViewControllerProtocol: AnyObject {
    func reloadData()
    func insertRows(at indexPaths: [IndexPath])
    func reloadRow(at indexPath: IndexPath)

    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showError(_ error: Error)

    func openSingleImage(_ photo: Photo)
}
