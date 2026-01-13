//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 02.01.2026.
//

import UIKit

final class SingleImageViewController: UIViewController {
    // MARK: - Public Properties
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            applyImage()
        }
    }
    
    // MARK: - UI
    
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let backButton = UIButton(type: .custom)
    private let shareButton = UIButton(type: .custom)
    
    // MARK: - State
    
    private var didApplyInitialZoom = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yapBlack
        
        setupViews()
        setupConstraints()
        configureZoom()
        applyImage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard imageView.image != nil else { return }
        rescaleAndCenterImageInScrollView()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.backgroundColor = .yapBlack
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .yapBlack
        scrollView.addSubview(imageView)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        let backImage = UIImage(resource: .backwardButton)
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = .white
        backButton.layer.cornerRadius = 24
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        view.addSubview(backButton)
        
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        let shareImage = UIImage(resource: .sharingButton)
        shareButton.setImage(shareImage, for: .normal)
        shareButton.tintColor = .white
        shareButton.layer.cornerRadius = 25
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
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
        
        let visibleSize = scrollView.bounds.size
        guard visibleSize.width > 0, visibleSize.height > 0 else { return }
        
        let imageSize = image.size
        let hScale = visibleSize.width / imageSize.width
        let vScale = visibleSize.height / imageSize.height
        let aspectFillScale = max(hScale, vScale)
        
        let currentZoom = max(scrollView.zoomScale, 0.0001)
        let currentOffset = scrollView.contentOffset
        
        let newMinZoom = min(aspectFillScale, currentZoom)
        let newMaxZoom = max(scrollView.maximumZoomScale, newMinZoom + 0.0001)
        
        scrollView.minimumZoomScale = newMinZoom
        scrollView.maximumZoomScale = newMaxZoom
        
        if didApplyInitialZoom == false {
            scrollView.setZoomScale(aspectFillScale, animated: false)
            centerContent()
            didApplyInitialZoom = true
        } else {
            let clampedZoom = min(max(currentZoom, scrollView.minimumZoomScale), scrollView.maximumZoomScale)
            if abs(clampedZoom - currentZoom) > .ulpOfOne {
                scrollView.setZoomScale(clampedZoom, animated: false)
            }
            scrollView.setContentOffset(currentOffset, animated: false)
            centerContent()
        }
    }
    
    private func centerContent() {
        let visibleSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        
        let insetX = max((visibleSize.width - contentSize.width) / 2, 0)
        let insetY = max((visibleSize.height - contentSize.height) / 2, 0)
        
        scrollView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
    }
    
    private func applyImage() {
        guard let image else { return }
        imageView.image = image
        didApplyInitialZoom = false
        if view.window != nil {
            rescaleAndCenterImageInScrollView()
        }
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
