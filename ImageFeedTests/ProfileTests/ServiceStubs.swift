//
//  ServiceStubs.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 18.01.2026.
//

@testable import ImageFeed
import UIKit

final class ProfileServiceStub: ProfileServiceProtocol {
    var profile: Profile?
    
    init(profile: Profile?) {
        self.profile = profile
    }

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
    }
}

final class ProfileImageServiceStub: ProfileImageServiceProtocol {
    var avatarURL: String?
    let didChangeNotification = Notification.Name("ProfileImageServiceStubDidChange")
    
    init(avatarURL: String?) {
        self.avatarURL = avatarURL
    }
}

final class LogoutServiceSpy: ProfileLogoutServiceProtocol {
    private(set) var logoutCalled = false
    func logout() { logoutCalled = true }
}
