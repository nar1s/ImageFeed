//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 31.12.2025.
//

import UIKit

struct Profile {
    let avatarImageName: String?
    let fullName: String
    let username: String
    let bio: String
}

final class ProfileViewController: UIViewController {
    
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yapBlack
        
        setupViews()
        setupConstraints()
        setupActions()
        
        // Mock data
        let mockProfile = Profile(
            avatarImageName: "avatar",
            fullName: "Екатерина Новикова",
            username: "@ekaterina_nov",
            bio: "Hello, World!"
        )
        configure(with: mockProfile)
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
    }
    
    private func setupConstraints() {
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
    
    private func setupActions() {
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            self.configure(with: Profile(avatarImageName: nil, fullName: "", username: "", bio: ""))
        }
        logoutButton.addAction(action, for: .touchUpInside)
    }
    
    // MARK: - Configuration
    
    func configure(with profile: Profile) {
        if let imageName = profile.avatarImageName, let image = UIImage(named: imageName) {
            avatarImageView.image = image
            avatarImageView.backgroundColor = .clear
        } else {
            avatarImageView.image = nil
            avatarImageView.backgroundColor = .yapBlack
        }
        
        nameLabel.text = profile.fullName
        loginNameLabel.text = profile.username
        descriptionLabel.text = profile.bio
        
        let logoutImage = UIImage(named: "logout_button")?.withRenderingMode(.alwaysOriginal)
        logoutButton.setImage(logoutImage, for: .normal)

        let isEmpty = profile.fullName.isEmpty && profile.username.isEmpty && profile.bio.isEmpty
        logoutButton.isHidden = isEmpty
    }
}

