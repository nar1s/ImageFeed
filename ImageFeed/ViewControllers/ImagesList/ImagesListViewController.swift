import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Properties

    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        configureImageView()
    }

    // MARK: - Private Methods

    private func setupTableView() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    private func configureImageView() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                guard let self else { return }
                self.updateTableViewAnimated()
            })
        
        imagesListService.fetchPhotosNextPage()
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if newCount < oldCount {
            let indexPaths = (newCount..<oldCount).map { IndexPath(row: $0, section: 0) }
            tableView.performBatchUpdates {
                tableView.deleteRows(at: indexPaths, with: .automatic)
            }
            return
        }

        if newCount > oldCount {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.performBatchUpdates {
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
            return
        } else {
            let visible = tableView.indexPathsForVisibleRows ?? []
            tableView.reloadRows(at: visible, with: .none)
        }
    }
    
    // MARK: - Alerts
    
    private func showError(completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        alert.addAction(UIAlertAction(title: "ОК", style: .default) { _ in
            completion()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )

        guard let imageCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageCell.delegate = self

        configureCell(imageCell, at: indexPath)
        return imageCell
    }
}

// MARK: - Cell Configuration

extension ImagesListViewController {

    private func configureCell(_ cell: ImagesListCell, at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        cell.cellImage.kf.indicatorType = .activity
        let placeholder = UIImage(resource: .loadCard)
        
        cell.cellImage.kf.setImage(
            with: URL(string: photo.largeImageURL),
            placeholder: placeholder,
            options: [
                .transition(.fade(0.25)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ]) { [weak self] _ in
                guard let self else { return }
                self.tableView.performBatchUpdates(nil)
            }
        
        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = "unknown date"
        }
        
        cell.setIsLiked(photo.isLiked)
        cell.setLikeEnabled(true)
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openSingleImage(at: indexPath)
    }
    
    private func openSingleImage(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let vc = SingleImageViewController()
        
        UIBlockingProgressHUD.show()
        guard let url = URL(string: photo.fullImageURL) else {
            showError { [weak self] in
                self?.openSingleImage(at: indexPath)
            }
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            Task { @MainActor in
                UIBlockingProgressHUD.dismiss()
            }
            guard let self else { return }
            switch result {
            case .success(let value):
                DispatchQueue.main.async {
                    vc.image = value.image
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            case .failure:
                DispatchQueue.main.async {
                    self.showError { [weak self] in
                        self?.openSingleImage(at: indexPath)
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        return photo.size.height * scale + imageInsets.top + imageInsets.bottom
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let threshold = 3
        let lastIndex = photos.count - 1
        if indexPath.row >= lastIndex - threshold {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        let targetIsLike = !photo.isLiked
        
        cell.setLikeEnabled(false)
        cell.setIsLiked(targetIsLike)
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            guard let self else { return }
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                if let currentIndexPath = self.tableView.indexPath(for: cell) {
                    self.configureCell(cell, at: currentIndexPath)
                } else {
                    if let newIndex = self.photos.firstIndex(where: { $0.id == photo.id }) {
                        self.tableView.reloadRows(at: [IndexPath(row: newIndex, section: 0)], with: .none)
                    }
                }
            case .failure:
                if let currentIndexPath = self.tableView.indexPath(for: cell) {
                    self.configureCell(cell, at: currentIndexPath)
                } else {
                    if let idx = self.photos.firstIndex(where: { $0.id == photo.id }) {
                        self.tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .none)
                    }
                }
                self.showError { [weak self] in
                    guard let self else { return }
                    self.imageListCellDidTapLike(cell)
                }
            }
            cell.setLikeEnabled(true)
        }
    }
}
