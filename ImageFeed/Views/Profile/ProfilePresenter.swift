//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 18.01.2026.
//

import UIKit

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let logoutService: ProfileLogoutServiceProtocol
    private let notificationCenter: NotificationCenter
    
    private var avatarObserver: NSObjectProtocol?
    
    init(
        profileService: ProfileServiceProtocol,
        profileImageService: ProfileImageServiceProtocol,
        logoutService: ProfileLogoutServiceProtocol,
        notificationCenter: NotificationCenter = .default
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.logoutService = logoutService
        self.notificationCenter = notificationCenter
    }

    deinit {
        if let avatarObserver {
            notificationCenter.removeObserver(avatarObserver)
        }
    }
    
    func bind(view: ProfileViewControllerProtocol) {
            self.view = view
        }

    func viewDidLoad() {
        subscribeAvatarUpdates()
        updateProfile()
        updateAvatar()
    }
    
    func didTapLogout() {
        view?.showLogoutConfirmation()
    }

    func didConfirmLogout() {
        logoutService.logout()
    }
    
    private func updateProfile() {
        guard let profile = profileService.profile else {
            view?.displayProfile(
                name: "Имя не указано",
                login: "@неизвестный_пользователь",
                bio: "Профиль не заполнен"
            )
            return
        }
        let name = profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let login = profile.loginName.trimmingCharacters(in: .whitespacesAndNewlines)
        let bio = profile.bio.trimmingCharacters(in: .whitespacesAndNewlines)

        view?.displayProfile(
            name: name.isEmpty ? "Имя не указано" : name,
            login: login.isEmpty ? "@неизвестный_пользователь" : login,
            bio: bio.isEmpty ? "Профиль не заполнен" : bio
        )
    }
    
    private func updateAvatar() {
        let url: URL? = {
            guard let s = profileImageService.avatarURL, let u = URL(string: s) else { return nil }
            return u
        }()
        view?.displayAvatar(url: url)
    }
    
    private func subscribeAvatarUpdates() {
        avatarObserver = notificationCenter.addObserver(
            forName: profileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
    }    
}
