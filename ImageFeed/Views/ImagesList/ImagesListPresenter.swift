//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 18.01.2026.
//

import UIKit
import Kingfisher

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - Properties

    weak var view: ImagesListViewControllerProtocol?
    private let photoService: ImagesListServiceProtocol

    private var photos: [Photo] = []

    var photosCount: Int {
        photos.count
    }

    // MARK: - Init

    init(photoService: ImagesListServiceProtocol) {
        self.photoService = photoService
    }
    
    func photo(at indexPath: IndexPath) -> Photo? {
        guard indexPath.row < photos.count else { return nil }
        return photos[indexPath.row]
    }
    
    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }

            let oldCount = self.photos.count
            self.photos = self.photoService.photos
            let newCount = self.photos.count

            if oldCount == 0 || newCount < oldCount {
                self.view?.reloadData()
                return
            }

            if newCount > oldCount {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                self.view?.insertRows(at: indexPaths)
            }
        }
        if photoService.photos.isEmpty {
            photoService.fetchPhotosNextPage()
        } else {
            photos = photoService.photos
            view?.reloadData()
        }
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    func didScrollBottom() {
        photoService.fetchPhotosNextPage()
    }
    
    func didTapPhoto(at indexPath: IndexPath) {
        guard let photo = photo(at: indexPath) else { return }
        view?.openSingleImage(photo)
    }
    
    func didTapLike(at indexPath: IndexPath) {
        guard let photo = photo(at: indexPath) else { return }

        view?.showLoadingIndicator()
        let targetIsLike = !photo.isLiked

        photoService.changeLike(photoId: photo.id, isLike: targetIsLike) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoadingIndicator()
                switch result {
                case .success:
                    self?.view?.reloadRow(at: indexPath)
                case .failure(let error):
                    self?.view?.showError(error)
                    self?.view?.reloadRow(at: indexPath)
                }
            }
        }
    }
}
