//
//  ProfileProtocols.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 20.01.2026.
//

import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func bind(view: ProfileViewControllerProtocol)
    func viewDidLoad()
    func didTapLogout()
    func didConfirmLogout()
}

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func displayProfile(name: String, login: String, bio: String)
    func displayAvatar(url: URL?)
    func showLogoutConfirmation()
}
