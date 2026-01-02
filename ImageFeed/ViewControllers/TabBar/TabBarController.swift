//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 02.01.2026.
//
import UIKit

final class TabBarController: UITabBarController {

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTabBarAppearance()
        setupViewControllers()
        print("вызвался")
    }

    // MARK: - Setup

    private func setupViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )

        let profileViewController = storyboard.instantiateViewController(
            withIdentifier: "ProfileViewController"
        )

        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )

        viewControllers = [
            imagesListViewController,
            profileViewController
        ]
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .yapBlack

        tabBar.standardAppearance = appearance

        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}

	   
