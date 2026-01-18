//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 02.01.2026.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    // MARK: - Public Properties
    
    var photo: Photo? {
        didSet {
            guard isViewLoaded, let photo else { return }
            loadImage(from: photo)
        }
    }
    
    // MARK: - UI
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.delegate = self
        sv.backgroundColor = .yapBlack
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .yapBlack
        return iv
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        let backImage = UIImage(resource: .backwardButton)
        button.setImage(backImage, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 24
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        let shareImage = UIImage(resource: .sharingButton)
        button.setImage(shareImage, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yapBlack
        
        setupViews()
        setupConstraints()
        configureZoom()
        if let photo = photo { loadImage(from: photo) }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard imageView.image != nil else { return }
        rescaleAndCenterImageInScrollView()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(backButton)
        view.addSubview(shareButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let contentGuide = scrollView.contentLayoutGuide
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor)
        ])
        
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 8),
            backButton.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 48),
            backButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        NSLayoutConstraint.activate([
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -16),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureZoom() {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 5.0
        scrollView.bouncesZoom = true
    }
    
    // MARK: - Actions
    
    @objc private func didTapBackButton() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func didTapShareButton() {
        guard let imageToShare = imageView.image else { return }
        let activityVC = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func rescaleAndCenterImageInScrollView() {
        guard let image = imageView.image else { return }
        
        view.layoutIfNeeded()
        
        let bounds = scrollView.bounds.size
        guard bounds.width > 0, bounds.height > 0 else { return }
        
        let imageSize = image.size
        let hScale = bounds.width / imageSize.width
        let vScale = bounds.height / imageSize.height
        let aspectFillScale = max(hScale, vScale)
        
        scrollView.minimumZoomScale = aspectFillScale
        scrollView.maximumZoomScale = max(5.0, aspectFillScale)
        
        scrollView.setZoomScale(aspectFillScale, animated: false)

        centerByOffsetIfNeeded()
        centerContent()
    }
    
    private func centerContent() {
        let visibleSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        
        let insetX = max((visibleSize.width - contentSize.width) / 2, 0)
        let insetY = max((visibleSize.height - contentSize.height) / 2, 0)
        
        scrollView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
    }
    
    private func centerByOffsetIfNeeded() {
        let bounds = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        
        var offset = scrollView.contentOffset
        var changed = false
        
        if contentSize.width > bounds.width {
            offset.x = (contentSize.width - bounds.width) / 2
            changed = true
        }
        if contentSize.height > bounds.height {
            offset.y = (contentSize.height - bounds.height) / 2
            changed = true
        }
        if changed {
            scrollView.setContentOffset(offset, animated: false)
        }
    }
    
    private func loadImage(from photo: Photo) {
        guard let url = URL(string: photo.largeImageURL) else { return }
        
        imageView.kf.indicatorType = .activity
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            switch result {
            case .success:
                self.rescaleAndCenterImageInScrollView()
            case .failure(let error):
                self.showError()
                print("Ошибка загрузки изображения: \(error)")
            }
        }
    }
    
    private func showError() {
        guard let photo else { return }
        
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        alert.addAction(UIAlertAction(title: "ОК", style: .default) { _ in
            self.loadImage(from: photo)
        })
        present(alert, animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerContent()
    }
}
