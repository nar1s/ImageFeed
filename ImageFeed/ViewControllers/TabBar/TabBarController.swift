//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 02.01.2026.
//
import UIKit

final class TabBarController: UITabBarController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
        setupViewControllers()
    }

    // MARK: - Setup

    private func setupViewControllers() {
        let imagesListViewController = ImagesListViewController()
        
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabEditorialActive),
            selectedImage: nil
        )

        let profileViewController = ProfileViewController()

        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )

        viewControllers = [imagesListViewController, profileViewController]
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .yapBlack

        appearance.stackedLayoutAppearance.selected.iconColor = .yapWhite
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.yapWhite]

        tabBar.standardAppearance = appearance

        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
