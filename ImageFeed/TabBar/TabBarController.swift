//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 02.01.2026.
//

import UIKit

final class TabBarController: UITabBarController {
	   override func awakeFromNib() {
		   super.awakeFromNib()
		   let storyboard = UIStoryboard(name: "Main", bundle: .main)
		   let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
		   let profileViewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController")
		   profileViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(resource: .tabProfileActive), selectedImage: nil)
		   self.viewControllers = [imagesListViewController, profileViewController]
	   }
   }
	   
