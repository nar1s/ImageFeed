//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 31.12.2025.
//

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    func displayProfile(name: String, login: String, bio: String)
    func displayAvatar(url: URL?)
    func showLogoutConfirmation()
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private var presenter: ProfilePresenterProtocol?
    
    // MARK: - UI
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 35
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .yapWhite
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .yapGray
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .yapWhite
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Config

    func configure(with presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.bind(view: self)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLogoutButton()
        presenter?.viewDidLoad()
    }
    
    // MARK: - Public methods
    
    func displayProfile(name: String, login: String, bio: String) {
        nameLabel.text = name
        loginNameLabel.text = login
        descriptionLabel.text = bio
    }
    
    func displayAvatar(url: URL?) {
        setAvatar(url: url)
    }
    
    func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )

        let logout = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.presenter?.didConfirmLogout()
        }

        let cancel = UIAlertAction(title: "Нет", style: .default)

        alert.addAction(logout)
        alert.addAction(cancel)

        present(alert, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func setupLogoutButton() {
        let logoutImage = UIImage(resource: .logoutButton).withRenderingMode(.alwaysOriginal)
        logoutButton.setImage(logoutImage, for: .normal)

        logoutButton.addAction(UIAction { [weak self] _ in
            self?.presenter?.didTapLogout()
        }, for: .touchUpInside)
    }
    
    private func setupUI() {
        view.backgroundColor = .yapBlack
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)

        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setAvatar(url: URL?) {
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))

        guard let url else {
            avatarImageView.image = placeholderImage
            return
        }

        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]
        )
    }
}
