//
//  ProfileViewControllerSpy.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 18.01.2026.
//

@testable import ImageFeed
import UIKit

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    
    var presenter: ProfilePresenterProtocol?

    private(set) var displayProfileCalled = false
    var name: String?
    var login: String?
    var bio: String?

    var displayAvatarCalled = false
    var avatarURL: URL?
    var onDisplayAvatar: ((URL?) -> Void)?
    
    private(set) var showLogoutConfirmationCalled = false
    
    func displayProfile(name: String, login: String, bio: String) {
        displayProfileCalled = true
        self.name = name
        self.login = login
        self.bio = bio
    }
    
    func displayAvatar(url: URL?) {
        displayAvatarCalled = true
        avatarURL = url
        onDisplayAvatar?(url)
    }
    
    func showLogoutConfirmation() {
        showLogoutConfirmationCalled = true
    }
    
    
}
