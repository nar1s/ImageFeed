//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 03.01.2026.
//

import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - UI
    
    private var logoImageView: UIImageView!
    
    // MARK: - Properties
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupUI()
        
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - Private helpers
    
    private func switchToTabBarController() {
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive } ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
        
        guard
            let scene = windowScene,
            let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first
        else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarController")
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case let .success(profile):
                ProfileImageService.shared.fetchProfileImage(username: profile.username) { _ in }
                self.switchToTabBarController()
                
            case let .failure(error):
                print(error)
                break
            }
        }
    }
    
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Не удалось найти AuthViewController по идентификатору")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = .yapBlack
        setupImageView()
    }
    
    private func setupImageView() {
        let imageSplashScreenLogo = UIImage(resource: .splashScreenLogo)
        
        logoImageView = UIImageView(image: imageSplashScreenLogo)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - AuthViewControllerDelegate)

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        switchToTabBarController()
    }
}
